//
//  MoreInformationViewModelTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
@testable import GiniInternalPaymentSDK

@Suite("MoreInformationViewModel")
struct MoreInformationViewModelTests {

    @Test("tapOnMoreInformation notifies delegate")
    func tapOnMoreInformationNotifiesDelegate() {
        let vm = MoreInformationViewModel(configuration: .test, strings: .test)
        final class MockDelegate: MoreInformationViewProtocol {
            var called = false
            func didTapOnMoreInformation() { called = true }
        }
        let delegate = MockDelegate()
        vm.delegate = delegate
        vm.tapOnMoreInformation()
        #expect(delegate.called == true)
    }

    @Test("tapOnMoreInformation is safe when delegate is nil")
    func tapOnMoreInformationWithNilDelegateDoesNotCrash() {
        let vm = MoreInformationViewModel(configuration: .test, strings: .test)
        vm.tapOnMoreInformation()
    }
}
