//
//  PaymentReviewModer.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniHealthAPILibrary
import GiniUtilites

protocol PaymentReviewViewModelDelegate: AnyObject {
    func presentInstallAppBottomSheet(bottomSheet: BottomSheetViewController)
    func presentShareInvoiceBottomSheet(bottomSheet: BottomSheetViewController)
    func createPaymentRequestAndOpenBankApp()
    func obtainPDFFromPaymentRequest()
}

public protocol BottomSheetsProviderProtocol: AnyObject {
    func installAppBottomSheet() -> BottomSheetViewController
    func shareInvoiceBottomSheet() -> BottomSheetViewController
}

public protocol PaymentReviewAPIProtocol: AnyObject {
    func createPaymentRequest(paymentInfo: PaymentInfo, completion: @escaping (Result<String, GiniError>) -> Void)
    func shouldHandleErrorInternally(error: GiniError) -> Bool
    func openPaymentProviderApp(requestID: String, universalLink: String)
    func submitFeedback(for document: Document, updatedExtractions: [Extraction], completion: @escaping (Result<Void, GiniHealthAPILibrary.GiniError>) -> Void)
    func preview(for documentId: String, pageNumber: Int, completion: @escaping (Result<Data, GiniHealthAPILibrary.GiniError>) -> Void)
    func obtainPDFURLFromPaymentRequest(paymentInfo: PaymentInfo, viewController: UIViewController)

    func trackOnPaymentReviewCloseKeyboardClicked()
    func trackOnPaymentReviewCloseButtonClicked()
    func trackOnPaymentReviewBankButtonClicked(providerName: String)

    func supportsGPC() -> Bool
    func supportsOpenWith() -> Bool
    func shouldShowOnboardingScreenFor() -> Bool
}

/**
 View model class for review screen
 */
public class PaymentReviewModel: NSObject {

    var onPreviewImagesFetched: (() -> Void)?
    var reloadCollectionViewClosure: (() -> Void)?
    var updateLoadingStatus: (() -> Void)?
    var updateImagesLoadingStatus: (() -> Void)?

    var onErrorHandling: ((_ error: GiniError) -> Void)?

    var onCreatePaymentRequestErrorHandling: (() -> Void)?

    weak var viewModelDelegate: PaymentReviewViewModelDelegate?
    weak var delegateAPI: PaymentReviewAPIProtocol?
    weak var bottomSheetsProvider: BottomSheetsProviderProtocol?

    public var onPaymentRequestCreated: (() -> Void)?

    public var document: Document?

    public var extractions: [Extraction]?

    public var paymentInfo: PaymentInfo?

    public var documentId: String?
    private var selectedPaymentProvider: GiniHealthAPILibrary.PaymentProvider

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

    let configuration: PaymentReviewConfiguration
    let strings: PaymentReviewStrings
    let containerConfiguration: PaymentReviewContainerConfiguration
    let containerStrings: PaymentReviewContainerStrings
    let defaultStyleInputFieldConfiguration: TextFieldConfiguration
    let errorStyleInputFieldConfiguration: TextFieldConfiguration
    let selectionStyleInputFieldConfiguration: TextFieldConfiguration
    let primaryButtonConfiguration: ButtonConfiguration
    let poweredByGiniConfiguration: PoweredByGiniConfiguration
    let poweredByGiniStrings: PoweredByGiniStrings
    let bottomSheetConfiguration: BottomSheetConfiguration
    let showPaymentReviewCloseButton: Bool

    public init(delegateAPI: PaymentReviewAPIProtocol,
                bottomSheetsProvider: BottomSheetsProviderProtocol,
                document: Document?,
                extractions: [Extraction]?,
                paymentInfo: PaymentInfo?,
                selectedPaymentProvider: GiniHealthAPILibrary.PaymentProvider,
                configuration: PaymentReviewConfiguration,
                strings: PaymentReviewStrings,
                containerConfiguration: PaymentReviewContainerConfiguration,
                containerStrings: PaymentReviewContainerStrings,
                defaultStyleInputFieldConfiguration: TextFieldConfiguration,
                errorStyleInputFieldConfiguration: TextFieldConfiguration,
                selectionStyleInputFieldConfiguration: TextFieldConfiguration,
                primaryButtonConfiguration: ButtonConfiguration,
                poweredByGiniConfiguration: PoweredByGiniConfiguration,
                poweredByGiniStrings: PoweredByGiniStrings,
                bottomSheetConfiguration: BottomSheetConfiguration,
                showPaymentReviewCloseButton: Bool) {
        self.delegateAPI = delegateAPI
        self.bottomSheetsProvider = bottomSheetsProvider
        self.configuration = configuration
        self.strings = strings
        self.documentId = document?.id
        self.document = document
        self.extractions = extractions
        self.paymentInfo = paymentInfo
        self.selectedPaymentProvider = selectedPaymentProvider
        self.poweredByGiniConfiguration = poweredByGiniConfiguration
        self.poweredByGiniStrings = poweredByGiniStrings
        self.showPaymentReviewCloseButton = showPaymentReviewCloseButton
        self.containerConfiguration = containerConfiguration
        self.containerStrings = containerStrings
        self.primaryButtonConfiguration = primaryButtonConfiguration
        self.defaultStyleInputFieldConfiguration = defaultStyleInputFieldConfiguration
        self.errorStyleInputFieldConfiguration = errorStyleInputFieldConfiguration
        self.selectionStyleInputFieldConfiguration = selectionStyleInputFieldConfiguration
        self.bottomSheetConfiguration = bottomSheetConfiguration
    }

    func getCellViewModel(at indexPath: IndexPath) -> PageCollectionCellViewModel {
        return cellViewModels[indexPath.section]
    }

    private func createCellViewModel(previewImage: UIImage) -> PageCollectionCellViewModel {
        return PageCollectionCellViewModel(preview: previewImage)
    }

    func sendFeedback(updatedExtractions: [Extraction]) {
        guard let document else { return }
        delegateAPI?.submitFeedback(for: document, updatedExtractions: updatedExtractions, completion: { _ in })
    }

    func createPaymentRequest(paymentInfo: PaymentInfo, completion: ((_ paymentRequestID: String) -> ())? = nil) {
        isLoading = true
        delegateAPI?.createPaymentRequest(paymentInfo: paymentInfo, completion: { [weak self] result in
            self?.isLoading = false
            switch result {
            case let .success(requestId):
                completion?(requestId)
            case let .failure(error):
                if self?.delegateAPI?.shouldHandleErrorInternally(error: error) == true {
                    self?.onCreatePaymentRequestErrorHandling?()
                }
            }
        })
    }

    func openInstallAppBottomSheet() {
        guard let installAppBottomSheet = bottomSheetsProvider?.installAppBottomSheet() else { return }
        installAppBottomSheet.modalPresentationStyle = .overFullScreen
        viewModelDelegate?.presentInstallAppBottomSheet(bottomSheet: installAppBottomSheet)
    }

    func openOnboardingShareInvoiceBottomSheet() {
        guard let shareInvoiceBottomSheet = bottomSheetsProvider?.shareInvoiceBottomSheet() else { return }
        shareInvoiceBottomSheet.modalPresentationStyle = .overFullScreen
        viewModelDelegate?.presentShareInvoiceBottomSheet(bottomSheet: shareInvoiceBottomSheet)
    }

    func openPaymentProviderApp(requestId: String, universalLink: String) {
        delegateAPI?.openPaymentProviderApp(requestID: requestId, universalLink: universalLink)
    }

    func fetchImages() {
        self.isImagesLoading = true
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "imagesQueue")
        let dispatchSemaphore = DispatchSemaphore(value: 0)
        guard let document, let documentId else { return }
        var vms = [PageCollectionCellViewModel]()
        dispatchQueue.async {
            for page in 1 ... document.pageCount {
                dispatchGroup.enter()

                self.delegateAPI?.preview(for: documentId, pageNumber: page, completion: { [weak self] result in
                    if let cellModel = self?.proccessPreview(result) {
                        vms.append(cellModel)
                    }
                    dispatchSemaphore.signal()
                    dispatchGroup.leave()
                })
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
            if delegateAPI?.shouldHandleErrorInternally(error: error) == true {
                onErrorHandling?(error)
            }
        }
        return nil
    }

    func paymentReviewContainerViewModel() -> PaymentReviewContainerViewModel {
        PaymentReviewContainerViewModel(extractions: extractions,
                                        paymentInfo: paymentInfo,
                                        selectedPaymentProvider: selectedPaymentProvider,
                                        configuration: containerConfiguration,
                                        strings: containerStrings,
                                        primaryButtonConfiguration: primaryButtonConfiguration,
                                        defaultStyleInputFieldConfiguration: defaultStyleInputFieldConfiguration,
                                        errorStyleInputFieldConfiguration: errorStyleInputFieldConfiguration,
                                        selectionStyleInputFieldConfiguration: selectionStyleInputFieldConfiguration,
                                        poweredByGiniConfiguration: poweredByGiniConfiguration,
                                        poweredByGiniStrings: poweredByGiniStrings)
    }
}

extension PaymentReviewModel: InstallAppBottomViewProtocol {
    public func didTapOnContinue() {
        viewModelDelegate?.createPaymentRequestAndOpenBankApp()
    }
}

extension PaymentReviewModel: ShareInvoiceBottomViewProtocol {
    public func didTapOnContinueToShareInvoice() {
        viewModelDelegate?.obtainPDFFromPaymentRequest()
    }
}

/**
 View model class for collection view cell

 */
public struct PageCollectionCellViewModel {
    let preview: UIImage
}