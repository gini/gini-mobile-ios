//
//  PaymentReviewModer.swift
//  GiniHealth
//
//  Created by Nadya Karaban on 18.04.21.
//

import GiniHealthAPILibrary
import UIKit
/**
 View model class for review screen
  */
public class PaymentReviewModel: NSObject {
    var onDocumentUpdated: () -> Void = {}
    var onPaymentProvidersFetched: (_ provider: PaymentProviders) -> Void = { _ in }

    var onExtractionFetched: () -> Void = {}
    var onExtractionUpdated: () -> Void = {}
    var onPreviewImagesFetched: () -> Void = {}
    var reloadCollectionViewClosure: () -> Void = {}
    var updateLoadingStatus: () -> Void = {}
    var updateImagesLoadingStatus: () -> Void = {}
    
    var onErrorHandling: (_ error: GiniHealthError) -> Void = { _ in }

    var onNoAppsErrorHandling: (_ error: GiniHealthError) -> Void = { _ in }
    
    var onCreatePaymentRequestErrorHandling: () -> Void = {}

    public var document: Document {
        didSet {
            self.onDocumentUpdated()
        }
    }

    private var providers: PaymentProviders = []

    public var extractions: [Extraction] {
        didSet {
            self.onExtractionFetched()
        }
    }

    public var documentId: String
    private var healthSDK: GiniHealth

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

    public init(with giniHealth: GiniHealth, document: Document, extractions: [Extraction]) {
        self.healthSDK = giniHealth
        self.documentId = document.id
        self.document = document
        self.extractions = extractions
    }

    func getCellViewModel(at indexPath: IndexPath) -> PageCollectionCellViewModel {
        return cellViewModels[indexPath.section]
    }

    private func createCellViewModel(previewImage: UIImage) -> PageCollectionCellViewModel {
        return PageCollectionCellViewModel(preview: previewImage)
    }

    func checkIfAnyPaymentProviderAvailiable() {
        healthSDK.checkIfAnyPaymentProviderAvailiable {[weak self] result in
            switch result {
            case let .success(providers):
                self?.onPaymentProvidersFetched(providers)
            case let .failure(error):
                if let delegate = self?.healthSDK.delegate, delegate.shouldHandleErrorInternally(error: error) {
                    self?.onNoAppsErrorHandling(error)
                }
            }
        }
    }

    func sendFeedback(updatedExtractions: [Extraction]) {
        healthSDK.documentService.submitFeedback(for: document, with: updatedExtractions) { result in
            switch result {
            case .success: break
            case .failure: break
            }
        }
    }
    
    func createPaymentRequest(paymentInfo: PaymentInfo) {
        isLoading = true
        healthSDK.createPaymentRequest(paymentInfo: paymentInfo) {[weak self] result in
            switch result {
            case let .success(requestId):
                    self?.isLoading = false
                    self?.openPaymentProviderApp(requestId: requestId, appScheme: paymentInfo.paymentProviderScheme)
            case let .failure(error):
                    self?.isLoading = false
                if let delegate = self?.healthSDK.delegate, delegate.shouldHandleErrorInternally(error: error) {
                    self?.onCreatePaymentRequestErrorHandling()
                }
            }
        }
    }

    func openPaymentProviderApp(requestId: String, appScheme: String) {
        healthSDK.openPaymentProviderApp(requestID: requestId, appScheme: appScheme)
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
}

/**
 View model class for collection view cell
 
  */
public struct PageCollectionCellViewModel {
    let preview: UIImage
}
