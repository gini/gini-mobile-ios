//
// GiniBank.swift
// GiniBank
//
//  Created by Nadya Karaban on 18.02.21.
//

import UIKit
import GiniBankAPILibrary
import GiniCaptureSDK

/**
 Core class for the Gini Bank SDK, providing functionalities for document handling and payment processing.
 */
@objc public final class GiniBank: NSObject {

    /// Handles interaction with the Gini Bank backend.
    public var giniApiLib: GiniBankAPI

    /// Provides services for payment processing.
    public var paymentService: PaymentService

    private var documentService: DefaultDocumentService {
        return giniApiLib.documentService()
    }

    private var documentId: String?
    
    // Cast the coordinator to the internal protocol to access internal properties and methods
    private var internalTransactionDocsDataCoordinator: TransactionDocsDataInternalProtocol? {
        return GiniBankConfiguration.shared.transactionDocsDataCoordinator as? TransactionDocsDataInternalProtocol
    }
    /**
     Returns a GiniBank instance

     - parameter giniApiLib: GiniBankAPI initialized with client's credentials
     */
    public init(with giniApiLib: GiniBankAPI) {
        self.giniApiLib = giniApiLib
        paymentService = giniApiLib.paymentService()
    }

    // MARK: - Gini Pay Connect

    /**
     Fetches the payment request via payment request id.

     - parameter paymentRequestId: Id of payment request.
     - parameter completion: An action for processing asynchronous data received from the service with Result type as a paramater. Result is a value that represents either a success or a failure, including an associated value in each case.
     Completion block called on main thread.
     In success returns the payment request structure.
     In case of failure error from the server side.

     */
    public func receivePaymentRequest(paymentRequestId: String,
                                      completion: @escaping (Result<PaymentRequest, GiniBankError>) -> Void) {
        paymentService.paymentRequest(id: paymentRequestId) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(paymentRequest):
                    completion(.success(paymentRequest))
                case let .failure(error):
                    completion(.failure(.apiError(error)))
                }
            }
        }
    }

    /**
     Resolves the payment via payment request id.
     **Important**: The amount string in the `PaymentInfo` must be convertible to a `Double`.
           * For ex. "12.39" is valid, but "12.39 €" or "12,39" are not valid.
     - parameter paymentRequesId: Id of payment request.
     - parameter completion: An action for processing asynchronous data received from the service with Result type as a paramater. Result is a value that represents either a success or a failure, including an associated value in each case.
     Completion block called on main thread.
     In success returns the resolved payment request structure.
     In case of failure error from the server side.
     If the amount string could not be parsed throws `amountParsingError`

     */
    public func resolvePaymentRequest(paymentRequesId: String,
                                      paymentInfo: PaymentInfo,
                                      completion: @escaping (Result<ResolvedPaymentRequest, GiniBankError>) -> Void) {
        var amountString: String?
        do {
            amountString = try String.parseAmountStringToBackendFormat(string: paymentInfo.amount)
        } catch let error as GiniBankError {
            completion(.failure(error))
        } catch {
            assertionFailure("Unexpected error: \(error)")
        }
        guard let amountString = amountString else {
            return
        }
        paymentService.resolvePaymentRequest(id: paymentRequesId,
                                             recipient: paymentInfo.recipient,
                                             iban: paymentInfo.iban,
                                             amount: amountString,
                                             purpose: paymentInfo.purpose,
                                             completion: { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(resolvedPayment):
                    completion(.success(resolvedPayment))
                case let .failure(error):
                    completion(.failure(.apiError(error)))
                }
            }
        })
    }

    /**
     Returns back to the business app.

     - parameter resolvedPaymentRequest: resolved payment request returned by method 'resolvePaymentRequest'

     */
    public func returnBackToBusinessAppHandler(resolvedPaymentRequest: ResolvedPaymentRequest) {
        if let resultUrl = URL(string: resolvedPaymentRequest.requesterUri) {
            DispatchQueue.main.async {
                UIApplication.shared.open(resultUrl, options: [:], completionHandler: nil)
            }
        }
    }

    // MARK: - Transaction Docs

    /**
     Initiates the process of loading transaction document data.

     - Parameter documentId: The identifier of the document to process.
     */
    public func handleTransactionDocsDataLoading(for documentId: String) {
        self.documentId = documentId
        internalTransactionDocsDataCoordinator?.loadDocumentData = { [weak self] in
            self?.processTransactionDocs(for: documentId)
        }
    }

    // MARK: - Screen API without Networking - Initializers for 'UIViewController'

    /**
     Returns a view controller which will handle the analysis process.

     - parameter delegate: An instance conforming to the `GiniCaptureDelegate` protocol.
     - parameter importedDocuments: Documents that come from a source different than `CameraViewController`.
     There should be either images or one PDF, and they should be validated before calling this method.

     - returns: A presentable view controller.
     */
    @objc public class func viewController(withDelegate delegate: GiniCaptureDelegate,
                                           importedDocuments: [GiniCaptureDocument]? = nil) -> UIViewController {

        let screenCoordinator = GiniScreenAPICoordinator(withDelegate: delegate,
                                                         giniConfiguration:
                                                            GiniBankConfiguration.shared.captureConfiguration())

        return screenCoordinator.start(withDocuments: importedDocuments)
    }

    /**
     Returns a view controller which will handle the analysis process.

     - parameter delegate: An instance conforming to the `GiniCaptureDelegate` protocol.
     - parameter importedDocuments: Documents that come from a source different than `CameraViewController`.
     There should be either images or one PDF, and they should be validated before calling this method.
     - parameter trackingDelegate: A delegate object to receive user events

     - returns: A presentable view controller.
     */
    public class func viewController(withDelegate delegate: GiniCaptureDelegate,
                                     importedDocuments: [GiniCaptureDocument]? = nil,
                                     trackingDelegate: GiniCaptureTrackingDelegate? = nil) -> UIViewController {
        let configuration = GiniBankConfiguration.shared.captureConfiguration()
        let screenCoordinator = GiniScreenAPICoordinator(withDelegate: delegate,
                                                         giniConfiguration: configuration)
        screenCoordinator.trackingDelegate = trackingDelegate

        return screenCoordinator.start(withDocuments: importedDocuments)
    }

    /**
     Returns a view controller which will handle the analysis process.

     - parameter delegate: An instance conforming to the `GiniCaptureDelegate` protocol.
     - parameter importedDocument: Documents that come from a source different than CameraViewController.
     There should be either images or one PDF, and they should be validated before calling this method.

     - returns: A presentable view controller.
     */
    @objc public class func viewController(withDelegate delegate: GiniCaptureDelegate,
                                           importedDocument: GiniCaptureDocument? = nil) -> UIViewController {
        var documents: [GiniCaptureDocument]?
        if let importedDocument = importedDocument {
            documents = [importedDocument]
        }

        return viewController(withDelegate: delegate, importedDocuments: documents)
    }

    /**
     Returns a view controller which will handle the analysis process.

     - parameter delegate: An instance conforming to the `GiniCaptureDelegate` protocol.
     - parameter importedDocument: Documents that come from a source different than CameraViewController.
     There should be either images or one PDF, and they should be validated before calling this method.
     - parameter trackingDelegate: A delegate object to receive user events

     - returns: A presentable view controller.
     */
    public class func viewController(withDelegate delegate: GiniCaptureDelegate,
                                     importedDocument: GiniCaptureDocument?,
                                     trackingDelegate: GiniCaptureTrackingDelegate?) -> UIViewController {
        var documents: [GiniCaptureDocument]?
        if let importedDocument = importedDocument {
            documents = [importedDocument]
        }

        return viewController(withDelegate: delegate, importedDocuments: documents, trackingDelegate: trackingDelegate)
    }

    /**
     Returns a view controller which will handle the analysis process.
     Allows to set a custom configuration to change the look and feel of the  Gini Bank SDK.

     - parameter delegate:      An instance conforming to the `GiniCaptureDelegate` protocol.
     - parameter configuration: The bank configuration to set.
     - parameter importedDocument: Documents that come from a source different than CameraViewController.
     There should be either images or one PDF, and they should be validated before calling this method.

     - returns: A presentable view controller.
     */
    @objc public class func viewController(withDelegate delegate: GiniCaptureDelegate,
                                           withConfiguration configuration: GiniBankConfiguration,
                                           importedDocument: GiniCaptureDocument? = nil) -> UIViewController {
        GiniBank.setConfiguration(configuration)
        return viewController(withDelegate: delegate, importedDocument: importedDocument)
    }

    /**
     Returns a view controller which will handle the analysis process.
     Allows to set a custom configuration to change the look and feel of the Gini Bank SDK.

     - parameter delegate:      An instance conforming to the `GiniCaptureDelegate` protocol.
     - parameter configuration: The configuration to set.
     - parameter importedDocument: Documents that come from a source different than CameraViewController.
     There should be either images or one PDF, and they should be validated before calling this method.
     - parameter trackingDelegate: A delegate object to receive user events

     - returns: A presentable view controller.
     */
    public class func viewController(withDelegate delegate: GiniCaptureDelegate,
                                     withConfiguration configuration: GiniBankConfiguration,
                                     importedDocument: GiniCaptureDocument? = nil,
                                     trackingDelegate: GiniCaptureTrackingDelegate? = nil) -> UIViewController {
        GiniBank.setConfiguration(configuration)
        return viewController(withDelegate: delegate,
                              importedDocument: importedDocument,
                              trackingDelegate: trackingDelegate)
    }

    /**
     Sets a configuration which is used to customize the look and feel of the Gini Bank SDK,
     for example to change texts and colors displayed to the user.

     - parameter configuration: The bank configuration to set.
     */
    @objc public class func setConfiguration(_ configuration: GiniBankConfiguration) {
        GiniBankConfiguration.shared = configuration
        let captureConfiguration = GiniBankConfiguration.shared.captureConfiguration()
        GiniCapture.setConfiguration(captureConfiguration)
    }
}

extension GiniBank: DocumentPagesProvider {
    func getDocumentPages(completion: @escaping (Result<[Document.Page], GiniError>) -> Void) {
        guard let documentId else { return }
        documentService.pages(for: documentId, completion: completion)
    }

    func getDocumentPage(for pageNumber: Int,
                         size: Document.Page.Size,
                         completion: @escaping (Result<Data, GiniError>) -> Void) {
        guard let documentId else { return }
        documentService.documentPage(for: documentId,
                                     pageNumber: pageNumber,
                                     size: size,
                                     completion: completion)
    }
}
//
// MARK: - Private Methods
fileprivate extension GiniBank {

    private func processTransactionDocs(for documentId: String) {
        guard let viewModel = internalTransactionDocsDataCoordinator?.getTransactionDocsViewModel(),
              let images = viewModel.cachedImages[documentId], !images.isEmpty else {
            loadDocumentData(for: documentId)
            return
        }

        loadDocumentExtractions(for: documentId) { extractions in
            DispatchQueue.main.async { [weak self] in
                self?.internalTransactionDocsDataCoordinator?.updateTransactionDocsViewModel(with: images,
                                                                                             extractions: extractions,
                                                                                             for: documentId)
            }
        }
    }

    private func loadDocumentData(for documentId: String) {
        let dispatchGroup = DispatchGroup()
        var extractedData: [Extraction] = []
        var documentImages: [UIImage] = []
        var documentPagesError: GiniError?

        dispatchGroup.enter()
        DocumentServiceHelper.fetchDocumentPages(from: self) { result in
            switch result {
            case .success(let images):
                documentImages = images
            case .failure(let error):
                documentPagesError = error
            }
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        loadDocumentExtractions(for: documentId) { extractions in
            extractedData = extractions
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            if let error = documentPagesError {
                self.handlePreviewDocumentError(error: error)
            } else {
                self.internalTransactionDocsDataCoordinator?.updateTransactionDocsViewModel(
                    with: documentImages,
                    extractions: extractedData,
                    for: documentId
                )
            }
        }
    }

    private func loadDocumentExtractions(for documentId: String,
                                         completion: @escaping ([Extraction]) -> Void) {
        fetchDocumentExtractions(for: documentId) { result in
            switch result {
            case.success(let extractionResult):
                completion(extractionResult.extractions)
            case.failure:
                completion([])
            }
        }
    }

    private func handlePreviewDocumentError(error: GiniError) {
        internalTransactionDocsDataCoordinator?
            .getTransactionDocsViewModel()?
            .setPreviewDocumentError(error: error) {
                self.internalTransactionDocsDataCoordinator?.loadDocumentData?()
            }
    }

    private func fetchDocumentExtractions(for documentId: String,
                                          completion: @escaping (Result<ExtractionResult, GiniError>) -> Void) {
        documentService.extractions(for: documentId, completion: completion)
    }
}
