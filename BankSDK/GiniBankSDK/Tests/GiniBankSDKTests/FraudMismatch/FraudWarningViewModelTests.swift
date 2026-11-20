//
//  FraudWarningViewModelTests.swift
//  GiniBankSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import Combine
import Testing
@testable import GiniBankSDK

@Suite("FraudWarningViewModel")
@MainActor
struct FraudWarningViewModelTests {

    private static let qrIBAN = "PL12 1000 0111 0100 1000"
    private static let printedIBAN = "DE89 3704 0044 0532 0130 00"

    @Test("init with nil delegate does not crash")
    func initWithNilDelegate() {
        let viewModel = FraudWarningViewModel(qrIBAN: Self.qrIBAN,
                                              printedIBAN: Self.printedIBAN,
                                              delegate: nil)

        #expect(viewModel.delegate == nil)
    }

    @Test("didTapCancel fires fraudWarningViewModelDidCancel exactly once")
    func didTapCancelFiresOnce() {
        let delegate = Mock()
        let viewModel = FraudWarningViewModel(qrIBAN: Self.qrIBAN,
                                              printedIBAN: Self.printedIBAN,
                                              delegate: delegate)

        viewModel.didTapCancel()

        #expect(delegate.cancelCount == 1)
        #expect(delegate.proceedCount == 0)
    }

    @Test("didTapProceed fires fraudWarningViewModelDidProceed exactly once")
    func didTapProceedFiresOnce() {
        let delegate = Mock()
        let viewModel = FraudWarningViewModel(qrIBAN: Self.qrIBAN,
                                              printedIBAN: Self.printedIBAN,
                                              delegate: delegate)

        viewModel.didTapProceed()

        #expect(delegate.proceedCount == 1)
        #expect(delegate.cancelCount == 0)
    }

    @Test("didTapCancel twice fires the delegate twice")
    func didTapCancelTwiceFiresTwice() {
        let delegate = Mock()
        let viewModel = FraudWarningViewModel(qrIBAN: Self.qrIBAN,
                                              printedIBAN: Self.printedIBAN,
                                              delegate: delegate)

        viewModel.didTapCancel()
        viewModel.didTapCancel()

        #expect(delegate.cancelCount == 2)
    }

    @Test("isExpandedProtectMyself defaults to false")
    func isExpandedProtectMyselfDefaultsToFalse() {
        let viewModel = FraudWarningViewModel(qrIBAN: Self.qrIBAN,
                                              printedIBAN: Self.printedIBAN,
                                              delegate: nil)

        #expect(viewModel.isExpandedProtectMyself == false)
    }

    @Test("isExpandedProtectMyself mutation fires objectWillChange")
    func isExpandedProtectMyselfFiresObjectWillChange() {
        let viewModel = FraudWarningViewModel(qrIBAN: Self.qrIBAN,
                                              printedIBAN: Self.printedIBAN,
                                              delegate: nil)
        var fired = false
        let cancellable = viewModel.objectWillChange.sink { _ in
            fired = true
        }

        viewModel.isExpandedProtectMyself = true

        #expect(fired == true)
        #expect(viewModel.isExpandedProtectMyself == true)
        cancellable.cancel()
    }

    @Test("selectedIBAN defaults to nil")
    func selectedIBANDefaultsToNil() {
        let viewModel = FraudWarningViewModel(qrIBAN: Self.qrIBAN,
                                              printedIBAN: Self.printedIBAN,
                                              delegate: nil)

        #expect(viewModel.selectedIBAN == nil)
    }

    @Test("didConfirmIBAN stores the choice and fires didProceed exactly once")
    func didConfirmIBANStoresAndFires() {
        let delegate = Mock()
        let viewModel = FraudWarningViewModel(qrIBAN: Self.qrIBAN,
                                              printedIBAN: Self.printedIBAN,
                                              delegate: delegate)
        let choice: IBANChoice = .printed(iban: Self.printedIBAN)

        viewModel.didConfirmIBAN(choice)

        #expect(viewModel.selectedIBAN == choice)
        #expect(delegate.proceedCount == 1)
        #expect(delegate.cancelCount == 0)
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
