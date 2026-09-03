//
//  MockHTTPClientTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//
import Testing
import Foundation
@testable import GiniBankAPILibrary

@Suite("GiniHTTPClient CancellableTask Tests")
struct GiniHTTPClientCancellableTaskTests {

    private var dummyRequest: URLRequest {
        guard let url = URL(string: "https://api.gini.net") else {
            fatalError("Invalid test URL - this should never happen")
        }
        return URLRequest(url: url)
    }

    @Test("MockHTTPClient dataRequest returns cancellable task")
    func dataRequestReturnsCancellableTask() {
        let client = MockHTTPClient()
        // Verify the protocol method is callable and returns CancellableTask
        let task: CancellableTask = client.dataRequest(dummyRequest) { _, _, _ in }
        #expect(client.dataRequestCalled, "Expected dataRequest to be called")
        // Verify that the returned task is cancellable
        task.cancel()
    }
    @Test("MockHTTPClient uploadRequest returns cancellable task")
    func uploadRequestReturnsCancellableTask() {
        let client = MockHTTPClient()
        let task: CancellableTask = client.uploadRequest(dummyRequest, body: Data()) { _, _, _ in }
        #expect(client.uploadRequestCalled, "Expected uploadRequest to be called")
        // Verify that the returned task is cancellable
        task.cancel()
    }
    @Test("MockHTTPClient downloadRequest returns cancellable task")
    func downloadRequestReturnsCancellableTask() {
        let client = MockHTTPClient()
        let task: CancellableTask = client.downloadRequest(dummyRequest) { _, _, _ in }
        #expect(client.downloadRequestCalled, "Expected downloadRequest to be called")
        // Verify that the returned task is cancellable
        task.cancel()
    }

    @Test("Full flow: custom client → CancellationToken")
    func fullFlowCustomClientToCancellationToken() {
        var cancelCalled = false
        let token = CancellationToken()
        let task = AnyCancellableTask { cancelCalled = true }
        token.task = task

        // Simulate what the SDK does: assign task from HTTP client, then cancel via token
        token.cancel()

        #expect(token.isCancelled, "Expected token to be cancelled")
        #expect(cancelCalled, "Expected custom client's cancel closure to be triggered via token")
    }
}
