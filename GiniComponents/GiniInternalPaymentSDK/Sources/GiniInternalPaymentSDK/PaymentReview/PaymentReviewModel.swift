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
    func presentInstallAppBottomSheet(bottomSheet: UIViewController)
    func presentBankSelectionBottomSheet(bottomSheet: UIViewController)
    func createPaymentRequestAndOpenBankApp()
    func obtainPDFFromPaymentRequest(paymentRequestId: String)
}

/// BottomSheetsProviderProtocol defines methods for providing custom bottom sheets.
public protocol BottomSheetsProviderProtocol: AnyObject {
    func installAppBottomSheet() -> UIViewController
    func shareInvoiceBottomSheet(qrCodeData: Data, paymentRequestId: String) -> UIViewController
    func bankSelectionBottomSheet() -> UIViewController
}

/// PaymentReviewProtocol combines the functionalities of PaymentReviewAPIProtocol, PaymentReviewTrackingProtocol, PaymentReviewSupportedFormatsProtocol, and PaymentReviewActionProtocol for comprehensive payment review management.
public typealias PaymentReviewProtocol = PaymentReviewAPIProtocol & PaymentReviewTrackingProtocol & PaymentReviewSupportedFormatsProtocol & PaymentReviewActionProtocol

/// PaymentReviewAPIProtocol defines methods for handling payment review processes.
public protocol PaymentReviewAPIProtocol: AnyObject {
    func createPaymentRequest(paymentInfo: PaymentInfo, completion: @escaping (Result<String, GiniError>) -> Void)
    func shouldHandleErrorInternally(error: GiniError) -> Bool
    func openPaymentProviderApp(requestId: String, universalLink: String)
    func submitFeedback(for document: Document, updatedExtractions: [Extraction], completion: ((Result<Void, GiniHealthAPILibrary.GiniError>) -> Void)?)
    func preview(for documentId: String, pageNumber: Int, completion: @escaping (Result<Data, GiniHealthAPILibrary.GiniError>) -> Void)
    func obtainPDFURLFromPaymentRequest(viewController: UIViewController, paymentRequestId: String)
}

/// PaymentReviewTrackingProtocol defines methods for tracking user interactions during the payment review process.
public protocol PaymentReviewTrackingProtocol {
    func trackOnPaymentReviewCloseKeyboardClicked()
    func trackOnPaymentReviewCloseButtonClicked()
    func trackOnPaymentReviewBankButtonClicked(providerName: String)
}

/// PaymentReviewSupportedFormatsProtocol defines methods for checking supported formats in the payment review process.
public protocol PaymentReviewSupportedFormatsProtocol {
    func supportsGPC() -> Bool
    func supportsOpenWith() -> Bool
}

/// PaymentReviewActionProtocol defines actions related to payment review processes.
public protocol PaymentReviewActionProtocol {
    func updatedPaymentProvider(_ paymentProvider: PaymentProvider)
    func openMoreInformationViewController()
    func presentShareInvoiceBottomSheet(paymentRequestId: String, paymentInfo: PaymentInfo)
    func paymentReviewClosed(with previousPresentedView: PaymentComponentScreenType?)
}

/**
 View model class for review screen
 */
public class PaymentReviewModel {

    var onPreviewImagesFetched: (() -> Void)?
    var reloadCollectionViewClosure: (() -> Void)?
    var updateLoadingStatus: (() -> Void)?
    var updateImagesLoadingStatus: (() -> Void)?

    var onErrorHandling: ((_ error: GiniError) -> Void)?

    var onCreatePaymentRequestErrorHandling: (() -> Void)?

    var onNewPaymentProvider: (() -> Void)?

    weak var viewModelDelegate: PaymentReviewViewModelDelegate?
    weak var delegate: PaymentReviewProtocol?
    weak var bottomSheetsProvider: BottomSheetsProviderProtocol?

    public var onPaymentRequestCreated: (() -> Void)?

    public var document: Document?

    public var extractions: [Extraction]?

    public var paymentInfo: PaymentInfo?

    public var documentId: String?
    var selectedPaymentProvider: GiniHealthAPILibrary.PaymentProvider

    var cellViewModels: [PageCollectionCellViewModel] = [PageCollectionCellViewModel]() {
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
    let secondaryButtonConfiguration: ButtonConfiguration
    let poweredByGiniConfiguration: PoweredByGiniConfiguration
    let poweredByGiniStrings: PoweredByGiniStrings
    let bottomSheetConfiguration: BottomSheetConfiguration
    let showPaymentReviewCloseButton: Bool
    var displayMode: DisplayMode
    var previousPaymentComponentScreenType: PaymentComponentScreenType?
    
    var clientConfiguration: ClientConfiguration?

    public init(delegate: PaymentReviewProtocol,
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
                secondaryButtonConfiguration: ButtonConfiguration,
                poweredByGiniConfiguration: PoweredByGiniConfiguration,
                poweredByGiniStrings: PoweredByGiniStrings,
                bottomSheetConfiguration: BottomSheetConfiguration,
                showPaymentReviewCloseButton: Bool,
                previousPaymentComponentScreenType: PaymentComponentScreenType?,
                clientConfiguration: ClientConfiguration?) {
        self.delegate = delegate
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
        self.secondaryButtonConfiguration = secondaryButtonConfiguration
        self.defaultStyleInputFieldConfiguration = defaultStyleInputFieldConfiguration
        self.errorStyleInputFieldConfiguration = errorStyleInputFieldConfiguration
        self.selectionStyleInputFieldConfiguration = selectionStyleInputFieldConfiguration
        self.bottomSheetConfiguration = bottomSheetConfiguration
        self.displayMode = document != nil ? .documentCollection : .bottomSheet
        self.previousPaymentComponentScreenType = previousPaymentComponentScreenType
        self.clientConfiguration = clientConfiguration
    }

    func viewDidDisappear() {
        delegate?.paymentReviewClosed(with: previousPaymentComponentScreenType)
    }

    func getCellViewModel(at indexPath: IndexPath) -> PageCollectionCellViewModel {
        return cellViewModels[indexPath.section]
    }

    private func createCellViewModel(previewImage: UIImage) -> PageCollectionCellViewModel {
        return PageCollectionCellViewModel(preview: previewImage)
    }

    func sendFeedback(updatedExtractions: [Extraction]) {
        guard let document else { return }
        delegate?.submitFeedback(for: document, updatedExtractions: updatedExtractions, completion: nil)
    }

    func createPaymentRequest(paymentInfo: PaymentInfo, completion: ((_ paymentRequestId: String) -> ())? = nil) {
        isLoading = true
        delegate?.createPaymentRequest(paymentInfo: paymentInfo, completion: { [weak self] result in
            self?.isLoading = false
            switch result {
            case let .success(requestId):
                completion?(requestId)
            case let .failure(error):
                if self?.delegate?.shouldHandleErrorInternally(error: error) == true {
                    self?.onCreatePaymentRequestErrorHandling?()
                }
            }
        })
    }

    func openInstallAppBottomSheet() {
        guard let installAppBottomSheet = bottomSheetsProvider?.installAppBottomSheet() as? InstallAppBottomView else { return }
        installAppBottomSheet.viewModel.viewDelegate = self
        viewModelDelegate?.presentInstallAppBottomSheet(bottomSheet: installAppBottomSheet)
    }

    func openOnboardingShareInvoiceBottomSheet(paymentRequestId: String, paymentInfo: PaymentInfo) {
        delegate?.presentShareInvoiceBottomSheet(paymentRequestId: paymentRequestId, paymentInfo: paymentInfo)
    }

    func openBankSelectionBottomSheet() {
        guard let banksPickerBottomSheet = bottomSheetsProvider?.bankSelectionBottomSheet() as? BanksBottomView else { return }
        banksPickerBottomSheet.viewModel.viewDelegate = self
        viewModelDelegate?.presentBankSelectionBottomSheet(bottomSheet: banksPickerBottomSheet)
    }

    func openPaymentProviderApp(requestId: String, universalLink: String) {
        delegate?.openPaymentProviderApp(requestId: requestId, universalLink: universalLink)
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

                self.delegate?.preview(for: documentId, pageNumber: page, completion: { [weak self] result in
                    if let cellModel = self?.processPreview(result) {
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
    
    /**
    Async/await variant of ``fetchImages()`` tailored for SwiftUI and other async contexts.
    Use this version from SwiftUI (e.g. inside a `Task` or `.task` modifier) or when you are
    already in an async context and want structured concurrency instead of completion handlers.
    The synchronous ``fetchImages()`` completion-handler-based version should be used
    from legacy, non-async code.
     
    This method:
     - Loads all page previews concurrently using a task group.
     - Updates ``isImagesLoading`` and `cellViewModels`
     - Invokes ``onPreviewImagesFetched`` once all previews have been processed.
    */
    func fetchImages() async {
        guard let document, let documentId else { return }
        
        isImagesLoading = true
        
        let viewModels = await withTaskGroup(of: PageCollectionCellViewModel?.self) { group in
            for page in 1 ... document.pageCount {
                group.addTask {
                    await self.buildCellViewModel(documentId: documentId, pageNumber: page)
                }
            }
            
            // Collect all the non nil results.
            return await group.reduce(into: [PageCollectionCellViewModel]()) { result, cellViewModel in
                guard let cellViewModel else { return }
                result.append(cellViewModel)
            }
        }
        
        isImagesLoading = false
        cellViewModels.append(contentsOf: viewModels)
        onPreviewImagesFetched?()
    }
    
    private func buildCellViewModel(documentId: String, pageNumber: Int) async -> PageCollectionCellViewModel? {
        do {
            let data = try await fetchPreview(for: documentId, pageNumber: pageNumber)
            
            return processPreview(data)
        } catch {
            return nil
        }
    }
    
    private func fetchPreview(for documentId: String, pageNumber: Int) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            self.delegate?.preview(for: documentId, pageNumber: pageNumber) { result in
                switch result {
                case .success(let data):
                    continuation.resume(returning: data)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func processPreview(_ data: Data) -> PageCollectionCellViewModel? {
        guard let image = UIImage(data: data) else { return nil }
        
        return createCellViewModel(previewImage: image)
    }
    
    private func processPreview(_ result: Result<Data, GiniError>) -> PageCollectionCellViewModel? {
        switch result {
        case let .success(dataImage):
            if let image = UIImage(data: dataImage) {
                return createCellViewModel(previewImage: image)
            }
        case let .failure(error):
            if delegate?.shouldHandleErrorInternally(error: error) == true {
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
                                        secondaryButtonConfiguration: secondaryButtonConfiguration,
                                        defaultStyleInputFieldConfiguration: defaultStyleInputFieldConfiguration,
                                        errorStyleInputFieldConfiguration: errorStyleInputFieldConfiguration,
                                        selectionStyleInputFieldConfiguration: selectionStyleInputFieldConfiguration,
                                        poweredByGiniConfiguration: poweredByGiniConfiguration,
                                        poweredByGiniStrings: poweredByGiniStrings,
                                        displayMode: displayMode,
                                        clientConfiguration: clientConfiguration)
    }
}

extension PaymentReviewModel: InstallAppBottomViewProtocol {
    public func didTapOnContinue() {
        viewModelDelegate?.createPaymentRequestAndOpenBankApp()
    }
}

extension PaymentReviewModel: ShareInvoiceBottomViewProtocol {
    public func didTapOnContinueToShareInvoice(paymentRequestId: String) {
        viewModelDelegate?.obtainPDFFromPaymentRequest(paymentRequestId: paymentRequestId)
    }
}

extension PaymentReviewModel: BanksSelectionProtocol {
    /**
     Called when a payment provider is selected by the user.
     
     - Parameters:
       - paymentProvider: The `PaymentProvider` object representing the selected payment provider.
       - documentId: An optional `String` identifier for the document associated id with this payment. If `nil`, no document is associated.
     
     This function updates the current selected payment provider, notifies the delegate of the new provider,
     and triggers any associated callback for handling the change in payment provider.
     */
    public func didSelectPaymentProvider(paymentProvider: GiniHealthAPILibrary.PaymentProvider) {
        selectedPaymentProvider = paymentProvider
        delegate?.updatedPaymentProvider(paymentProvider)
        onNewPaymentProvider?()
    }

    /**
     Called when the user taps on the "More Information" button was tapped on BanksSelection view
     
     This function notifies the delegate to open the "More Information" view controller.
     */
    public func didTapOnMoreInformation() {
        previousPaymentComponentScreenType = .bankPicker
        delegate?.openMoreInformationViewController()
    }

    public func didTapOnClose() {
        // This method will remain empty; no implementation is needed.
    }

    public func didTapOnContinueOnShareBottomSheet() {
        // This method will remain empty; no implementation is needed.
    }

    public func didTapForwardOnInstallBottomSheet() {
        // This method will remain empty; no implementation is needed.
    }

    public func didTapOnPayButton() {
        // This method will remain empty; no implementation is needed.
    }

}

/**
 View model class for collection view cell

 */
public struct PageCollectionCellViewModel {
    let preview: UIImage
}
