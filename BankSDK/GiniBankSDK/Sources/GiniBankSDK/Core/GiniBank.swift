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
 Core class for Gini Bank SDK.
 */
@objc public final class GiniBank: NSObject {
    /// reponsible for interaction with Gini Bank backend.
    public var giniApiLib: GiniBankAPI
    /// reponsible for the payment processing.
    public var paymentService: PaymentService

    private var documentService: DefaultDocumentService {
        return giniApiLib.documentService()
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

    // MARK: - Transaction Docs demo

    public func documentPagesRequest(documentId: String,
                                     completion: @escaping ([UIImage], GiniError?) -> Void) {

        loadDocumentPages(for: documentId, completion: completion)
    }

    public func documentExtractionsRequest(documentId: String,
                                           completion: @escaping (ExtractionResult?, GiniError?) -> Void) {

        getDocumentExtractions(for: documentId) { result in
            switch result {
            case let .success(extractionResult):
                print("Finished analysis process with no errors")
                    completion(extractionResult, nil)
            case let .failure(error):
                if error == .requestCancelled {
                    print("Cancelled analysis process with error")
                } else {
                    print("Finished analysis process with error: \(error)")
                }
                completion(nil, error)
            }
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

fileprivate extension GiniBank {
    private func loadDocumentPages(for documentId: String, completion: @escaping ([UIImage], GiniError?) -> Void) {
        getDocumentPages(for: documentId) { [weak self] result in
            guard let self = self else {
                completion([], nil)
                return
            }

            switch result {
            case .success(let pages):
                self.loadAllPages(for: documentId,
                                  pages: pages) { images, error in
                    completion(images, error)
                }
            case .failure(let error):
                completion([], error)
            }
        }
    }

    private func loadAllPages(for documentId: String,
                              pages: [Document.Page],
                              completion: @escaping ([UIImage], GiniError?) -> Void) {
        var images: [UIImage] = []
        var loadError: GiniError?

        func loadPage(at index: Int) {
            guard index < pages.count else {
                completion(images, nil)
                return
            }

            let page = pages[index]
            loadDocumentPage(for: documentId,
                             startingAt: page.number,
                             size: page.images[0].size) { pageImage, errors in
                if let firstError = errors.first {
                    loadError = firstError
                    completion([], loadError)
                } else {
                    images.append(pageImage)
                    loadPage(at: index + 1) // Load the next page
                }
            }
        }

        // Start loading the first page
        loadPage(at: 0)
    }

    private func loadDocumentPage(for documentId: String,
                                  startingAt pageNumber: Int,
                                  size: Document.Page.Size,
                                  completion: @escaping (UIImage, [GiniError]) -> Void) {
        var errors = [GiniError]()
        getDocumentPage(for: documentId,
                        pageNumber: pageNumber,
                        size: size) { result in
            switch result {
            case.success(let image):
                if let image {
                    completion(image, [])
                }
            case.failure(let error):
                errors.append(error)
                completion(UIImage(), errors)
            }
        }
    }

    private func getDocumentPages(for documentId: String,
                                  completion: @escaping (Result<[Document.Page], GiniError>) -> Void) {
        documentService.pages(for: documentId, completion: completion)
    }

    private func getDocumentPage(for documentId: String,
                                 pageNumber: Int,
                                 size: Document.Page.Size,
                                 completion: @escaping (Result<UIImage?, GiniError>) -> Void) {

        documentService.documentPage(for: documentId, pageNumber: pageNumber,
                                     size: size) { result in
            switch result {
            case let .success(data):
                DispatchQueue.main.async {
                    // Convert the data to a UIImage
                    if let image = UIImage(data: data) {
                        // Successfully created an image
                        completion(.success(image))
                    } else {
                        // Failed to create an image
                        print("Failed to create image from data")
                        completion(.success(nil))
                    }
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    private func getDocumentExtractions(for documentId: String,
                                        completion: @escaping (Result<ExtractionResult, GiniError>) -> Void) {
        documentService.extractions(for: documentId, completion: completion)
    }
}
