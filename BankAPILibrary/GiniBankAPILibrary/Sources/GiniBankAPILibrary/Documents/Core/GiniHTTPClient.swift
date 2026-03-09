//
//  GiniHTTPClient.swift
//  GiniBankAPI
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation

// MARK: - CancellableTask

/**
 * A handle to an in-flight network request that can be cancelled.
 *
 * The SDK uses this to cancel requests regardless of the underlying
 * networking library (URLSession, Alamofire, etc.).
 */
public protocol CancellableTask: AnyObject {
    /// Cancels the in-flight request.
    func cancel()
}

/**
 * Type-erasing wrapper for `CancellableTask`.
 *
 * Use this when you need to create a `CancellableTask` from a cancel closure,
 * for example when wrapping a third-party networking library.
 *
 * ```swift
 * let task = AnyCancellableTask { myCustomRequest.abort() }
 * ```
 */
public final class AnyCancellableTask: CancellableTask {
    private let _cancel: () -> Void

    public init(_ cancel: @escaping () -> Void) {
        self._cancel = cancel
    }

    public func cancel() {
        _cancel()
    }
}

extension URLSessionTask: CancellableTask {}

// MARK: - GiniHTTPClient Protocol

/**
 * Protocol for executing HTTP requests on behalf of the Gini SDK.
 *
 * Your implementation receives complete URLRequest objects including OAuth tokens
 * in the Authorization header. You have full control over URLSession configuration,
 * proxy settings, TLS, and logging.
 *
 * - Important: When you provide a custom HTTP client, the SDK's default security
 *   mechanisms — including SSL certificate pinning configured via `sessionDelegate` —
 *   are bypassed entirely. You are responsible for implementing proper TLS configuration
 *   and certificate validation in your own `URLSession` setup.
 *
 * # Example Implementation
 *
 * ```swift
 * final class MyHTTPClient: GiniHTTPClient {
 *     private let session: URLSession
 *
 *     init() {
 *         let config = URLSessionConfiguration.default
 *         config.tlsMinimumSupportedProtocolVersion = .TLSv12
 *         self.session = URLSession(configuration: config)
 *     }
 *
 *     @discardableResult
 *     func dataRequest(_ request: URLRequest,
 *                     completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> CancellableTask {
 *         let task = session.dataTask(with: request, completionHandler: completion)
 *         task.resume()
 *         return task
 *     }
 *
 *     // ... implement other methods
 * }
 * ```
 */
public protocol GiniHTTPClient {

    /**
     * Executes a data request and returns the response via completion handler.
     *
     * - Parameters:
     *   - request: The URLRequest to execute (includes OAuth token in Authorization header)
     *   - completion: Called when request completes with data, response, and error
     * - Returns: A `CancellableTask` that can be used to cancel the in-flight request.
     */
    @discardableResult
    func dataRequest(_ request: URLRequest,
                     completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> CancellableTask

    /**
     * Executes an upload request with a body and returns the response via completion handler.
     *
     * - Parameters:
     *   - request: The URLRequest to execute (includes OAuth token in Authorization header)
     *   - body: The data to upload in the request body
     *   - completion: Called when request completes with data, response, and error
     * - Returns: A `CancellableTask` that can be used to cancel the in-flight request.
     */
    @discardableResult
    func uploadRequest(_ request: URLRequest,
                       body: Data,
                       completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> CancellableTask

    /**
     * Executes a download request and returns the file URL via completion handler.
     *
     * - Parameters:
     *   - request: The URLRequest to execute (includes OAuth token in Authorization header)
     *   - completion: Called when request completes with file URL, response, and error
     * - Returns: A `CancellableTask` that can be used to cancel the in-flight request.
     */
    @discardableResult
    func downloadRequest(_ request: URLRequest,
                         completion: @escaping (URL?, URLResponse?, Error?) -> Void) -> CancellableTask
}

// MARK: - GiniNetworkProvider Protocol

/**
 * Protocol for providing a custom HTTP client to the Gini SDK.
 *
 * # Example
 *
 * ```swift
 * final class CustomNetworkProvider: GiniNetworkProvider {
 *     private let client: GiniHTTPClient
 *
 *     init(client: GiniHTTPClient) {
 *         self.client = client
 *     }
 *
 *     func httpClient() -> GiniHTTPClient {
 *         return client
 *     }
 * }
 *
 * // Usage
 * let configuration = GiniBankConfiguration.shared
 * configuration.customNetworkProvider = CustomNetworkProvider(
 *     client: MyHTTPClient()
 * )
 * ```
 */
public protocol GiniNetworkProvider {

    /**
     * Returns the HTTP client to use for all Gini SDK network requests.
     *
     * This method is called once during `GiniBankAPI.Builder.build()`.
     * The returned client instance will be reused for all subsequent requests
     * throughout the lifetime of the GiniBankAPI instance.
     *
     * - Returns: An instance conforming to `GiniHTTPClient` that will execute all HTTP requests.
     */
    func httpClient() -> GiniHTTPClient
}

// MARK: - DefaultGiniHTTPClient

/**
 * Default HTTP client implementation using the SDK's secure URLSession.
 *
 * This implementation maintains all SDK security guarantees:
 * - SSL certificate pinning (when session delegate is provided)
 * - Proper OAuth token handling
 * - Request/response integrity
 *
 * Used automatically when no custom network provider is configured.
 */
final class DefaultGiniHTTPClient: GiniHTTPClient {

    private let session: URLSession

    /**
     * Initializes the default HTTP client with a URLSession.
     *
     * - Parameter session: The URLSession to use for network requests.
     *                      Should be configured with proper security settings and delegate.
     */
    init(session: URLSession) {
        self.session = session
    }

    @discardableResult
    func dataRequest(_ request: URLRequest,
                     completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> CancellableTask {
        let task = session.dataTask(with: request, completionHandler: completion)
        task.resume()
        return task
    }

    @discardableResult
    func uploadRequest(_ request: URLRequest,
                       body: Data,
                       completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> CancellableTask {
        let task = session.uploadTask(with: request, from: body, completionHandler: completion)
        task.resume()
        return task
    }

    @discardableResult
    func downloadRequest(_ request: URLRequest,
                         completion: @escaping (URL?, URLResponse?, Error?) -> Void) -> CancellableTask {
        let task = session.downloadTask(with: request, completionHandler: completion)
        task.resume()
        return task
    }
}
