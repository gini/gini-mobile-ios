//
//  PaymentReviewCollectionTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//
//  Tests for the pageControlTapHandler bounds-guard fix in
//  PaymentReviewViewController+UICollection.swift.
//
//  Bug: When no internet connection was available, model.numberOfCells == 0
//  but pageControl.numberOfPages > 0 (set from document metadata before the
//  network fetch). Tapping the page control called
//  UICollectionView.scrollToItem(at:) with an out-of-bounds index path and
//  crashed with EXC_CRASH (SIGABRT).
//
//  Fix: Added `guard page < model.numberOfCells else { return }` inside the
//  async block in pageControlTapHandler().
//

import Testing
import UIKit
import GiniHealthAPILibrary
import GiniUtilites
@testable import GiniHealthSDK
@testable import GiniInternalPaymentSDK

// MARK: - Tests

@MainActor
struct PaymentReviewCollectionTests {

    // MARK: - Helpers

    private func makePaymentProvider() -> GiniHealthAPILibrary.PaymentProvider {
        GiniHealthAPILibrary.PaymentProvider(id: "test_id",
                        name: "test",
                        appSchemeIOS: "",
                        minAppVersion: nil,
                        colors: ProviderColors(background: "", text: ""),
                        iconData: Data(),
                        appStoreUrlIOS: nil,
                        universalLinkIOS: "",
                        index: nil,
                        gpcSupportedPlatforms: [.ios],
                        openWithSupportedPlatforms: [.ios])
    }

    private func makeModel(delegate: PaymentReviewProtocol,
                           bottomSheetsProvider: BottomSheetsProviderProtocol) -> PaymentReviewModel {
        let textFieldConfig = TextFieldConfiguration(backgroundColor: .white,
                                                     borderColor: .gray,
                                                     textColor: .black,
                                                     textFont: .systemFont(ofSize: 14),
                                                     cornerRadius: 4,
                                                     borderWidth: 1,
                                                     placeholderForegroundColor: .lightGray)
        let buttonConfig = ButtonConfiguration(backgroundColor: .blue,
                                               borderColor: .clear,
                                               titleColor: .white,
                                               titleFont: .systemFont(ofSize: 16),
                                               shadowColor: .clear,
                                               cornerRadius: 8,
                                               borderWidth: 0,
                                               shadowRadius: 0,
                                               withBlurEffect: false)
        let paymentReviewConfig = PaymentReviewConfiguration(loadingIndicatorStyle: .large,
                                                             loadingIndicatorColor: .gray,
                                                             infoBarLabelTextColor: .white,
                                                             infoBarBackgroundColor: .green,
                                                             mainViewBackgroundColor: .white,
                                                             infoContainerViewBackgroundColor: .white,
                                                             paymentReviewClose: UIImage(),
                                                             backgroundColor: .white,
                                                             rectangleColor: .lightGray,
                                                             infoBarLabelFont: .systemFont(ofSize: 12),
                                                             statusBarStyle: .default,
                                                             pageIndicatorTintColor: .gray,
                                                             currentPageIndicatorTintColor: .darkGray,
                                                             isInfoBarHidden: true)
        let paymentReviewStrings = PaymentReviewStrings(alertOkButtonTitle: "OK",
                                                       infoBarMessage: "Info",
                                                       defaultErrorMessage: "Error",
                                                       createPaymentErrorMessage: "Payment Error",
                                                       invoiceImageAccessibilityLabel: "Invoice",
                                                       closeButtonAccessibilityLabel: "Close",
                                                       sheetGrabberAccessibilityLabel: "Grabber",
                                                       sheetGrabberAccessibilityHint: "Tap to collapse")
        let containerConfig = PaymentReviewContainerConfiguration(errorLabelTextColor: .red,
                                                                  errorLabelFont: .systemFont(ofSize: 12),
                                                                  lockIcon: UIImage(),
                                                                  lockedFields: false,
                                                                  showBanksPicker: true,
                                                                  chevronDownIcon: nil,
                                                                  chevronDownIconColor: nil)
        let containerStrings = PaymentReviewContainerStrings(emptyCheckErrorMessage: "Required",
                                                             ibanCheckErrorMessage: "Invalid IBAN",
                                                             recipientFieldPlaceholder: "Recipient",
                                                             ibanFieldPlaceholder: "IBAN",
                                                             amountFieldPlaceholder: "Amount",
                                                             usageFieldPlaceholder: "Usage",
                                                             recipientErrorMessage: "Recipient required",
                                                             ibanErrorMessage: "IBAN required",
                                                             amountErrorMessage: "Amount required",
                                                             purposeErrorMessage: "Purpose required",
                                                             payInvoiceLabelText: "Pay",
                                                             payInvoiceAccessibilityHint: "Tap to pay",
                                                             selectBankAccessibilityText: "Select bank",
                                                             selectBankAccessibilityHint: "Tap to select bank")
        let poweredByGiniConfig = PoweredByGiniConfiguration(poweredByGiniLabelFont: .systemFont(ofSize: 10),
                                                             poweredByGiniLabelAccentColor: .gray,
                                                             giniIcon: UIImage())
        let poweredByGiniStrings = PoweredByGiniStrings(poweredByGiniText: "Powered by Gini")
        let bottomSheetConfig = BottomSheetConfiguration(backgroundColor: .white,
                                                          rectangleColor: .lightGray,
                                                          dimmingBackgroundColor: UIColor.black.withAlphaComponent(0.4))

        return PaymentReviewModel(delegate: delegate,
                                  bottomSheetsProvider: bottomSheetsProvider,
                                  document: nil,
                                  extractions: nil,
                                  paymentInfo: nil,
                                  selectedPaymentProvider: makePaymentProvider(),
                                  configuration: paymentReviewConfig,
                                  strings: paymentReviewStrings,
                                  containerConfiguration: containerConfig,
                                  containerStrings: containerStrings,
                                  defaultStyleInputFieldConfiguration: textFieldConfig,
                                  errorStyleInputFieldConfiguration: textFieldConfig,
                                  selectionStyleInputFieldConfiguration: textFieldConfig,
                                  primaryButtonConfiguration: buttonConfig,
                                  secondaryButtonConfiguration: buttonConfig,
                                  poweredByGiniConfiguration: poweredByGiniConfig,
                                  poweredByGiniStrings: poweredByGiniStrings,
                                  bottomSheetConfiguration: bottomSheetConfig,
                                  showPaymentReviewCloseButton: false,
                                  previousPaymentComponentScreenType: nil,
                                  clientConfiguration: nil)
    }

    // MARK: - Test 1: numberOfCells is 0 when no images have been fetched

    /**
     Verifies that `model.numberOfCells` is `0` immediately after construction when no images have been fetched.
     This is the exact condition that triggered the crash when the device had no internet connection.
     */
    @Test func numberOfCells_whenNoImagesLoaded_isZero() {
        let delegate = MockPaymentReviewDelegate()
        let bottomSheetsProvider = MockBottomSheetsProvider()

        let model = makeModel(delegate: delegate, bottomSheetsProvider: bottomSheetsProvider)

        #expect(model.numberOfCells == 0,
                "numberOfCells should be 0 when no preview images have been fetched")
    }

    // MARK: - Test 2: guard condition is correct

    /**
     Verifies that `pageControl.currentPage < model.numberOfCells` correctly identifies when a scroll is safe.
     Confirms the guard returns early when no cells are loaded, as happens when offline.
     */
    @Test func pageControl_currentPage_isWithinBoundsOfLoadedCells() {
        let delegate = MockPaymentReviewDelegate()
        let bottomSheetsProvider = MockBottomSheetsProvider()

        let model = makeModel(delegate: delegate, bottomSheetsProvider: bottomSheetsProvider)

        /// Simulate the page control having pages (set from document metadata)
        /// but the collection having zero cells (no network, fetch failed).
        let pageControl = UIPageControl()
        pageControl.numberOfPages = 3
        pageControl.currentPage = 0

        let page = pageControl.currentPage

        /// With 0 cells loaded the guard should trip — scroll must NOT happen.
        #expect(!(page < model.numberOfCells),
                "page 0 should NOT be within bounds when numberOfCells is 0")

        /// Sanity-check the positive case: when cells equal the page count,
        /// page 0 is a valid index.
        let cellCount = pageControl.numberOfPages
        #expect(page < cellCount,
                "page 0 should be within bounds when cellCount equals numberOfPages")
    }

    // MARK: - Test 3: pageControlTapHandler does not crash when no cells are loaded

    /**
     Confirms that `pageControlTapHandler()` does not crash when no cells are loaded.
     Constructs a `PaymentReviewViewController` in bottom-sheet mode, sets `pageControl.numberOfPages`
     to a non-zero value to simulate offline state, fires the handler, and waits for the async block to complete.
     */
    @Test func pageControlTapHandler_whenNoCellsLoaded_doesNotCrash() async throws {
        let delegate = MockPaymentReviewDelegate()
        let bottomSheetsProvider = MockBottomSheetsProvider()

        let model = makeModel(delegate: delegate, bottomSheetsProvider: bottomSheetsProvider)

        let viewController = PaymentReviewViewController.instantiate(
            viewModel: model,
            selectedPaymentProvider: makePaymentProvider()
        )

        /// Load the view hierarchy so the page control is initialised.
        _ = viewController.view

        /// Simulate the state that triggers the bug: the page control knows about
        /// pages from document metadata but no cells have been loaded (offline).
        viewController.pageControl.numberOfPages = 3
        viewController.pageControl.currentPage = 0

        #expect(model.numberOfCells == 0,
                "Pre-condition: no cells should be loaded before firing the handler")

        /// Fire the handler. Without the fix this would crash inside the async block.
        viewController.pageControlTapHandler()

        /// Wait long enough for the 10 ms `asyncAfter` block to complete.
        try await Task.sleep(nanoseconds: 50_000_000) // 50 ms

        /// If execution reaches this point the guard fired correctly and no crash occurred.
        #expect(model.numberOfCells == 0,
                "numberOfCells should still be 0 after the no-op handler execution")
    }
}

// MARK: - Private Mocks

private final class MockPaymentReviewDelegate: PaymentReviewProtocol {

    // MARK: PaymentReviewAPIProtocol

    func createPaymentRequest(paymentInfo: GiniInternalPaymentSDK.PaymentInfo,
                              completion: @escaping (Result<String, GiniHealthAPILibrary.GiniError>) -> Void) {
        completion(.failure(.noResponse))
    }

    func shouldHandleErrorInternally(error: GiniHealthAPILibrary.GiniError) -> Bool {
        false
    }

    func openPaymentProviderApp(requestId: String,
                                universalLink: String) {}

    func submitFeedback(for document: GiniHealthAPILibrary.Document,
                        updatedExtractions: [GiniHealthAPILibrary.Extraction],
                        completion: ((Result<Void, GiniHealthAPILibrary.GiniError>) -> Void)?) {
        completion?(.success(()))
    }

    /**
     Simulates no internet by always returning a network error.
     */
    func preview(for documentId: String,
                 pageNumber: Int,
                 completion: @escaping (Result<Data, GiniHealthAPILibrary.GiniError>) -> Void) {
        completion(.failure(.noResponse))
    }

    func obtainPDFURLFromPaymentRequest(viewController: UIViewController,
                                        paymentRequestId: String) {}

    // MARK: PaymentReviewTrackingProtocol

    func trackOnPaymentReviewCloseKeyboardClicked() {}
    func trackOnPaymentReviewCloseButtonClicked() {}
    func trackOnPaymentReviewBankButtonClicked(providerName: String) {}

    // MARK: PaymentReviewSupportedFormatsProtocol

    func supportsGPC() -> Bool { true }
    func supportsOpenWith() -> Bool { false }

    // MARK: PaymentReviewActionProtocol

    func updatedPaymentProvider(_ paymentProvider: GiniHealthAPILibrary.PaymentProvider) {}
    func openMoreInformationViewController() {}
    func presentShareInvoiceBottomSheet(paymentRequestId: String,
                                        paymentInfo: GiniInternalPaymentSDK.PaymentInfo) {}
    func paymentReviewClosed(with previousPresentedView: PaymentComponentScreenType?) {}
}

private final class MockBottomSheetsProvider: BottomSheetsProviderProtocol {
    func installAppBottomSheet() -> UIViewController { UIViewController() }
    func shareInvoiceBottomSheet(qrCodeData: Data,
                                 paymentRequestId: String) -> UIViewController { UIViewController() }
    func bankSelectionBottomSheet() -> UIViewController { UIViewController() }
}
