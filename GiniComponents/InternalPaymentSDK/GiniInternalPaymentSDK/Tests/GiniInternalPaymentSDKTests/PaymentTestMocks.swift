//
//  PaymentTestMocks.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import UIKit
import GiniHealthAPILibrary
import GiniUtilites
@testable import GiniInternalPaymentSDK

// MARK: - PaymentReview mocks

final class MockPaymentReviewDelegate: PaymentReviewProtocol {
    var closeKeyboardClickedCalled = false

    // PaymentReviewAPIProtocol
    func createPaymentRequest(paymentInfo: PaymentInfo, completion: @escaping (Result<String, GiniError>) -> Void) {
        // This method will remain empty; no implementation is needed.
    }
    func shouldHandleErrorInternally(error: GiniError) -> Bool { true }
    func openPaymentProviderApp(requestId: String, universalLink: String) {
        // This method will remain empty; no implementation is needed.
    }
    func submitFeedback(for document: Document,
                        updatedExtractions: [Extraction],
                        completion: ((Result<Void, GiniError>) -> Void)?) {
        // This method will remain empty; no implementation is needed.
    }
    func preview(for documentId: String, pageNumber: Int, completion: @escaping (Result<Data, GiniError>) -> Void) {
        // This method will remain empty; no implementation is needed.
    }
    func obtainPDFURLFromPaymentRequest(viewController: UIViewController, paymentRequestId: String) {
        // This method will remain empty; no implementation is needed.
    }

    // PaymentReviewTrackingProtocol
    func trackOnPaymentReviewCloseKeyboardClicked() { closeKeyboardClickedCalled = true }
    func trackOnPaymentReviewCloseButtonClicked() {
        // This method will remain empty; no implementation is needed.
    }
    func trackOnPaymentReviewBankButtonClicked(providerName: String) {
        // This method will remain empty; no implementation is needed.
    }

    // PaymentReviewSupportedFormatsProtocol
    func supportsGPC() -> Bool { false }
    func supportsOpenWith() -> Bool { false }

    // PaymentReviewActionProtocol
    func updatedPaymentProvider(_ paymentProvider: PaymentProvider) {
        // This method will remain empty; no implementation is needed.
    }
    func openMoreInformationViewController() {
        // This method will remain empty; no implementation is needed.
    }
    func paymentReviewClosed(with previousPresentedView: PaymentComponentScreenType?) {
        // This method will remain empty; no implementation is needed.
    }
    func presentShareInvoiceBottomSheet(paymentRequestId: String,
                                        paymentInfo: PaymentInfo,
                                        completion: @escaping (UIViewController) -> Void) {
        // This method will remain empty; no implementation is needed.
    }
}

final class MockBottomSheetsProvider: BottomSheetsProviderProtocol {
    func installAppBottomSheet() -> UIViewController { UIViewController() }
    func shareInvoiceBottomSheet(qrCodeData: Data, paymentRequestId: String) -> UIViewController { UIViewController() }
    func bankSelectionBottomSheet() -> UIViewController { UIViewController() }
}

// MARK: - URL opener mock

final class MockURLOpenerProtocol: URLOpenerProtocol {
    private let installedSchemes: Set<String>

    init(installedSchemes: Set<String> = []) {
        self.installedSchemes = installedSchemes
    }

    convenience init(installedScheme: String) {
        self.init(installedSchemes: [installedScheme])
    }

    func canOpenURL(_ url: URL) -> Bool {
        installedSchemes.contains(url.scheme ?? "")
    }

    func open(_ url: URL,
              options: [UIApplication.OpenExternalURLOptionsKey: Any],
              completionHandler completion: GiniOpenLinkCompletionBlock?) {
        // This method will remain empty; no implementation is needed.
    }
}

// MARK: - View delegate mocks

final class MockBanksSelectionDelegate: BanksSelectionProtocol {
    var selectedProvider: PaymentProvider?
    var didTapMoreInfoCalled = false
    var didTapCloseCalled = false
    var didTapContinueShareCalled = false
    var didTapForwardInstallCalled = false
    var didTapPayButtonCalled = false

    func didSelectPaymentProvider(paymentProvider: PaymentProvider) { selectedProvider = paymentProvider }
    func didTapOnMoreInformation() { didTapMoreInfoCalled = true }
    func didTapOnClose() { didTapCloseCalled = true }
    func didTapOnContinueOnShareBottomSheet() { didTapContinueShareCalled = true }
    func didTapForwardOnInstallBottomSheet() { didTapForwardInstallCalled = true }
    func didTapOnPayButton() { didTapPayButtonCalled = true }
}

final class MockPaymentComponentDelegate: PaymentComponentViewProtocol {
    var didTapMoreInfoCalled = false
    var didTapBankPickerCalled = false
    var didTapPayInvoiceCalled = false
    var didDismissCalled = false

    func didTapOnMoreInformation(documentId: String?) { didTapMoreInfoCalled = true }
    func didTapOnBankPicker(documentId: String?) { didTapBankPickerCalled = true }
    func didTapOnPayInvoice(documentId: String?) { didTapPayInvoiceCalled = true }
    func didDismissPaymentComponent() { didDismissCalled = true }
}

final class MockShareInvoiceDelegate: ShareInvoiceBottomViewProtocol {
    var continueTappedRequestId: String?

    func didTapOnContinueToShareInvoice(paymentRequestId: String) {
        continueTappedRequestId = paymentRequestId
    }
}

final class MockInstallAppDelegate: InstallAppBottomViewProtocol {
    var didTapContinueCalled = false

    func didTapOnContinue() { didTapContinueCalled = true }
}
