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

        #expect(sut.isBottomSheetMode == true, "isBottomSheetMode must be true when document is nil")
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
        #expect(sut.keyboardDoneButtonTitle == "Done", "keyboardDoneButtonTitle must return the default configured string")
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

        #expect(sut.keyboardDoneButtonTitle == "Fertig", "keyboardDoneButtonTitle must reflect the custom configured value")
    }

    @Test("isAmountFieldFocused defaults to false")
    func isAmountFieldFocusedDefaultsFalse() {
        let delegate = MockPaymentReviewDelegate()
        let provider = MockBottomSheetsProvider()
        let model = makePaymentReviewModel(delegate: delegate, bottomSheetsProvider: provider)
        let sut = PaymentReviewObservableModel(model: model)

        #expect(sut.isAmountFieldFocused == false, "isAmountFieldFocused must default to false on model initialisation")
    }

    @Test("trackKeyboardDismissed notifies the delegate")
    func trackKeyboardDismissedNotifiesDelegate() {
        let delegate = MockPaymentReviewDelegate()
        let provider = MockBottomSheetsProvider()
        let model = makePaymentReviewModel(delegate: delegate, bottomSheetsProvider: provider)
        let sut = PaymentReviewObservableModel(model: model)

        sut.trackKeyboardDismissed()

        #expect(delegate.closeKeyboardClickedCalled == true, "trackKeyboardDismissed must notify the delegate by calling closeKeyboardClicked")
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

    // MARK: - Install-app / pending payment flow (HEAL-352)

    @Test("didTapPay stores paymentInfo when GPC bank is not installed")
    func didTapPayStoresPendingPaymentInfoWhenBankNotInstalled() {
        let delegate = MockPaymentReviewDelegate()
        delegate.supportsGPCOverride = true
        let provider = MockBottomSheetsProvider()
        let model = makePaymentReviewModel(delegate: delegate, bottomSheetsProvider: provider)
        let sut = PaymentReviewObservableModel(model: model)

        let paymentInfo = PaymentInfo(recipient: "Test GmbH",
                                      iban: "DE89370400440532013000",
                                      bic: "",
                                      amount: "99.99:EUR",
                                      purpose: "Invoice 123",
                                      paymentUniversalLink: "",
                                      paymentProviderId: "test-provider-id")

        /// In the test environment `canOpenURLString()` always returns false (no real app scheme
        /// registered), so the install-sheet path is always taken for GPC providers.
        sut.didTapPay(paymentInfo)

        /// Verify via the resume path: triggering `onResumePaymentAfterBankInstall` must
        /// call `createPaymentRequest` with the stored paymentInfo.
        model.onResumePaymentAfterBankInstall?()

        #expect(delegate.createPaymentRequestCalled == true,
                "createPaymentRequest must be called after resuming payment following bank install")
        #expect(delegate.lastPaymentInfo?.recipient == "Test GmbH",
                "createPaymentRequest must be called with the paymentInfo that was stored before opening the install sheet")
    }

    @Test("onResumePaymentAfterBankInstall clears pendingPaymentInfo after first resume")
    func resumePaymentClearsPendingInfoAfterFirstCall() {
        let delegate = MockPaymentReviewDelegate()
        delegate.supportsGPCOverride = true
        let provider = MockBottomSheetsProvider()
        let model = makePaymentReviewModel(delegate: delegate, bottomSheetsProvider: provider)
        let sut = PaymentReviewObservableModel(model: model)

        let paymentInfo = PaymentInfo(recipient: "Test GmbH",
                                      iban: "DE89370400440532013000",
                                      bic: "",
                                      amount: "99.99:EUR",
                                      purpose: "Invoice 123",
                                      paymentUniversalLink: "",
                                      paymentProviderId: "test-provider-id")

        sut.didTapPay(paymentInfo)
        model.onResumePaymentAfterBankInstall?()
        /// Reset tracking and call resume again — the pending info was already consumed.
        delegate.createPaymentRequestCalled = false
        model.onResumePaymentAfterBankInstall?()

        #expect(delegate.createPaymentRequestCalled == false,
                "A second resume call must be a no-op once pendingPaymentInfo has been consumed")
    }

    @Test("onResumePaymentAfterBankInstall is a no-op when no payment is pending")
    func resumePaymentIsNoOpWithoutPendingInfo() {
        let delegate = MockPaymentReviewDelegate()
        delegate.supportsGPCOverride = true
        let provider = MockBottomSheetsProvider()
        let model = makePaymentReviewModel(delegate: delegate, bottomSheetsProvider: provider)
        _ = PaymentReviewObservableModel(model: model)

        model.onResumePaymentAfterBankInstall?()

        #expect(delegate.createPaymentRequestCalled == false,
                "onResumePaymentAfterBankInstall must not call createPaymentRequest when no payment is pending")
    }

    @Test("didTapPay does not store pendingPaymentInfo for openWith providers")
    func didTapPayDoesNotStorePendingInfoForOpenWith() {
        let delegate = MockPaymentReviewDelegate()
        delegate.supportsOpenWithOverride = true
        let provider = MockBottomSheetsProvider()
        let model = makePaymentReviewModel(delegate: delegate, bottomSheetsProvider: provider)
        let sut = PaymentReviewObservableModel(model: model)

        let paymentInfo = PaymentInfo(recipient: "Test GmbH",
                                      iban: "DE89370400440532013000",
                                      bic: "",
                                      amount: "99.99:EUR",
                                      purpose: "Invoice 123",
                                      paymentUniversalLink: "",
                                      paymentProviderId: "test-provider-id")

        sut.didTapPay(paymentInfo)
        /// Resume must be a no-op: the openWith path does not use the install-sheet flow
        /// and therefore never stores pendingPaymentInfo.
        model.onResumePaymentAfterBankInstall?()

        #expect(delegate.createPaymentRequestCalled == false,
                "pendingPaymentInfo must not be set for openWith providers — they do not use the install-sheet path")
    }

    @Test("resumePaymentAfterBankInstall opens the payment provider app after request is created")
    func resumePaymentOpensProviderApp() async {
        let delegate = MockPaymentReviewDelegate()
        delegate.supportsGPCOverride = true
        let provider = MockBottomSheetsProvider()
        let model = makePaymentReviewModel(delegate: delegate, bottomSheetsProvider: provider)
        let sut = PaymentReviewObservableModel(model: model)

        let paymentInfo = PaymentInfo(recipient: "Test GmbH",
                                      iban: "DE89370400440532013000",
                                      bic: "",
                                      amount: "99.99:EUR",
                                      purpose: "Invoice 123",
                                      paymentUniversalLink: "https://testbank.example/pay",
                                      paymentProviderId: "test-provider-id")

        sut.didTapPay(paymentInfo)
        model.onResumePaymentAfterBankInstall?()

        /// `PaymentReviewModel.createPaymentRequest` dispatches its completion via
        /// `DispatchQueue.main.async`. Yielding twice lets the main actor executor
        /// drain that work before we assert.
        await Task.yield()
        await Task.yield()

        #expect(delegate.openPaymentProviderAppCalled == true,
                "resumePaymentAfterBankInstall must open the payment provider app once the request is created")
    }

    @Test("PaymentReviewModel.didTapOnContinue triggers createPaymentRequestAndOpenBankApp on its delegate")
    func didTapOnContinueNotifiesViewModelDelegate() {
        let delegate = MockPaymentReviewDelegate()
        let provider = MockBottomSheetsProvider()
        let model = makePaymentReviewModel(delegate: delegate, bottomSheetsProvider: provider)
        let vmDelegate = MockPaymentReviewViewModelDelegate()
        model.viewModelDelegate = vmDelegate

        model.didTapOnContinue()

        #expect(vmDelegate.createPaymentRequestAndOpenBankAppCalled == true,
                "didTapOnContinue must forward to createPaymentRequestAndOpenBankApp on the viewModelDelegate")
    }
}