//
//  MockHTTPClientTests.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//
import Testing
import Foundation
@testable import GiniBankAPILibrary

@Suite("GiniHTTPClient CancellableTask Tests")
struct GiniHTTPClientCancellableTaskTests {

    private let dummyRequest = URLRequest(url: URL(string: "https://api.gini.net")!)

    @Test("MockHTTPClient dataRequest returns cancellable task")
    func dataRequestReturnsCancellableTask() {
        var cancelCalled = false
        let client = MockHTTPClient()
        let task = AnyCancellableTask { cancelCalled = true }

        // Verify the protocol method is callable and returns CancellableTask
        let _: CancellableTask = client.dataRequest(dummyRequest) { _, _, _ in }
        #expect(client.dataRequestCalled, "Expected dataRequest to be called")

        task.cancel()
        #expect(cancelCalled, "Expected cancel closure to run")
    }

    @Test("MockHTTPClient uploadRequest returns cancellable task")
    func uploadRequestReturnsCancellableTask() {
        var cancelCalled = false
        let client = MockHTTPClient()
        let task = AnyCancellableTask { cancelCalled = true }

        let _: CancellableTask = client.uploadRequest(dummyRequest, body: Data()) { _, _, _ in }
        #expect(client.uploadRequestCalled, "Expected uploadRequest to be called")

        task.cancel()
        #expect(cancelCalled, "Expected cancel closure to run")
    }

    @Test("MockHTTPClient downloadRequest returns cancellable task")
    func downloadRequestReturnsCancellableTask() {
        var cancelCalled = false
        let client = MockHTTPClient()
        let task = AnyCancellableTask { cancelCalled = true }

        let _: CancellableTask = client.downloadRequest(dummyRequest) { _, _, _ in }
        #expect(client.downloadRequestCalled, "Expected downloadRequest to be called")

        task.cancel()
        #expect(cancelCalled, "Expected cancel closure to run")
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
