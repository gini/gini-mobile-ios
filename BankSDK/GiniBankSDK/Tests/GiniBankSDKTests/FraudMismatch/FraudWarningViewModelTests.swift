//
//  FraudWarningViewModelTests.swift
//  GiniBankSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import Testing
@testable import GiniBankSDK

@Suite("FraudWarningViewModel")
@MainActor
struct FraudWarningViewModelTests {

    @Test("init with nil delegate does not crash")
    func initWithNilDelegate() {
        let viewModel = FraudWarningViewModel(delegate: nil)

        #expect(viewModel.delegate == nil)
    }

    @Test("didTapCancel fires fraudWarningViewModelDidCancel exactly once")
    func didTapCancelFiresOnce() {
        let delegate = Mock()
        let viewModel = FraudWarningViewModel(delegate: delegate)

        viewModel.didTapCancel()

        #expect(delegate.cancelCount == 1)
        #expect(delegate.proceedCount == 0)
    }

    @Test("didTapProceed fires fraudWarningViewModelDidProceed exactly once")
    func didTapProceedFiresOnce() {
        let delegate = Mock()
        let viewModel = FraudWarningViewModel(delegate: delegate)

        viewModel.didTapProceed()

        #expect(delegate.proceedCount == 1)
        #expect(delegate.cancelCount == 0)
    }

    @Test("didTapCancel twice fires the delegate twice")
    func didTapCancelTwiceFiresTwice() {
        let delegate = Mock()
        let viewModel = FraudWarningViewModel(delegate: delegate)

        viewModel.didTapCancel()
        viewModel.didTapCancel()

        #expect(delegate.cancelCount == 2)
    }
}

private final class Mock: FraudWarningViewModelDelegate {
    var cancelCount = 0
    var proceedCount = 0

    func fraudWarningViewModelDidCancel(_ viewModel: FraudWarningViewModel) {
        cancelCount += 1
    }

    func fraudWarningViewModelDidProceed(_ viewModel: FraudWarningViewModel) {
        proceedCount += 1
    }
}
