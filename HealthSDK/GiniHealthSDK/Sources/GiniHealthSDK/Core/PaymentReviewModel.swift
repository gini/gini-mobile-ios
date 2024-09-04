//
//  PaymentReviewModer.swift
//  GiniHealth
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import GiniHealthAPILibrary
import UIKit

protocol PaymentReviewViewModelDelegate: AnyObject {
    func presentInstallAppBottomSheet(bottomSheet: BottomSheetViewController)
    func presentShareInvoiceBottomSheet(bottomSheet: BottomSheetViewController)
    func createPaymentRequestAndOpenBankApp()
    func obtainPDFFromPaymentRequest()
}

/**
 View model class for review screen
  */
public class PaymentReviewModel: NSObject {
    var onDocumentUpdated: () -> Void = {}

    var onExtractionFetched: () -> Void = {}
    var onExtractionUpdated: () -> Void = {}
    var onPreviewImagesFetched: () -> Void = {}
    var reloadCollectionViewClosure: () -> Void = {}
    var updateLoadingStatus: () -> Void = {}
    var updateImagesLoadingStatus: () -> Void = {}
    
    var onErrorHandling: (_ error: GiniHealthError) -> Void = { _ in }

    var onNoAppsErrorHandling: (_ error: GiniHealthError) -> Void = { _ in }
    
    var onCreatePaymentRequestErrorHandling: () -> Void = {}
    
    var onBankSelection: (_ provider: PaymentProvider) -> Void = { _ in }
    
    weak var viewModelDelegate: PaymentReviewViewModelDelegate?

    public var document: Document {
        didSet {
            self.onDocumentUpdated()
        }
    }

    public var extractions: [Extraction] {
        didSet {
            self.onExtractionFetched()
        }
    }

    public var documentId: String
    var healthSDK: GiniHealth
    private var selectedPaymentProvider: PaymentProvider?

    private var cellViewModels: [PageCollectionCellViewModel] = [PageCollectionCellViewModel]() {
        didSet {
            self.reloadCollectionViewClosure()
        }
    }

    var numberOfCells: Int {
        return cellViewModels.count
    }

    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatus()
        }
    }
    
    var isImagesLoading: Bool = false {
        didSet {
            self.updateImagesLoadingStatus()
        }
    }
    
    // Pay invoice label
    let payInvoiceLabelText: String = GiniLocalized.string("ginihealth.reviewscreen.banking.app.button.label",
                                                                       comment: "Title label used for the pay invoice button")

    public init(with giniHealth: GiniHealth, document: Document, extractions: [Extraction], selectedPaymentProvider: PaymentProvider?) {
        self.healthSDK = giniHealth
        self.documentId = document.id
        self.document = document
        self.extractions = extractions
        self.selectedPaymentProvider = selectedPaymentProvider
    }

    func getCellViewModel(at indexPath: IndexPath) -> PageCollectionCellViewModel {
        return cellViewModels[indexPath.section]
    }

    private func createCellViewModel(previewImage: UIImage) -> PageCollectionCellViewModel {
        return PageCollectionCellViewModel(preview: previewImage)
    }

    func sendFeedback(updatedExtractions: [Extraction]) {
        healthSDK.documentService.submitFeedback(for: document, with: [], and: ["payment": [updatedExtractions]]){ result in
            switch result {
            case .success: break
            case .failure: break
            }
        }
    }
    
    func createPaymentRequest(paymentInfo: PaymentInfo, completion: ((_ paymentRequestID: String) -> ())? = nil) {
        isLoading = true
        healthSDK.createPaymentRequest(paymentInfo: paymentInfo) {[weak self] result in
            self?.isLoading = false
            switch result {
            case let .success(requestId):
                completion?(requestId)
            case let .failure(error):
                if let delegate = self?.healthSDK.delegate, delegate.shouldHandleErrorInternally(error: error) {
                    self?.onCreatePaymentRequestErrorHandling()
                }
            }
        }
    }
    
    func openInstallAppBottomSheet() {
        let installAppBottomSheet = installAppBottomSheet()
        installAppBottomSheet.modalPresentationStyle = .overFullScreen
        viewModelDelegate?.presentInstallAppBottomSheet(bottomSheet: installAppBottomSheet)
    }
    
    func openOnboardingShareInvoiceBottomSheet() {
        let shareInvoiceBottomSheet = shareInvoiceBottomSheet()
        shareInvoiceBottomSheet.modalPresentationStyle = .overFullScreen
        viewModelDelegate?.presentShareInvoiceBottomSheet(bottomSheet: shareInvoiceBottomSheet)
    }

    func openPaymentProviderApp(requestId: String, universalLink: String) {
        healthSDK.openPaymentProviderApp(requestId: requestId, universalLink: universalLink)
    }
    
    func shouldShowOnboardingScreenFor(paymentProvider: PaymentProvider) -> Bool {
        let onboardingCounts = OnboardingShareInvoiceScreenCount.load()
        let count = onboardingCounts.presentationCount(forProvider: paymentProvider.name)
        return count < Constants.numberOfTimesOnboardingShareScreenShouldAppear
    }
    
    func incrementOnboardingCountFor(paymentProvider: PaymentProvider) {
        var onboardingCounts = OnboardingShareInvoiceScreenCount.load()
        onboardingCounts.incrementPresentationCount(forProvider: paymentProvider.name)
    }
    
    func fetchImages() {
        self.isImagesLoading = true
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "imagesQueue")
        let dispatchSemaphore = DispatchSemaphore(value: 0)
        var vms = [PageCollectionCellViewModel]()
        dispatchQueue.async {
            for page in 1 ... self.document.pageCount {
                dispatchGroup.enter()

                self.healthSDK.documentService.preview(for: self.documentId, pageNumber: page) {[weak self] result in
                    switch result {
                    case let .success(dataImage):
                        if let image = UIImage(data: dataImage), let cellModel = self?.createCellViewModel(previewImage: image) {
                            vms.append(cellModel)
                        }
                    case let .failure(error):
                        if let delegate = self?.healthSDK.delegate, delegate.shouldHandleErrorInternally(error: .apiError(error)) {
                            self?.onErrorHandling(.apiError(error))
                        }
                    }
                    dispatchSemaphore.signal()
                    dispatchGroup.leave()
                }
                dispatchSemaphore.wait()
            }

            dispatchGroup.notify(queue: dispatchQueue) {
                DispatchQueue.main.async {
                    self.isImagesLoading = false
                    self.cellViewModels.append(contentsOf: vms)
                    self.onPreviewImagesFetched()
                }
            }
        }
    }
    
    func installAppBottomSheet() -> BottomSheetViewController {
        let installAppBottomViewModel = InstallAppBottomViewModel(selectedPaymentProvider: selectedPaymentProvider)
        installAppBottomViewModel.viewDelegate = self
        let installAppBottomView = InstallAppBottomView(viewModel: installAppBottomViewModel)
        return installAppBottomView
    }
    
    func shareInvoiceBottomSheet() -> BottomSheetViewController {
        let shareInvoiceBottomViewModel = ShareInvoiceBottomViewModel(selectedPaymentProvider: selectedPaymentProvider)
        shareInvoiceBottomViewModel.viewDelegate = self
        let shareInvoiceBottomView = ShareInvoiceBottomView(viewModel: shareInvoiceBottomViewModel)
        return shareInvoiceBottomView
    }

    func loadPDF(paymentRequestID: String, completion: @escaping (Data) -> ()) {
        isLoading = true
        healthSDK.paymentService.pdfWithQRCode(paymentRequestId: paymentRequestID) { [weak self] result in
            self?.isLoading = false
            switch result {
                case .success(let data):
                    completion(data)
                case let .failure(error):
                    if let delegate = self?.healthSDK.delegate, delegate.shouldHandleErrorInternally(error: .apiError(error)) {
                        self?.onCreatePaymentRequestErrorHandling()
                    }
            }
        }
    }
}

extension PaymentReviewModel: InstallAppBottomViewProtocol {
    func didTapOnContinue() {
        viewModelDelegate?.createPaymentRequestAndOpenBankApp()
    }
}

extension PaymentReviewModel: ShareInvoiceBottomViewProtocol {
    func didTapOnContinueToShareInvoice() {
        viewModelDelegate?.obtainPDFFromPaymentRequest()
    }
}

/**
 View model class for collection view cell
 
  */
public struct PageCollectionCellViewModel {
    let preview: UIImage
}

extension PaymentReviewModel {
    private enum Constants {
        static let numberOfTimesOnboardingShareScreenShouldAppear = 3
    }
}
