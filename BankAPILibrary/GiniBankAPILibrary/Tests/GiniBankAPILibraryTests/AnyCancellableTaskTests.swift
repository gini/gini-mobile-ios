//
//  AnyCancellableTaskTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//
import Testing
import Foundation
@testable import GiniBankAPILibrary

@Suite("AnyCancellableTask Tests")
struct AnyCancellableTaskTests {

    @Test("Cancel closure is called")
    func cancelClosureIsCalled() {
        var cancelCalled = false
        let task = AnyCancellableTask { cancelCalled = true }

        task.cancel()

        #expect(cancelCalled, "Expected cancel closure to be called")
    }

    @Test("Cancel can be called multiple times safely")
    func cancelCanBeCalledMultipleTimes() {
        var cancelCount = 0
        let task = AnyCancellableTask { cancelCount += 1 }

        task.cancel()
        task.cancel()

        #expect(cancelCount == 2, "Expected cancel closure to be called twice")
    }
}
