//
//  MockPaymentComponentsDelegate.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//
@testable import GiniHealthSDK


final class MockPaymentComponentsDelegate: PaymentComponentsControllerProtocol {
    var isLoadingStateChangedCalled = false
    var lastLoadingState: Bool?
    var didFetchedPaymentProvidersCalled = false
    var didDismissPaymentComponentsCalled = false

    func isLoadingStateChanged(isLoading: Bool) {
        isLoadingStateChangedCalled = true
        lastLoadingState = isLoading
    }

    func didFetchedPaymentProviders() {
        didFetchedPaymentProvidersCalled = true
    }

    func didDismissPaymentComponents() {
        didDismissPaymentComponentsCalled = true
    }
}
