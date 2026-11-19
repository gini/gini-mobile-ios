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

    private static let stubQRIBAN = "PL12 1000 0111 0100 1000"
    private static let stubPrintedIBAN = "DE89 3704 0044 0532 0130 00"

    @Test("init with nil delegate does not crash")
    func initWithNilDelegate() {
        let viewModel = FraudWarningViewModel(qrIBAN: Self.stubQRIBAN,
                                              printedIBAN: Self.stubPrintedIBAN,
                                              delegate: nil)

        #expect(viewModel.delegate == nil)
    }

    @Test("init stores qrIBAN")
    func initStoresQRIBAN() {
        let viewModel = FraudWarningViewModel(qrIBAN: Self.stubQRIBAN,
                                              printedIBAN: Self.stubPrintedIBAN,
                                              delegate: nil)

        #expect(viewModel.qrIBAN == Self.stubQRIBAN)
    }

    @Test("init stores printedIBAN")
    func initStoresPrintedIBAN() {
        let viewModel = FraudWarningViewModel(qrIBAN: Self.stubQRIBAN,
                                              printedIBAN: Self.stubPrintedIBAN,
                                              delegate: nil)

        #expect(viewModel.printedIBAN == Self.stubPrintedIBAN)
    }

    @Test("isExpandedProtectMyself defaults to false and mutates on assignment")
    func isExpandedProtectMyselfTogglesCleanly() {
        let viewModel = FraudWarningViewModel(qrIBAN: Self.stubQRIBAN,
                                              printedIBAN: Self.stubPrintedIBAN,
                                              delegate: nil)

        #expect(viewModel.isExpandedProtectMyself == false)

        viewModel.isExpandedProtectMyself = true
        #expect(viewModel.isExpandedProtectMyself == true)

        viewModel.isExpandedProtectMyself = false
        #expect(viewModel.isExpandedProtectMyself == false)
    }

    @Test("didTapCancel fires fraudWarningViewModelDidCancel exactly once")
    func didTapCancelFiresOnce() {
        let delegate = Mock()
        let viewModel = FraudWarningViewModel(qrIBAN: Self.stubQRIBAN,
                                              printedIBAN: Self.stubPrintedIBAN,
                                              delegate: delegate)

        viewModel.didTapCancel()

        #expect(delegate.cancelCount == 1)
        #expect(delegate.proceedCount == 0)
    }

    @Test("didTapProceed fires fraudWarningViewModelDidProceed exactly once")
    func didTapProceedFiresOnce() {
        let delegate = Mock()
        let viewModel = FraudWarningViewModel(qrIBAN: Self.stubQRIBAN,
                                              printedIBAN: Self.stubPrintedIBAN,
                                              delegate: delegate)

        viewModel.didTapProceed()

        #expect(delegate.proceedCount == 1)
        #expect(delegate.cancelCount == 0)
    }

    @Test("didTapCancel twice fires the delegate twice")
    func didTapCancelTwiceFiresTwice() {
        let delegate = Mock()
        let viewModel = FraudWarningViewModel(qrIBAN: Self.stubQRIBAN,
                                              printedIBAN: Self.stubPrintedIBAN,
                                              delegate: delegate)

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
