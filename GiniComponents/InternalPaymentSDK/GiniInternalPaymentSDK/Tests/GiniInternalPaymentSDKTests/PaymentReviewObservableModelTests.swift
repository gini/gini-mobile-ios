//
//  PaymentReviewObservableModelTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import UIKit
import GiniHealthAPILibrary
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
    func didTapPayDoesNotStorePendingInfoForOpenWith() async {
        let delegate = MockPaymentReviewDelegate()
        delegate.supportsOpenWithOverride = true
        let provider = MockBottomSheetsProvider()
        let model = makePaymentReviewModel(delegate: delegate, bottomSheetsProvider: provider)
        let sut = PaymentReviewObservableModel(model: model)

        let paymentInfo = PaymentInfo(recipient: "Test GmbH",
                                      iban: "DE89370400440532013000",
                                      amount: "99.99:EUR",
                                      purpose: "Invoice 123",
                                      paymentUniversalLink: "",
                                      paymentProviderId: "test-provider-id")

        sut.didTapPay(paymentInfo)
        /// The openWith path calls createPaymentRequest directly (no install-sheet).
        #expect(delegate.createPaymentRequestCalled == true,
                "openWith path must call createPaymentRequest immediately")

        /// Reset and verify that resume is a no-op — pendingPaymentInfo was never stored.
        delegate.createPaymentRequestCalled = false
        model.onResumePaymentAfterBankInstall?()
        await Task.yield()
        await Task.yield()

        #expect(delegate.createPaymentRequestCalled == false,
                "onResumePaymentAfterBankInstall must be a no-op for openWith providers — pendingPaymentInfo is never stored on that path")
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

    // MARK: - didTapClose

    @Test("didTapClose calls closePaymentReview which notifies tracking delegate and viewModelDelegate")
    func didTapCloseCallsClosePaymentReview() {
        let delegate = MockPaymentReviewDelegate()
        let provider = MockBottomSheetsProvider()
        let model = makePaymentReviewModel(delegate: delegate, bottomSheetsProvider: provider)
        let vmDelegate = MockPaymentReviewViewModelDelegate()
        model.viewModelDelegate = vmDelegate
        let sut = PaymentReviewObservableModel(model: model)

        sut.didTapClose()

        #expect(delegate.closeButtonClickedCalled == true,
                "didTapClose must call trackOnPaymentReviewCloseButtonClicked on the delegate")
        #expect(vmDelegate.dismissPaymentReviewCalled == true,
                "didTapClose must call dismissPaymentReview on the viewModelDelegate")
    }

    // MARK: - invoiceImageAccessibilityLabel

    @Test("invoiceImageAccessibilityLabel returns the configured string")
    func invoiceImageAccessibilityLabelReturnsConfiguredString() {
        let delegate = MockPaymentReviewDelegate()
        let provider = MockBottomSheetsProvider()
        let model = makePaymentReviewModel(delegate: delegate, bottomSheetsProvider: provider)
        let sut = PaymentReviewObservableModel(model: model)

        #expect(sut.invoiceImageAccessibilityLabel == "Invoice")
    }

    // MARK: - Model bindings

    @Test("onPreviewImagesFetched binding updates cellViewModels on the observable model")
    func onPreviewImagesFetchedUpdatesObservableCellViewModels() async {
        let delegate = MockPaymentReviewDelegate()
        let provider = MockBottomSheetsProvider()
        let model = makePaymentReviewModel(delegate: delegate, bottomSheetsProvider: provider)
        let sut = PaymentReviewObservableModel(model: model)

        let image = UIImage()
        model.cellViewModels = [PageCollectionCellViewModel(preview: image)]
        model.onPreviewImagesFetched?()

        // The binding dispatches to the main actor via a Task — yield to let it run.
        await Task.yield()
        await Task.yield()

        #expect(sut.cellViewModels.count == 1,
                "cellViewModels on the observable model must mirror the underlying model after onPreviewImagesFetched fires")
    }

    @Test("updateLoadingStatus binding updates isLoading on the observable model")
    func updateLoadingStatusUpdatesObservableIsLoading() async {
        let delegate = MockPaymentReviewDelegate()
        let provider = MockBottomSheetsProvider()
        let model = makePaymentReviewModel(delegate: delegate, bottomSheetsProvider: provider)
        let sut = PaymentReviewObservableModel(model: model)

        model.isLoading = true
        await Task.yield()
        await Task.yield()

        #expect(sut.isLoading == true,
                "isLoading on the observable model must mirror the underlying model's isLoading")
    }

    @Test("updateImagesLoadingStatus binding updates isImagesLoading on the observable model")
    func updateImagesLoadingStatusUpdatesObservableIsImagesLoading() async {
        let delegate = MockPaymentReviewDelegate()
        let provider = MockBottomSheetsProvider()
        let model = makePaymentReviewModel(delegate: delegate, bottomSheetsProvider: provider)
        let sut = PaymentReviewObservableModel(model: model)

        model.isImagesLoading = true
        await Task.yield()
        await Task.yield()

        #expect(sut.isImagesLoading == true,
                "isImagesLoading on the observable model must mirror the underlying model's isImagesLoading")
    }

    @Test("onErrorHandling binding presents error alert via viewModelDelegate")
    func onErrorHandlingPresentsErrorAlert() async {
        let delegate = MockPaymentReviewDelegate()
        let provider = MockBottomSheetsProvider()
        let model = makePaymentReviewModel(delegate: delegate, bottomSheetsProvider: provider)
        let vmDelegate = MockPaymentReviewViewModelDelegate()
        model.viewModelDelegate = vmDelegate
        // Keep a strong reference so [weak self] inside the binding closure is not nil.
        let sut = PaymentReviewObservableModel(model: model)
        _ = sut

        model.onErrorHandling?(.unknown())
        await Task.yield()
        await Task.yield()

        #expect(vmDelegate.presentErrorAlertCalled == true,
                "onErrorHandling must present an error alert via viewModelDelegate")
    }

    @Test("onCreatePaymentRequestErrorHandling binding presents payment error alert")
    func onCreatePaymentRequestErrorHandlingPresentsAlert() async {
        let delegate = MockPaymentReviewDelegate()
        let provider = MockBottomSheetsProvider()
        let model = makePaymentReviewModel(delegate: delegate, bottomSheetsProvider: provider)
        let vmDelegate = MockPaymentReviewViewModelDelegate()
        model.viewModelDelegate = vmDelegate
        // Keep a strong reference so [weak self] inside the binding closure is not nil.
        let sut = PaymentReviewObservableModel(model: model)
        _ = sut

        model.onCreatePaymentRequestErrorHandling?()
        await Task.yield()
        await Task.yield()

        #expect(vmDelegate.presentErrorAlertCalled == true,
                "onCreatePaymentRequestErrorHandling must present an error alert with the payment error message")
        #expect(vmDelegate.lastErrorMessage == "Payment error",
                "The error message must match the configured createPaymentErrorMessage")
    }

    // MARK: - validateAmountFieldOnKeyboardDismiss

    @Test("validateAmountFieldOnKeyboardDismiss is safe to call twice without crashing")
    func validateAmountFieldOnKeyboardDismissIsIdempotent() {
        let delegate = MockPaymentReviewDelegate()
        let provider = MockBottomSheetsProvider()
        let model = makePaymentReviewModel(delegate: delegate, bottomSheetsProvider: provider)
        let sut = PaymentReviewObservableModel(model: model)

        sut.validateAmountFieldOnKeyboardDismiss()
        sut.validateAmountFieldOnKeyboardDismiss()
    }
}
