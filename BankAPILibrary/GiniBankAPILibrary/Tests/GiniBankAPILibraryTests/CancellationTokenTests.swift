//
//  CancellationTokenTests.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//
import Testing
import Foundation
@testable import GiniBankAPILibrary

@Suite("CancellationToken Tests")
struct CancellationTokenTests {

    @Test("isCancelled starts false")
    func isCancelledStartsFalse() {
        let token = CancellationToken()

        #expect(!token.isCancelled, "Expected isCancelled to start as false")
    }

    @Test("Cancel sets isCancelled to true")
    func cancelSetsIsCancelled() {
        let token = CancellationToken()

        token.cancel()

        #expect(token.isCancelled, "Expected isCancelled to be true after cancel()")
    }

    @Test("Cancel calls task.cancel()")
    func cancelCallsTaskCancel() {
        var taskCancelCalled = false
        let task = AnyCancellableTask { taskCancelCalled = true }
        let token = CancellationToken()
        token.task = task

        token.cancel()

        #expect(taskCancelCalled, "Expected task cancel closure to be called")
        #expect(token.isCancelled, "Expected isCancelled to be true")
    }

    @Test("Cancel with nil task doesn't crash")
    func cancelWithNilTaskDoesNotCrash() {
        let token = CancellationToken()

        token.cancel()

        #expect(token.isCancelled, "Expected isCancelled to be true even without a task")
    }
}
