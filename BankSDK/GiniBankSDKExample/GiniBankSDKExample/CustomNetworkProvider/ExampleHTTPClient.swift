//
//  ExampleHTTPClient.swift
//  GiniBankSDKExample
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import GiniBankAPILibrary

/**
 * Example implementation of custom HTTP client with detailed logging.
 *
 * This demonstrates how to:
 * - Wrap a URLSession in the GiniHTTPClient protocol
 * - Configure secure session settings
 * - Add request/response logging
 *
 * For production use, adapt the logging and security configuration to your needs.
 */
final class ExampleHTTPClient: GiniHTTPClient {
    
    private let session: URLSession
    private let customTimeoutSeconds: Int = 60
    private var requestCounter = 0
    private let counterLock = NSLock()

    init() {
        let config = URLSessionConfiguration.ephemeral
        config.urlCache = nil
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.tlsMinimumSupportedProtocolVersion = .TLSv12
        config.timeoutIntervalForRequest = TimeInterval(customTimeoutSeconds)
        config.timeoutIntervalForResource = 300

        self.session = URLSession(configuration: config)
        
        print("🔧 ExampleHTTPClient initialized")
        print("   - TLS: 1.2+")
        print("   - Caching: Disabled")
    }
    
    // MARK: - GiniHTTPClient Implementation

    @discardableResult
    func dataRequest(_ request: URLRequest,
                     completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> CancellableTask {
        let request = addCustomHeaders(to: request)
        let requestId = nextRequestId()
        logRequestStart(request, type: "DATA", requestId: requestId)
        let startTime = Date()

        let task = session.dataTask(with: request) { data, response, error in
            let duration = Date().timeIntervalSince(startTime)
            self.logResponse(data: data, response: response, error: error, requestId: requestId, duration: duration)
            completion(data, response, error)
        }
        task.resume()
        return task
    }

    @discardableResult
    func uploadRequest(_ request: URLRequest,
                       body: Data,
                       completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> CancellableTask {
        let request = addCustomHeaders(to: request)
        let requestId = nextRequestId()
        logRequestStart(request, type: "UPLOAD", bodySize: body.count, requestId: requestId)
        let startTime = Date()

        let task = session.uploadTask(with: request, from: body) { data, response, error in
            let duration = Date().timeIntervalSince(startTime)
            self.logResponse(data: data, response: response, error: error, requestId: requestId, duration: duration)
            completion(data, response, error)
        }
        task.resume()
        return task
    }

    @discardableResult
    func downloadRequest(_ request: URLRequest,
                         completion: @escaping (URL?, URLResponse?, Error?) -> Void) -> CancellableTask {
        let request = addCustomHeaders(to: request)
        let requestId = nextRequestId()
        logRequestStart(request, type: "DOWNLOAD", requestId: requestId)
        let startTime = Date()

        let task = session.downloadTask(with: request) { url, response, error in
            let duration = Date().timeIntervalSince(startTime)
            if let url = url {
                print("📥 [\(requestId)] Download saved: \(url.lastPathComponent)")
            }
            self.logResponse(data: nil, response: response, error: error, requestId: requestId, duration: duration)
            completion(url, response, error)
        }
        task.resume()
        return task
    }
    
    // MARK: - Custom Headers

    private func addCustomHeaders(to request: URLRequest) -> URLRequest {
        var request = request
        request.setValue("Enabled", forHTTPHeaderField: "X-Custom-HTTP-Client")
        request.setValue("\(customTimeoutSeconds)s", forHTTPHeaderField: "X-Custom-Timeout")
        return request
    }

    // MARK: - Logging
    
    private func nextRequestId() -> Int {
        counterLock.lock()
        defer { counterLock.unlock() }
        requestCounter += 1
        return requestCounter
    }
    
    private func logRequestStart(_ request: URLRequest, type: String, bodySize: Int? = nil, requestId: Int) {
        guard let url = request.url else { return }
        
        let method = request.httpMethod ?? "GET"
        print("\n🌐 [\(requestId)] \(type) Request Started")
        print("Method: \(method)")
        print("URL: \(url.absoluteString)")
        
        // Log headers (Authorization is redacted for security)
        if let headers = request.allHTTPHeaderFields {
            var safeHeaders = headers
            let hasAuth = safeHeaders.removeValue(forKey: "Authorization") != nil
            
            if hasAuth {
                print("🔐 Authorization: [REDACTED - Bearer token present]")
            }
            
            if !safeHeaders.isEmpty {
                for (key, value) in safeHeaders.sorted(by: { $0.key < $1.key }) {
                    print("   \(key): \(value)")
                }
            }
        }
        
        if let size = bodySize {
            print("Body Size: \(ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file))")
        }
    }
    
    private func logResponse(data: Data?, response: URLResponse?, error: Error?, requestId: Int, duration: TimeInterval) {
        if let error = error {
            print("❌ [\(requestId)] Failed after \(String(format: "%.2f", duration))s")
            print("Error: \(error.localizedDescription)")
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("⚠️ [\(requestId)] Invalid response after \(String(format: "%.2f", duration))s")
            return
        }
        
        let statusEmoji = (200...299).contains(httpResponse.statusCode) ? "✅" : "⚠️"
        print("\(statusEmoji) [\(requestId)] Response: \(httpResponse.statusCode) (\(String(format: "%.2f", duration))s)")
    }
}
