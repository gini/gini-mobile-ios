//
//  SessionManager.swift
//  GiniBankAPI
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
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
        // This initializer is intentionally left empty because no custom setup is required at initialization.
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
        guard var request = resource.request else {
            completion(.failure(.unknown(response: nil, data: nil)))
            return
        }
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
                     finalRequest: request,
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

    private typealias DataResponseCompletion<T> = (Data?, URLResponse?, Error?) -> Void

    private func taskCompletionHandler<T: Resource>(for resource: T,
                                                    request: URLRequest,
                                                    taskType: TaskType,
                                                    cancellationToken: CancellationToken?,
                                                    completion: @escaping CompletionResult<T.ResponseType>) -> DataResponseCompletion<T> {
        return { [weak self] data, response, error in
            guard let self = self else { return }

            if handleNetworkError(error, completion: completion) {
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                return completion(.failure(.noResponse))
            }

            guard !(cancellationToken?.isCancelled ?? false) else {
                completion(.failure(.requestCancelled))
                return
            }

            self.handleResponse(for: resource,
                               request: request,
                               response: httpResponse,
                               data: data,
                               taskType: taskType,
                               cancellationToken: cancellationToken,
                               completion: completion)
        }
    }

    private func handleNetworkError<T>(_ error: Error?,
                                       completion: @escaping CompletionResult<T>) -> Bool {
        guard let nsError = error as NSError?,
              nsError.domain == NSURLErrorDomain,
              nsError.code == NSURLErrorNotConnectedToInternet else {
            return false
        }

        completion(.failure(.noInternetConnection))
        return true
    }

    private func handleResponse<T: Resource>(for resource: T,
                                             request: URLRequest,
                                             response: HTTPURLResponse,
                                             data: Data?,
                                             taskType: TaskType,
                                             cancellationToken: CancellationToken?,
                                             completion: @escaping CompletionResult<T.ResponseType>) {
        switch response.statusCode {
        case 200..<400:
            guard let jsonData = data else {
                completion(.failure(.unknown(response: response, data: nil)))
                return
            }
            handleSuccess(resource: resource,
                          request: request,
                          response: response,
                          data: jsonData,
                          completion: completion)

        case 400...599:
            handleError(resource: resource,
                        statusCode: response.statusCode,
                        response: response,
                        data: data,
                        taskType: taskType,
                        cancellationToken: cancellationToken,
                        completion: completion)

        default:
            completion(.failure(.unknown(response: response, data: data)))
        }
    }
    private func handleSuccess<T: Resource>(resource: T,
                                            request: URLRequest,
                                            response: HTTPURLResponse,
                                            data: Data,
                                            completion: @escaping CompletionResult<T.ResponseType>) {
        let method = request.httpMethod ?? "unknown method"
        let url = request.url?.absoluteString ?? "unknown URL"
        let dataString = String(data: data, encoding: .utf8) ?? "nil"

        do {
            let result = try resource.parsed(response: response, data: data)
            Log("Success: \(method) - \(url)", event: .success)
            completion(.success(result))
        } catch let error {
            Log("""
                Failure: \(method) - \(url)
                Parse error: \(error)
                Data content: \(dataString)
                """, event: .error)
            completion(.failure(.parseError(message: "Failed to parse response",
                                            response: response,
                                            data: data)))
        }
    }

    private func handleError<T: Resource>(resource: T,
                                          statusCode: Int,
                                          response: HTTPURLResponse?,
                                          data: Data?,
                                          taskType: TaskType,
                                          cancellationToken: CancellationToken?,
                                          completion: @escaping CompletionResult<T.ResponseType>) {
        let error = GiniError.from(statusCode: statusCode, response: response, data: data)
        completion(.failure(error))
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
