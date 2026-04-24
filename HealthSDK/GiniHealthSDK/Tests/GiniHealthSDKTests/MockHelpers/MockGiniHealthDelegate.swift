//
//  MockGiniHealthDelegate.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//
@testable import GiniHealthSDK


final class MockGiniHealthDelegate: GiniHealthDelegate {
    var didDismissHealthSDKCalled = false
    var shouldHandleErrorInternallyReturnValue = false

    func didCreatePaymentRequest(paymentRequestId: String) {}

    func shouldHandleErrorInternally(error: GiniHealthError) -> Bool {
        shouldHandleErrorInternallyReturnValue
    }

    func didDismissHealthSDK() {
        didDismissHealthSDKCalled = true
    }
}
