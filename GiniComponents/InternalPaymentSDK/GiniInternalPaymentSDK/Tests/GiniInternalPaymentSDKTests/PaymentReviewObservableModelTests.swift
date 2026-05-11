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
}
