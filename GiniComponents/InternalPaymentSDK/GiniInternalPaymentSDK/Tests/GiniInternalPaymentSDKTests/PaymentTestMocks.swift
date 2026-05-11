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
    var closeButtonClickedCalled = false
    var createPaymentRequestCalled = false
    var lastPaymentInfo: PaymentInfo?
    var openPaymentProviderAppCalled = false
    var supportsGPCOverride = false
    var supportsOpenWithOverride = false
    var shouldHandleInternallyOverride = true
    var createPaymentRequestResult: Result<String, GiniError> = .success("mock-request-id")
    var submitFeedbackCalled = false
    var updatedPaymentProviderCalled = false
    var lastUpdatedProvider: PaymentProvider?
    var openMoreInfoCalled = false
    var paymentReviewClosedCalled = false
    var lastClosedScreenType: PaymentComponentScreenType?
    var presentShareInvoiceCalled = false
    var previewResult: Result<Data, GiniError> = .success(Data())

    // PaymentReviewAPIProtocol
    func createPaymentRequest(paymentInfo: PaymentInfo, completion: @escaping (Result<String, GiniError>) -> Void) {
        createPaymentRequestCalled = true
        lastPaymentInfo = paymentInfo
        completion(createPaymentRequestResult)
    }
    func shouldHandleErrorInternally(error: GiniError) -> Bool { shouldHandleInternallyOverride }
    func openPaymentProviderApp(requestId: String, universalLink: String) {
        openPaymentProviderAppCalled = true
    }
    func submitFeedback(for document: Document,
                        updatedExtractions: [Extraction],
                        completion: ((Result<Void, GiniError>) -> Void)?) {
        submitFeedbackCalled = true
    }
    func preview(for documentId: String, pageNumber: Int, completion: @escaping (Result<Data, GiniError>) -> Void) {
        completion(previewResult)
    }
    func obtainPDFURLFromPaymentRequest(viewController: UIViewController, paymentRequestId: String) {
        // This method will remain empty; no implementation is needed.
    }

    // PaymentReviewTrackingProtocol
    func trackOnPaymentReviewCloseKeyboardClicked() { closeKeyboardClickedCalled = true }
    func trackOnPaymentReviewCloseButtonClicked() { closeButtonClickedCalled = true }
    func trackOnPaymentReviewBankButtonClicked(providerName: String) {
        // This method will remain empty; no implementation is needed.
    }

    // PaymentReviewSupportedFormatsProtocol
    func supportsGPC() -> Bool { supportsGPCOverride }
    func supportsOpenWith() -> Bool { supportsOpenWithOverride }

    // PaymentReviewActionProtocol
    func updatedPaymentProvider(_ paymentProvider: PaymentProvider) {
        updatedPaymentProviderCalled = true
        lastUpdatedProvider = paymentProvider
    }
    func openMoreInformationViewController() { openMoreInfoCalled = true }
    func paymentReviewClosed(with previousPresentedView: PaymentComponentScreenType?) {
        paymentReviewClosedCalled = true
        lastClosedScreenType = previousPresentedView
    }
    func presentShareInvoiceBottomSheet(paymentRequestId: String,
                                        paymentInfo: PaymentInfo,
                                        completion: @escaping (UIViewController) -> Void) {
        presentShareInvoiceCalled = true
        completion(UIViewController())
    }
}

final class MockBottomSheetsProvider: BottomSheetsProviderProtocol {
    var returnRealInstallAppView = false
    var returnRealBanksView = false

    func installAppBottomSheet() -> UIViewController {
        guard returnRealInstallAppView else { return UIViewController() }
        let vm = InstallAppBottomViewModel(selectedPaymentProvider: .test,
                                           installAppConfiguration: .test,
                                           strings: .test,
                                           primaryButtonConfiguration: .test,
                                           poweredByGiniConfiguration: .test,
                                           poweredByGiniStrings: .test,
                                           clientConfiguration: nil)
        return InstallAppBottomView(viewModel: vm, bottomSheetConfiguration: .test)
    }

    func shareInvoiceBottomSheet(qrCodeData: Data, paymentRequestId: String) -> UIViewController { UIViewController() }

    func bankSelectionBottomSheet() -> UIViewController {
        guard returnRealBanksView else { return UIViewController() }
        let vm = BanksBottomViewModel(paymentProviders: [],
                                      selectedPaymentProvider: .test,
                                      configuration: .test,
                                      strings: .test,
                                      poweredByGiniConfiguration: .test,
                                      poweredByGiniStrings: .test,
                                      moreInformationConfiguration: .test,
                                      moreInformationStrings: .test,
                                      paymentInfoConfiguration: .test,
                                      paymentInfoStrings: .test,
                                      clientConfiguration: nil)
        return BanksBottomView(viewModel: vm, bottomSheetConfiguration: .test)
    }
}

// MARK: - URL opener mock

final class MockURLOpener: URLOpenerProtocol {
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
    var didTapContinueShareCalled = false
    var didTapForwardInstallCalled = false
    var didTapPayButtonCalled = false

    func didSelectPaymentProvider(paymentProvider: PaymentProvider) { selectedProvider = paymentProvider }
    func didTapOnMoreInformation() { didTapMoreInfoCalled = true }
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

final class MockPaymentReviewViewModelDelegate: PaymentReviewViewModelDelegate {
    var createPaymentRequestAndOpenBankAppCalled = false
    var dismissPaymentReviewCalled = false
    var obtainPDFCalled = false
    var lastObtainedPDFRequestId: String?
    var presentShareInvoiceCalled = false
    var presentInstallAppCalled = false
    var presentBankSelectionCalled = false
    var presentErrorAlertCalled = false
    var lastErrorMessage: String?

    func presentInstallAppBottomSheet(bottomSheet: UIViewController) { presentInstallAppCalled = true }
    func presentBankSelectionBottomSheet(bottomSheet: UIViewController) { presentBankSelectionCalled = true }
    func createPaymentRequestAndOpenBankApp() { createPaymentRequestAndOpenBankAppCalled = true }
    func obtainPDFFromPaymentRequest(paymentRequestId: String) {
        obtainPDFCalled = true
        lastObtainedPDFRequestId = paymentRequestId
    }
    func presentShareInvoiceBottomSheet(bottomSheet: UIViewController) { presentShareInvoiceCalled = true }
    func dismissPaymentReview() { dismissPaymentReviewCalled = true }
    func presentErrorAlert(message: String) {
        presentErrorAlertCalled = true
        lastErrorMessage = message
    }
}
