//
//  PaymentReviewModelTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import UIKit
import GiniHealthAPILibrary
@testable import GiniInternalPaymentSDK

@Suite("PaymentReviewModel")
@MainActor
struct PaymentReviewModelTests {

    // MARK: - displayMode

    @Test("displayMode is bottomSheet when document is nil")
    func displayModeIsBottomSheetWithNilDocument() {
        let model = makePaymentReviewModel(delegate: MockPaymentReviewDelegate(),
                                          bottomSheetsProvider: MockBottomSheetsProvider())
        #expect(model.displayMode == .bottomSheet)
    }

    @Test("displayMode is documentCollection when document is provided")
    func displayModeIsDocumentCollectionWithDocument() {
        let model = makePaymentReviewModelWithDocument(delegate: MockPaymentReviewDelegate(),
                                                       bottomSheetsProvider: MockBottomSheetsProvider())
        #expect(model.displayMode == .documentCollection)
    }

    // MARK: - numberOfCells / getCellViewModel

    @Test("numberOfCells returns cellViewModels count")
    func numberOfCellsReflectsCount() {
        let model = makePaymentReviewModel(delegate: MockPaymentReviewDelegate(),
                                          bottomSheetsProvider: MockBottomSheetsProvider())
        #expect(model.numberOfCells == 0)
    }

    @Test("getCellViewModel returns the correct cell at index")
    func getCellViewModelReturnsCorrectCell() {
        let model = makePaymentReviewModel(delegate: MockPaymentReviewDelegate(),
                                          bottomSheetsProvider: MockBottomSheetsProvider())
        let image = UIImage()
        model.cellViewModels = [PageCollectionCellViewModel(preview: image)]
        let cell = model.getCellViewModel(at: IndexPath(row: 0, section: 0))
        #expect(cell.preview === image)
    }

    // MARK: - Loading status callbacks

    @Test("setting isLoading triggers updateLoadingStatus")
    func isLoadingTriggersCallback() {
        let model = makePaymentReviewModel(delegate: MockPaymentReviewDelegate(),
                                          bottomSheetsProvider: MockBottomSheetsProvider())
        var callbackFired = false
        model.updateLoadingStatus = { callbackFired = true }
        model.isLoading = true
        #expect(callbackFired == true)
    }

    @Test("setting isImagesLoading triggers updateImagesLoadingStatus")
    func isImagesLoadingTriggersCallback() {
        let model = makePaymentReviewModel(delegate: MockPaymentReviewDelegate(),
                                          bottomSheetsProvider: MockBottomSheetsProvider())
        var callbackFired = false
        model.updateImagesLoadingStatus = { callbackFired = true }
        model.isImagesLoading = true
        #expect(callbackFired == true)
    }

    @Test("setting cellViewModels triggers reloadCollectionViewClosure")
    func cellViewModelsDidSetTriggersReload() {
        let model = makePaymentReviewModel(delegate: MockPaymentReviewDelegate(),
                                          bottomSheetsProvider: MockBottomSheetsProvider())
        var reloadCalled = false
        model.reloadCollectionViewClosure = { reloadCalled = true }
        model.cellViewModels = [PageCollectionCellViewModel(preview: UIImage())]
        #expect(reloadCalled == true)
    }

    // MARK: - viewDidDisappear

    @Test("viewDidDisappear calls paymentReviewClosed on delegate")
    func viewDidDisappearNotifiesDelegate() {
        let delegate = MockPaymentReviewDelegate()
        let model = makePaymentReviewModel(delegate: delegate,
                                          bottomSheetsProvider: MockBottomSheetsProvider())
        model.viewDidDisappear()
        #expect(delegate.paymentReviewClosedCalled == true)
    }

    @Test("viewDidDisappear forwards previousPaymentComponentScreenType to delegate")
    func viewDidDisappearForwardsPreviousScreenType() {
        let delegate = MockPaymentReviewDelegate()
        let model = makePaymentReviewModelWithDocument(delegate: delegate,
                                                       bottomSheetsProvider: MockBottomSheetsProvider(),
                                                       previousPaymentComponentScreenType: .bankPicker)
        model.viewDidDisappear()
        #expect(delegate.lastClosedScreenType == .bankPicker)
    }

    // MARK: - sendFeedback

    @Test("sendFeedback does nothing when document is nil")
    func sendFeedbackWithNilDocumentIsNoOp() {
        let delegate = MockPaymentReviewDelegate()
        let model = makePaymentReviewModel(delegate: delegate,
                                          bottomSheetsProvider: MockBottomSheetsProvider())
        model.sendFeedback(updatedExtractions: [])
        #expect(delegate.submitFeedbackCalled == false)
    }

    @Test("sendFeedback calls submitFeedback on delegate when document is set")
    func sendFeedbackCallsDelegateWhenDocumentIsSet() {
        let delegate = MockPaymentReviewDelegate()
        let model = makePaymentReviewModelWithDocument(delegate: delegate,
                                                       bottomSheetsProvider: MockBottomSheetsProvider())
        model.sendFeedback(updatedExtractions: [])
        #expect(delegate.submitFeedbackCalled == true)
    }

    // MARK: - createPaymentRequest

    @Test("createPaymentRequest calls completion with requestId on success")
    func createPaymentRequestCallsCompletionOnSuccess() async {
        let delegate = MockPaymentReviewDelegate()
        let model = makePaymentReviewModel(delegate: delegate,
                                          bottomSheetsProvider: MockBottomSheetsProvider())
        let paymentInfo = PaymentInfo(recipient: "Test",
                                      iban: "DE89370400440532013000",
                                      amount: "10.00:EUR",
                                      purpose: "Test",
                                      paymentUniversalLink: "",
                                      paymentProviderId: "id")
        var receivedRequestId: String?
        model.createPaymentRequest(paymentInfo: paymentInfo) { requestId in
            receivedRequestId = requestId
        }
        await Task.yield()
        await Task.yield()
        #expect(receivedRequestId == "mock-request-id")
    }

    @Test("createPaymentRequest toggles isLoading around the async call")
    func createPaymentRequestTogglesLoading() async {
        let delegate = MockPaymentReviewDelegate()
        let model = makePaymentReviewModel(delegate: delegate,
                                          bottomSheetsProvider: MockBottomSheetsProvider())
        let paymentInfo = PaymentInfo(recipient: "Test",
                                      iban: "DE89370400440532013000",
                                      amount: "10.00:EUR",
                                      purpose: "Test",
                                      paymentUniversalLink: "",
                                      paymentProviderId: "id")
        model.createPaymentRequest(paymentInfo: paymentInfo)
        await Task.yield()
        await Task.yield()
        #expect(model.isLoading == false, "isLoading must be reset to false after the request completes")
    }

    @Test("createPaymentRequest calls onCreatePaymentRequestErrorHandling on failure when shouldHandleErrorInternally is true")
    func createPaymentRequestCallsErrorHandlerOnFailure() async {
        let delegate = MockPaymentReviewDelegate()
        delegate.createPaymentRequestResult = .failure(.unknown())
        delegate.shouldHandleInternallyOverride = true
        let model = makePaymentReviewModel(delegate: delegate,
                                          bottomSheetsProvider: MockBottomSheetsProvider())
        var errorHandlerCalled = false
        model.onCreatePaymentRequestErrorHandling = { errorHandlerCalled = true }
        let paymentInfo = PaymentInfo(recipient: "Test",
                                      iban: "DE89370400440532013000",
                                      amount: "10.00:EUR",
                                      purpose: "Test",
                                      paymentUniversalLink: "",
                                      paymentProviderId: "id")
        model.createPaymentRequest(paymentInfo: paymentInfo)
        await Task.yield()
        await Task.yield()
        #expect(errorHandlerCalled == true)
    }

    @Test("createPaymentRequest does not call error handler when shouldHandleErrorInternally is false")
    func createPaymentRequestSkipsErrorHandlerWhenNotInternal() async {
        let delegate = MockPaymentReviewDelegate()
        delegate.createPaymentRequestResult = .failure(.unknown())
        delegate.shouldHandleInternallyOverride = false
        let model = makePaymentReviewModel(delegate: delegate,
                                          bottomSheetsProvider: MockBottomSheetsProvider())
        var errorHandlerCalled = false
        model.onCreatePaymentRequestErrorHandling = { errorHandlerCalled = true }
        let paymentInfo = PaymentInfo(recipient: "Test",
                                      iban: "DE89370400440532013000",
                                      amount: "10.00:EUR",
                                      purpose: "Test",
                                      paymentUniversalLink: "",
                                      paymentProviderId: "id")
        model.createPaymentRequest(paymentInfo: paymentInfo)
        await Task.yield()
        await Task.yield()
        #expect(errorHandlerCalled == false)
    }

    // MARK: - closePaymentReview

    @Test("closePaymentReview calls trackOnPaymentReviewCloseButtonClicked and dismissPaymentReview")
    func closePaymentReviewCallsBothDelegates() {
        let delegate = MockPaymentReviewDelegate()
        let vmDelegate = MockPaymentReviewViewModelDelegate()
        let model = makePaymentReviewModel(delegate: delegate,
                                          bottomSheetsProvider: MockBottomSheetsProvider())
        model.viewModelDelegate = vmDelegate
        model.closePaymentReview()
        #expect(delegate.closeButtonClickedCalled == true)
        #expect(vmDelegate.dismissPaymentReviewCalled == true)
    }

    // MARK: - openPaymentProviderApp

    @Test("openPaymentProviderApp forwards to delegate")
    func openPaymentProviderAppCallsDelegate() {
        let delegate = MockPaymentReviewDelegate()
        let model = makePaymentReviewModel(delegate: delegate,
                                          bottomSheetsProvider: MockBottomSheetsProvider())
        model.openPaymentProviderApp(requestId: "req-1", universalLink: "https://bank.example/pay")
        #expect(delegate.openPaymentProviderAppCalled == true)
    }

    // MARK: - openInstallAppBottomSheet / openBankSelectionBottomSheet (guard paths)

    @Test("openInstallAppBottomSheet is a no-op when provider returns plain UIViewController")
    func openInstallAppBottomSheetIsNoOpWithPlainVC() {
        let vmDelegate = MockPaymentReviewViewModelDelegate()
        let model = makePaymentReviewModel(delegate: MockPaymentReviewDelegate(),
                                          bottomSheetsProvider: MockBottomSheetsProvider())
        model.viewModelDelegate = vmDelegate
        model.openInstallAppBottomSheet()
        #expect(vmDelegate.presentInstallAppCalled == false,
                "presentInstallAppBottomSheet must not be called when the provider returns a plain UIViewController")
    }

    @Test("openInstallAppBottomSheet presents sheet when provider returns InstallAppBottomView")
    func openInstallAppBottomSheetPresentsWhenProviderReturnsRealView() {
        let provider = MockBottomSheetsProvider()
        provider.returnRealInstallAppView = true
        let vmDelegate = MockPaymentReviewViewModelDelegate()
        let model = makePaymentReviewModel(delegate: MockPaymentReviewDelegate(),
                                          bottomSheetsProvider: provider)
        model.viewModelDelegate = vmDelegate
        model.openInstallAppBottomSheet()
        #expect(vmDelegate.presentInstallAppCalled == true,
                "presentInstallAppBottomSheet must be called when the provider returns a real InstallAppBottomView")
    }

    @Test("openBankSelectionBottomSheet is a no-op when provider returns plain UIViewController")
    func openBankSelectionBottomSheetIsNoOpWithPlainVC() {
        let vmDelegate = MockPaymentReviewViewModelDelegate()
        let model = makePaymentReviewModel(delegate: MockPaymentReviewDelegate(),
                                          bottomSheetsProvider: MockBottomSheetsProvider())
        model.viewModelDelegate = vmDelegate
        model.openBankSelectionBottomSheet()
        #expect(vmDelegate.presentBankSelectionCalled == false,
                "presentBankSelectionBottomSheet must not be called when the provider returns a plain UIViewController")
    }

    @Test("openBankSelectionBottomSheet presents sheet when provider returns BanksBottomView")
    func openBankSelectionBottomSheetPresentsWhenProviderReturnsRealView() {
        let provider = MockBottomSheetsProvider()
        provider.returnRealBanksView = true
        let vmDelegate = MockPaymentReviewViewModelDelegate()
        let model = makePaymentReviewModel(delegate: MockPaymentReviewDelegate(),
                                          bottomSheetsProvider: provider)
        model.viewModelDelegate = vmDelegate
        model.openBankSelectionBottomSheet()
        #expect(vmDelegate.presentBankSelectionCalled == true,
                "presentBankSelectionBottomSheet must be called when the provider returns a real BanksBottomView")
    }

    // MARK: - openOnboardingShareInvoiceBottomSheet

    @Test("openOnboardingShareInvoiceBottomSheet calls delegate and presents share invoice sheet")
    func openOnboardingShareInvoiceCallsDelegateAndPresents() {
        let delegate = MockPaymentReviewDelegate()
        let vmDelegate = MockPaymentReviewViewModelDelegate()
        let model = makePaymentReviewModel(delegate: delegate,
                                          bottomSheetsProvider: MockBottomSheetsProvider())
        model.viewModelDelegate = vmDelegate
        let paymentInfo = PaymentInfo(recipient: "R",
                                      iban: "DE89370400440532013000",
                                      amount: "1.00:EUR",
                                      purpose: "P",
                                      paymentUniversalLink: "",
                                      paymentProviderId: "id")
        model.openOnboardingShareInvoiceBottomSheet(paymentRequestId: "req-42", paymentInfo: paymentInfo)
        #expect(delegate.presentShareInvoiceCalled == true)
        #expect(vmDelegate.presentShareInvoiceCalled == true)
    }

    // MARK: - paymentReviewContainerViewModel

    @Test("paymentReviewContainerViewModel returns a configured PaymentReviewContainerViewModel")
    func paymentReviewContainerViewModelReturnsConfiguredVM() {
        let model = makePaymentReviewModel(delegate: MockPaymentReviewDelegate(),
                                          bottomSheetsProvider: MockBottomSheetsProvider())
        let containerVM = model.paymentReviewContainerViewModel()
        #expect(containerVM.selectedPaymentProvider.id == "test-provider-id")
    }

    // MARK: - BanksSelectionProtocol conformance

    @Test("didSelectPaymentProvider updates selectedPaymentProvider and calls delegate")
    func didSelectPaymentProviderUpdatesAndNotifies() {
        let delegate = MockPaymentReviewDelegate()
        let model = makePaymentReviewModel(delegate: delegate,
                                          bottomSheetsProvider: MockBottomSheetsProvider())
        var newProviderFired = false
        model.onNewPaymentProvider = { newProviderFired = true }
        let newProvider = PaymentProvider.fixture(id: "new-bank", name: "New Bank")
        model.didSelectPaymentProvider(paymentProvider: newProvider)
        #expect(model.selectedPaymentProvider.id == "new-bank")
        #expect(delegate.updatedPaymentProviderCalled == true)
        #expect(delegate.lastUpdatedProvider?.id == "new-bank")
        #expect(newProviderFired == true)
    }

    @Test("didTapOnMoreInformation sets previousPaymentComponentScreenType to bankPicker and calls delegate")
    func didTapOnMoreInformationSetsScreenTypeAndCallsDelegate() {
        let delegate = MockPaymentReviewDelegate()
        let model = makePaymentReviewModel(delegate: delegate,
                                          bottomSheetsProvider: MockBottomSheetsProvider())
        model.didTapOnMoreInformation()
        #expect(model.previousPaymentComponentScreenType == .bankPicker)
        #expect(delegate.openMoreInfoCalled == true)
    }

    @Test("didTapOnClose is a no-op")
    func didTapOnCloseIsNoOp() {
        let delegate = MockPaymentReviewDelegate()
        let model = makePaymentReviewModel(delegate: delegate,
                                          bottomSheetsProvider: MockBottomSheetsProvider())
        model.didTapOnClose()
        #expect(delegate.paymentReviewClosedCalled == false)
    }

    @Test("didTapOnContinueOnShareBottomSheet is a no-op")
    func didTapOnContinueOnShareBottomSheetIsNoOp() {
        let delegate = MockPaymentReviewDelegate()
        let model = makePaymentReviewModel(delegate: delegate,
                                          bottomSheetsProvider: MockBottomSheetsProvider())
        model.didTapOnContinueOnShareBottomSheet()
        #expect(delegate.paymentReviewClosedCalled == false)
    }

    @Test("didTapForwardOnInstallBottomSheet is a no-op")
    func didTapForwardIsNoOp() {
        let delegate = MockPaymentReviewDelegate()
        let model = makePaymentReviewModel(delegate: delegate,
                                          bottomSheetsProvider: MockBottomSheetsProvider())
        model.didTapForwardOnInstallBottomSheet()
        #expect(delegate.paymentReviewClosedCalled == false)
    }

    @Test("didTapOnPayButton is a no-op")
    func didTapOnPayButtonIsNoOp() {
        let delegate = MockPaymentReviewDelegate()
        let model = makePaymentReviewModel(delegate: delegate,
                                          bottomSheetsProvider: MockBottomSheetsProvider())
        model.didTapOnPayButton()
        #expect(delegate.paymentReviewClosedCalled == false)
    }

    // MARK: - ShareInvoiceBottomViewProtocol conformance

    @Test("didTapOnContinueToShareInvoice forwards paymentRequestId to viewModelDelegate")
    func didTapOnContinueToShareInvoiceForwards() {
        let vmDelegate = MockPaymentReviewViewModelDelegate()
        let model = makePaymentReviewModel(delegate: MockPaymentReviewDelegate(),
                                          bottomSheetsProvider: MockBottomSheetsProvider())
        model.viewModelDelegate = vmDelegate
        model.didTapOnContinueToShareInvoice(paymentRequestId: "req-99")
        #expect(vmDelegate.obtainPDFCalled == true)
        #expect(vmDelegate.lastObtainedPDFRequestId == "req-99")
    }

    // MARK: - InstallAppBottomViewProtocol conformance

    @Test("PaymentReviewModel.didTapOnContinue triggers createPaymentRequestAndOpenBankApp on its delegate")
    func didTapOnContinueNotifiesViewModelDelegate() {
        let delegate = MockPaymentReviewDelegate()
        let model = makePaymentReviewModel(delegate: delegate,
                                          bottomSheetsProvider: MockBottomSheetsProvider())
        let vmDelegate = MockPaymentReviewViewModelDelegate()
        model.viewModelDelegate = vmDelegate

        model.didTapOnContinue()

        #expect(vmDelegate.createPaymentRequestAndOpenBankAppCalled == true,
                "didTapOnContinue must forward to createPaymentRequestAndOpenBankApp on the viewModelDelegate")
    }

    // MARK: - fetchImages

    @Test("fetchImages returns immediately when document is nil")
    func fetchImagesIsNoOpWithNilDocument() async {
        let model = makePaymentReviewModel(delegate: MockPaymentReviewDelegate(),
                                          bottomSheetsProvider: MockBottomSheetsProvider())
        var previewFetchedCalled = false
        model.onPreviewImagesFetched = { previewFetchedCalled = true }
        await model.fetchImages()
        #expect(previewFetchedCalled == false, "onPreviewImagesFetched must not fire when document is nil")
    }

    @Test("fetchImages sets isImagesLoading and calls onPreviewImagesFetched")
    func fetchImagesWithDocumentCallsCallback() async {
        let delegate = MockPaymentReviewDelegate()
        let model = makePaymentReviewModelWithDocument(delegate: delegate,
                                                       bottomSheetsProvider: MockBottomSheetsProvider(),
                                                       document: .testDocument(pageCount: 2))
        var previewFetchedCalled = false
        model.onPreviewImagesFetched = { previewFetchedCalled = true }
        await model.fetchImages()
        #expect(previewFetchedCalled == true)
        #expect(model.isImagesLoading == false, "isImagesLoading must be false after fetch completes")
    }
}
