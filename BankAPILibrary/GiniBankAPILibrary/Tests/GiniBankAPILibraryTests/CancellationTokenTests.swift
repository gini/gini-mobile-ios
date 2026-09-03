//
//  CancellationTokenTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
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
    
    @Test("Task reference is weak to prevent retain cycles")
    func taskReferenceIsWeak() {
        let token = CancellationToken()
        
        // Create task in a scope so it can be deallocated
        do {
            let task = AnyCancellableTask { /* noop */ }
            token.task = task
            #expect(token.task != nil, "Task should be set")
        }
        
        // After task goes out of scope and is deallocated,
        // the weak reference should become nil
        #expect(token.task == nil, "Task reference should be nil after task is deallocated (proving weak reference)")
    }
}
