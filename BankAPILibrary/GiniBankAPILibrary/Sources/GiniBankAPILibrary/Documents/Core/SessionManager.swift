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
    
    /// URLSession for network requests. Nil when using custom HTTP client.
    private let session: URLSession?
    
    let userDomain: UserDomain
    var clientAccessToken: String?
    var userAccessToken: String?
    
    /// Custom HTTP client for executing network requests.
    /// When nil, uses default URLSession-based implementation.
    private let httpClient: GiniHTTPClient
    
    /// Flag indicating if custom network provider is being used.
    private let isUsingCustomProvider: Bool

    enum TaskType {
        case data, download, upload(Data)
    }

    init(keyStore: KeyStore = KeychainStore(),
         alternativeTokenSource: AlternativeTokenSource? = nil,
         urlSession: URLSession = .init(configuration: .default),
         userDomain: UserDomain = .default,
         sessionDelegate: URLSessionDelegate? = nil,
         customHTTPClient: GiniHTTPClient? = nil) {
        
        self.keyStore = keyStore
        self.alternativeTokenSource = alternativeTokenSource
        self.userDomain = userDomain
        
        // Use custom client or create default
        if let customClient = customHTTPClient {
            self.httpClient = customClient
            self.isUsingCustomProvider = true
            self.session = nil  // No session needed - customer controls their own
        } else {
            let session = URLSession(configuration: urlSession.configuration,
                                     delegate: sessionDelegate,
                                     delegateQueue: nil)
            self.httpClient = DefaultGiniHTTPClient(session: session)
            self.isUsingCustomProvider = false
            self.session = session
        }
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
                         completion: completion)
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
                     completion: completion)
        }
    }
    
    private func dataTask<T: Resource>(for resource: T,
                                       finalRequest request: URLRequest,
                                       type: TaskType,
                                       cancellationToken: CancellationToken?,
                                       completion: @escaping CompletionResult<T.ResponseType>) {

            // If using custom provider, route through custom client
            if isUsingCustomProvider {
                // Route through custom HTTP client
                switch type {
                case .data:
                    httpClient.dataRequest(request) { [weak self] data, response, error in
                        self?.handleCustomClientResponse(
                            data: data,
                            response: response,
                            error: error,
                            request: request,
                            resource: resource,
                            taskType: type,
                            cancellationToken: cancellationToken,
                            completion: completion
                        )
                    }

                case .upload(let body):
                    httpClient.uploadRequest(request, body: body) { [weak self] data, response, error in
                        self?.handleCustomClientResponse(
                            data: data,
                            response: response,
                            error: error,
                            request: request,
                            resource: resource,
                            taskType: type,
                            cancellationToken: cancellationToken,
                            completion: completion
                        )
                    }

                case .download:
                    httpClient.downloadRequest(request) { [weak self] url, response, error in
                        self?.handleCustomClientDownloadResponse(
                            fileURL: url,
                            response: response,
                            error: error,
                            request: request,
                            resource: resource,
                            taskType: type,
                            cancellationToken: cancellationToken,
                            completion: completion
                        )
                    }
                }

                return
            }

            // Default path: use URLSession directly
            guard let session = session else {
                preconditionFailure("URLSession is nil but custom provider is not being used. This should never happen.")
            }

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
            task.resume()
    }
    
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
    
    // MARK: - Custom HTTP Client Response Handlers
    
    /// Handles data/upload responses from custom HTTP client.
    private func handleCustomClientResponse<T: Resource>(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        request: URLRequest,
        resource: T,
        taskType: TaskType,
        cancellationToken: CancellationToken?,
        completion: @escaping CompletionResult<T.ResponseType>) {
        taskCompletionHandler(
            for: resource,
            request: request,
            taskType: taskType,
            cancellationToken: cancellationToken,
            completion: completion
        )(data, response, error)
    }
    
    /// Handles download responses from custom HTTP client.
    private func handleCustomClientDownloadResponse<T: Resource>(
        fileURL: URL?,
        response: URLResponse?,
        error: Error?,
        request: URLRequest,
        resource: T,
        taskType: TaskType,
        cancellationToken: CancellationToken?,
        completion: @escaping CompletionResult<T.ResponseType>) {
        guard let url = fileURL else {
            completion(.failure(.unknown(response: response as? HTTPURLResponse, data: nil)))
            return
        }

        downloadTaskCompletionHandler(
            for: resource,
            request: request,
            taskType: taskType,
            cancellationToken: cancellationToken,
            completion: completion
        )(url, response, error)
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

