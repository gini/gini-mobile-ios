//
//  PaymentReviewObservableModelTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
@testable import GiniInternalPaymentSDK

@Suite("PaymentReviewObservableModel")
@MainActor
struct PaymentReviewObservableModelTests {

    @Test("isBottomSheetMode is true when document is nil")
    func bottomSheetModeWithNoDocument() {
        let delegate = MockPaymentReviewDelegate()
        let provider = MockBottomSheetsProvider()
        let model = makePaymentReviewModel(delegate: delegate, bottomSheetsProvider: provider)
        let sut = PaymentReviewObservableModel(model: model)

        #expect(sut.isBottomSheetMode == true)
    }

    @Test("keyboardDoneButtonTitle returns the configured string")
    func keyboardDoneButtonTitleIsConfigured() {
        let delegate = MockPaymentReviewDelegate()
        let provider = MockBottomSheetsProvider()
        let model = makePaymentReviewModel(delegate: delegate,
                                          bottomSheetsProvider: provider,
                                          displayMode: .bottomSheet)
        let sut = PaymentReviewObservableModel(model: model)

        // The default .test(keyboardDoneButtonTitle:) uses "Done"
        #expect(sut.keyboardDoneButtonTitle == "Done")
    }

    @Test("keyboardDoneButtonTitle reflects custom configured value")
    func keyboardDoneButtonTitleCustomValue() {
        let delegate = MockPaymentReviewDelegate()
        let provider = MockBottomSheetsProvider()
        let model = PaymentReviewModel(delegate: delegate,
                                       bottomSheetsProvider: provider,
                                       document: nil,
                                       extractions: nil,
                                       paymentInfo: nil,
                                       selectedPaymentProvider: .test,
                                       configuration: .test,
                                       strings: .test,
                                       containerConfiguration: .test,
                                       containerStrings: .test(keyboardDoneButtonTitle: "Fertig"),
                                       defaultStyleInputFieldConfiguration: .test,
                                       errorStyleInputFieldConfiguration: .test,
                                       selectionStyleInputFieldConfiguration: .test,
                                       primaryButtonConfiguration: .test,
                                       secondaryButtonConfiguration: .test,
                                       poweredByGiniConfiguration: .test,
                                       poweredByGiniStrings: .test,
                                       bottomSheetConfiguration: .test,
                                       showPaymentReviewCloseButton: true,
                                       previousPaymentComponentScreenType: nil,
                                       clientConfiguration: nil)
        let sut = PaymentReviewObservableModel(model: model)

        #expect(sut.keyboardDoneButtonTitle == "Fertig")
    }

    @Test("isAmountFieldFocused defaults to false")
    func isAmountFieldFocusedDefaultsFalse() {
        let delegate = MockPaymentReviewDelegate()
        let provider = MockBottomSheetsProvider()
        let model = makePaymentReviewModel(delegate: delegate, bottomSheetsProvider: provider)
        let sut = PaymentReviewObservableModel(model: model)

        #expect(sut.isAmountFieldFocused == false)
    }

    @Test("trackKeyboardDismissed notifies the delegate")
    func trackKeyboardDismissedNotifiesDelegate() {
        let delegate = MockPaymentReviewDelegate()
        let provider = MockBottomSheetsProvider()
        let model = makePaymentReviewModel(delegate: delegate, bottomSheetsProvider: provider)
        let sut = PaymentReviewObservableModel(model: model)

        sut.trackKeyboardDismissed()

        #expect(delegate.closeKeyboardClickedCalled == true)
    }

    @Test("dismissBannerAfterDelay does not throw and is safe to call twice")
    func dismissBannerAfterDelayIsSafeToCallTwice() {
        let delegate = MockPaymentReviewDelegate()
        let provider = MockBottomSheetsProvider()
        let model = makePaymentReviewModel(delegate: delegate, bottomSheetsProvider: provider)
        let sut = PaymentReviewObservableModel(model: model)

        sut.dismissBannerAfterDelay()
        sut.dismissBannerAfterDelay()
    }
}
