//
//  SessionManager.swift
//  GiniBankAPI
//
//  Created by Enrique del Pozo Gómez on 1/20/18.
//

import Foundation

/// Represents a completion result callback
public typealias CompletionResult<T> = (Result<T, GiniError>) -> Void

protocol SessionAuthenticationProtocol: AnyObject {
    func logIn(completion: @escaping (Result<Token, GiniError>) -> Void)
    func logOut()
}

protocol SessionProtocol: AnyObject {
    
    func data<T: Resource>(resource: T,
                           cancellationToken: CancellationToken?,
                           completion: @escaping CompletionResult<T.ResponseType>)
    func download<T: Resource>(resource: T,
                               cancellationToken: CancellationToken?,
                               completion: @escaping CompletionResult<T.ResponseType>)
    func upload<T: Resource>(resource: T,
                             data: Data,
                             cancellationToken: CancellationToken?,
                             completion: @escaping CompletionResult<T.ResponseType>)
    
}

extension SessionProtocol {
    func data<T: Resource>(resource: T,
                           completion: @escaping CompletionResult<T.ResponseType>) {
        data(resource: resource, cancellationToken: nil, completion: completion)
    }
    
    func upload<T: Resource>(resource: T,
                             data: Data,
                             completion: @escaping CompletionResult<T.ResponseType>) {
        upload(resource: resource, data: data, cancellationToken: nil, completion: completion)
    }
    
    func download<T: Resource>(resource: T,
                               completion: @escaping CompletionResult<T.ResponseType>) {
        download(resource: resource, cancellationToken: nil, completion: completion)
    }
    
}

typealias SessionManagerProtocol = SessionProtocol & SessionAuthenticationProtocol

final class SessionManager: NSObject {
    
    let keyStore: KeyStore
    let alternativeTokenSource: AlternativeTokenSource?
    private let session: URLSession
    let userDomain: UserDomain
    var clientAccessToken: String?
    var userAccessToken: String?

    enum TaskType {
        case data, download, upload(Data)
    }

    init(keyStore: KeyStore = KeychainStore(),
         alternativeTokenSource: AlternativeTokenSource? = nil,
         urlSession: URLSession = .init(configuration: .default),
         userDomain: UserDomain = .default,
         sessionDelegate: URLSessionDelegate? = nil) {
        
        self.keyStore = keyStore
        self.alternativeTokenSource = alternativeTokenSource
        self.session = URLSession.init(configuration: urlSession.configuration, delegate: sessionDelegate, delegateQueue: nil)
        self.userDomain = userDomain
    }
}

// MARK: - SessionProtocol

extension SessionManager: SessionProtocol {

    func data<T: Resource >(resource: T,
                            cancellationToken: CancellationToken?,
                            completion: @escaping CompletionResult<T.ResponseType>) {
        load(resource: resource, taskType: .data, cancellationToken: cancellationToken, completion: completion)
    }
    
    func upload<T: Resource>(resource: T,
                             data: Data,
                             cancellationToken: CancellationToken?,
                             completion: @escaping CompletionResult<T.ResponseType>) {
        load(resource: resource, taskType: .upload(data), cancellationToken: cancellationToken, completion: completion)
    }
    
    func download<T: Resource>(resource: T,
                               cancellationToken: CancellationToken?,
                               completion: @escaping CompletionResult<T.ResponseType>) {
        load(resource: resource, taskType: .download, cancellationToken: cancellationToken, completion: completion)
    }
}

/// Cancellation token needed during the analysis process
public final class CancellationToken {
    internal weak var task: URLSessionTask?
    
    /// Indicates if the analysis has been cancelled
    public var isCancelled = false
    
    public init() {
        
    }
    
    /// Cancels the current task
    public func cancel() {
        isCancelled = true
        task?.cancel()
    }
}

// MARK: - Private

private extension SessionManager {

    func load<T: Resource>(resource: T,
                           taskType: TaskType,
                           cancellationToken: CancellationToken?,
                           completion: @escaping CompletionResult<T.ResponseType>) {
        if let authServiceType = resource.authServiceType {
            var accessToken: String?
            var authType: AuthType?
            switch authServiceType {
                case .apiService:
                    accessToken = self.userAccessToken
                    authType = .bearer
                case .userService(let type):
                    if case .basic = type {
                        accessToken = AuthHelper.encoded(client)
                    } else if case .bearer = type {
                        accessToken = self.clientAccessToken
                    }
                    authType = type
            }

            if let accessToken = accessToken, let header = authType {
                var request = resource.request
                let authHeader = AuthHelper.authorizationHeader(for: accessToken, headerType: header)
                request.addValue(authHeader.value, forHTTPHeaderField: authHeader.key)
                dataTask(for: resource,
                         finalRequest: request,
                         type: taskType,
                         cancellationToken: cancellationToken,
                         completion: completion).resume()
            } else {
                Log("Stored token is no longer valid", event: .warning)
                handleLoginFlow(resource: resource,
                                taskType: taskType,
                                cancellationToken: cancellationToken,
                                completion: completion)
            }

        } else {
            dataTask(for: resource,
                     finalRequest: resource.request,
                     type: taskType,
                     cancellationToken: cancellationToken,
                     completion: completion).resume()
        }
    }
    
    private func dataTask<T: Resource>(for resource: T,
                                       finalRequest request: URLRequest,
                                       type: TaskType,
                                       cancellationToken: CancellationToken?,
                                       completion: @escaping CompletionResult<T.ResponseType>)
        -> URLSessionTask {
            let task: URLSessionTask
            switch type {
            case .data:
                task = session.dataTask(with: request,
                                        completionHandler: taskCompletionHandler(for: resource,
                                                                                 request: request,
                                                                                 taskType: type,
                                                                                 cancellationToken: cancellationToken,
                                                                                 completion: completion))
            case .download:
                task = session
                    .downloadTask(with: request,
                                  completionHandler: downloadTaskCompletionHandler(for: resource,
                                                                                   request: request,
                                                                                   taskType: type,
                                                                                   cancellationToken: cancellationToken,
                                                                                   completion: completion))
            case .upload(let data):
                task = session.uploadTask(with: request,
                                          from: data,
                                          completionHandler: taskCompletionHandler(for: resource,
                                                                                   request: request,
                                                                                   taskType: type,
                                                                                   cancellationToken: cancellationToken,
                                                                                   completion: completion))
                
            }
            
            cancellationToken?.task = task
            return task
    }
    
    // swiftlint:disable function_body_length
    private typealias DataResponseCompletion<T> = (Data?, URLResponse?, Error?) -> Void

    private func taskCompletionHandler<T: Resource>(for resource: T,
                                            request: URLRequest,
                                            taskType: TaskType,
                                            cancellationToken: CancellationToken?,
                                            completion: @escaping CompletionResult<T.ResponseType>) -> DataResponseCompletion<T> {
        return { [weak self] data, response, error in
            guard let self = self else { return }

            if let nsError = error as NSError?,
               nsError.domain == NSURLErrorDomain,
               nsError.code == NSURLErrorNotConnectedToInternet {
                return completion(.failure(.noInternetConnection))
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                return completion(.failure(.noResponse))
            }

            guard !(cancellationToken?.isCancelled ?? false) else {
                completion(.failure(.requestCancelled))
                return
            }

            switch httpResponse.statusCode {
            case 200..<400:
                if let jsonData = data {
                    self.handleSuccess(resource: resource,
                                       request: request,
                                       response: httpResponse,
                                       data: jsonData,
                                       completion: completion)
                } else {
                        completion(.failure(.unknown(response: httpResponse, data: nil)))
                }

            case 400...599:
                self.handleError(resource: resource,
                                 statusCode: httpResponse.statusCode,
                                 response: httpResponse,
                                 data: data,
                                 taskType: taskType,
                                 cancellationToken: cancellationToken,
                                  completion: completion)

            default:
                completion(.failure(.unknown(response: httpResponse, data: data)))
            }
        }
    }

    private func handleSuccess<T: Resource>(resource: T,
                                            request: URLRequest,
                                            response: HTTPURLResponse,
                                            data: Data,
                                            completion: @escaping CompletionResult<T.ResponseType>) {
        do {
            let result = try resource.parsed(response: response, data: data)
            Log("Success: \(request.httpMethod!) - \(request.url!)", event: .success)
            completion(.success(result))
        } catch let error {
            Log("""
                Failure: \(request.httpMethod!) - \(request.url!)
                Parse error: \(error)
                Data content: \(String(data: data, encoding: .utf8) ?? "nil")
                """, event: .error)
            completion(.failure(.parseError(message: "Failed to parse response",
                                            response: response,
                                            data: data))
            )
        }
    }

    private func handleError<T: Resource>(resource: T,
                                          statusCode: Int,
                                          response: HTTPURLResponse?,
                                          data: Data?,
                                          taskType: TaskType,
                                          cancellationToken: CancellationToken?,
                                          completion: @escaping CompletionResult<T.ResponseType>) {
        switch statusCode {
        case 400:
            guard let responseData = data else {
                completion(.failure(.badRequest(response: response, data: nil)))
                return
            }

            guard let errorInfo = try? JSONDecoder().decode([String: String].self, from: responseData),
                errorInfo["error"] == "invalid_grant" else {
                completion(.failure(.badRequest(response: response, data: data)))
                return
            }
            completion(.failure(.unauthorized(response: response, data: data)))
        case 401:
            completion(.failure(.unauthorized(response: response, data: data)))
        case 404:
            completion(.failure(.notFound(response: response, data: data)))
        case 406:
            completion(.failure(.notAcceptable(response: response, data: data)))
        case 429:
            completion(.failure(.tooManyRequests(response: response, data: data)))
        case 503:
            completion(.failure(.maintenance(errorCode: statusCode)))
        case 500:
            completion(.failure(.outage(errorCode: statusCode)))
        case 501, 502, 504...599:
            completion(.failure(.server(errorCode: statusCode)))
        default:
            completion(.failure(.unknown(response: response, data: data)))
        }
    }

    private func downloadTaskCompletionHandler<T: Resource>(for resource: T,
                                                            request: URLRequest,
                                                            taskType: TaskType,
                                                            cancellationToken: CancellationToken?,
                                                            completion: @escaping CompletionResult<T.ResponseType>) -> ((URL?, URLResponse?, Error?) -> Void) {
        return {[weak self] url, response, error in
            guard let self = self else { return }

            self.taskCompletionHandler(for: resource,
                                       request: request,
                                       taskType: taskType,
                                       cancellationToken: cancellationToken,
                                       completion: completion)(Data(url: url), response, error)
        }
    }

    private func handleLoginFlow<T: Resource>(resource: T,
                                              taskType: TaskType,
                                              cancellationToken: CancellationToken?,
                                              completion: @escaping CompletionResult<T.ResponseType>) {
        logIn { result in
            switch result {
                case .success:
                    self.load(resource: resource,
                              taskType: taskType,
                              cancellationToken: cancellationToken,
                              completion: completion)
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
}
