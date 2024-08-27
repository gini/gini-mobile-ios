//
//  PaymentReviewModer.swift
//  GiniMerchantSDK
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

    var onPreviewImagesFetched: (() -> Void)?
    var reloadCollectionViewClosure: (() -> Void)?
    var updateLoadingStatus: (() -> Void)?
    var updateImagesLoadingStatus: (() -> Void)?

    var onErrorHandling: ((_ error: GiniMerchantError) -> Void)?

    var onCreatePaymentRequestErrorHandling: (() -> Void)?

    weak var viewModelDelegate: PaymentReviewViewModelDelegate?

    public var document: Document?

    public var extractions: [Extraction]?
    public var paymentInfo: PaymentInfo?

    public var documentId: String?
    private var merchantSDK: GiniMerchant
    private var selectedPaymentProvider: PaymentProvider?

    private var cellViewModels: [PageCollectionCellViewModel] = [PageCollectionCellViewModel]() {
        didSet {
            self.reloadCollectionViewClosure?()
        }
    }

    var numberOfCells: Int {
        return cellViewModels.count
    }

    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatus?()
        }
    }

    var isImagesLoading: Bool = false {
        didSet {
            self.updateImagesLoadingStatus?()
        }
    }

    var paymentComponentsController: PaymentComponentsController

    public init(with giniMerchant: GiniMerchant, document: Document?, extractions: [Extraction]?, paymentInfo: PaymentInfo?, selectedPaymentProvider: PaymentProvider?, paymentComponentsController: PaymentComponentsController) {
        self.merchantSDK = giniMerchant
        self.documentId = document?.id
        self.document = document
        self.extractions = extractions
        self.paymentInfo = paymentInfo
        self.selectedPaymentProvider = selectedPaymentProvider
        self.paymentComponentsController = paymentComponentsController
    }

    func getCellViewModel(at indexPath: IndexPath) -> PageCollectionCellViewModel {
        return cellViewModels[indexPath.section]
    }

    private func createCellViewModel(previewImage: UIImage) -> PageCollectionCellViewModel {
        return PageCollectionCellViewModel(preview: previewImage)
    }

    func sendFeedback(updatedExtractions: [Extraction]) {
        guard let document else { return }
        merchantSDK.documentService.submitFeedback(for: document, with: [], and: ["payment": [updatedExtractions]], completion: { _ in })
    }
    
    func createPaymentRequest(paymentInfo: PaymentInfo, completion: ((_ paymentRequestID: String) -> ())? = nil) {
        isLoading = true
        self.paymentInfo = paymentInfo
        merchantSDK.createPaymentRequest(paymentInfo: paymentInfo) {[weak self] result in
            self?.isLoading = false
            switch result {
            case let .success(requestId):
                completion?(requestId)
            case let .failure(error):
                if let delegate = self?.merchantSDK.delegate, delegate.shouldHandleErrorInternally(error: GiniMerchantError.apiError(error)) {
                    self?.onCreatePaymentRequestErrorHandling?()
                }
            }
        }
    }
    
    func openInstallAppBottomSheet() {
        guard let installAppBottomSheet = paymentComponentsController.installAppBottomSheet() as? BottomSheetViewController else { return }
        installAppBottomSheet.modalPresentationStyle = .overFullScreen
        viewModelDelegate?.presentInstallAppBottomSheet(bottomSheet: installAppBottomSheet)
    }
    
    func openOnboardingShareInvoiceBottomSheet() {
        guard let shareInvoiceBottomSheet = paymentComponentsController.shareInvoiceBottomSheet() as? BottomSheetViewController else { return }
        shareInvoiceBottomSheet.modalPresentationStyle = .overFullScreen
        viewModelDelegate?.presentShareInvoiceBottomSheet(bottomSheet: shareInvoiceBottomSheet)
    }

    func openPaymentProviderApp(requestId: String, universalLink: String) {
        merchantSDK.openPaymentProviderApp(requestID: requestId, universalLink: universalLink)
    }

    func fetchImages() {
        guard let document else { return }
        self.isImagesLoading = true
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "imagesQueue")
        let dispatchSemaphore = DispatchSemaphore(value: 0)
        var vms = [PageCollectionCellViewModel]()
        dispatchQueue.async {
            for page in 1 ... document.pageCount {
                dispatchGroup.enter()

                self.merchantSDK.documentService.preview(for: document.id, pageNumber: page) { [weak self] result in
                    if let cellModel = self?.proccessPreview(result) {
                        vms.append(cellModel)
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
                    self.onPreviewImagesFetched?()
                }
            }
        }
    }

    private func proccessPreview(_ result: Result<Data, GiniError>) -> PageCollectionCellViewModel? {
        switch result {
        case let .success(dataImage):
            if let image = UIImage(data: dataImage) {
               return createCellViewModel(previewImage: image)
            }
        case let .failure(error):
            if let delegate = merchantSDK.delegate, delegate.shouldHandleErrorInternally(error: GiniMerchantError.apiError(error)) {
                onErrorHandling?(.apiError(error))
            }
        }
        return nil
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
