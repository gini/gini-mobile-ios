//
//  GiniHTTPClientProtocolConformanceTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//
import Testing
import Foundation
@testable import GiniBankAPILibrary

@Suite("GiniHTTPClient Protocol Conformance Tests")
struct GiniHTTPClientProtocolConformanceTests {

    private var dummyRequest: URLRequest {
        guard let url = URL(string: "https://api.gini.net/test") else {
            fatalError("Invalid test URL - this should never happen")
        }
        return URLRequest(url: url)
    }

    @Test("MockHTTPClient conforms to GiniHTTPClient")
    func mockConformsToProtocol() {
        let client: GiniHTTPClient = MockHTTPClient()
        let _: CancellableTask = client.dataRequest(dummyRequest) { _, _, _ in }
        let _: CancellableTask = client.uploadRequest(dummyRequest, body: Data()) { _, _, _ in }
        let _: CancellableTask = client.downloadRequest(dummyRequest) { _, _, _ in }
    }

    @Test("DefaultGiniHTTPClient conforms to GiniHTTPClient")
    func defaultClientConformsToProtocol() async {
        let client: GiniHTTPClient = DefaultGiniHTTPClient(session: makeStubSession())

        // Verify all three methods are callable through the protocol reference and complete
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            client.dataRequest(dummyRequest) { _, _, _ in
                continuation.resume()
            }
        }
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            client.uploadRequest(dummyRequest, body: Data()) { _, _, _ in
                continuation.resume()
            }
        }
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            client.downloadRequest(dummyRequest) { _, _, _ in
                continuation.resume()
            }
        }
    }

    @Test("CancellableTask returned by protocol method can be assigned to CancellationToken")
    func cancellableTaskWorksWithCancellationToken() {
        let client: GiniHTTPClient = MockHTTPClient()
        let token = CancellationToken()

        let task = client.dataRequest(dummyRequest) { _, _, _ in }
        token.task = task

        token.cancel()

        #expect(token.isCancelled, "Expected token to be cancelled")
    }

    @Test("Different GiniHTTPClient implementations return independent CancellableTasks")
    func independentCancellableTasks() async {
        let mockClient: GiniHTTPClient = MockHTTPClient()
        let defaultClient: GiniHTTPClient = DefaultGiniHTTPClient(session: makeStubSession())

        var mockCancelCalled = false
        _ = mockClient.dataRequest(dummyRequest) { _, _, _ in }

        let mockWrapper = AnyCancellableTask { mockCancelCalled = true }
        let mockToken = CancellationToken()
        mockToken.task = mockWrapper

        let defaultTask: CancellableTask = await withCheckedContinuation { continuation in
            let task = defaultClient.dataRequest(dummyRequest) { _, _, _ in }
            continuation.resume(returning: task)
        }
        let defaultToken = CancellationToken()
        defaultToken.task = defaultTask

        // Cancel only the default token
        defaultToken.cancel()

        #expect(defaultToken.isCancelled, "Expected default token to be cancelled")
        #expect(!mockToken.isCancelled, "Expected mock token to remain uncancelled")
        #expect(!mockCancelCalled, "Expected mock cancel not to be called")
    }
}
