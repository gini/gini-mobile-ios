//
//  ScreenAPICoordinator.swift
//  Example Swift
//
//  Created by Nadya Karaban on 19.02.21.
//

import UIKit
import GiniBankAPILibrary
import GiniBankSDK
import GiniCaptureSDK

protocol ScreenAPICoordinatorDelegate: AnyObject {
    func screenAPI(coordinator: ScreenAPICoordinator, didFinish:())
    func didRequestRescan(coordinator: ScreenAPICoordinator)
}

class TrackingDelegate: GiniCaptureTrackingDelegate {
    
    
    func onAnalysisScreenEvent(event: Event<AnalysisScreenEventType>) {
        print("✏️ Analysis: \(event.type.rawValue), info: \(event.info ?? [:])")
    }
    
    func onOnboardingScreenEvent(event: Event<OnboardingScreenEventType>) {
        print("✏️ Onboarding: \(event.type.rawValue)")
    }
    
    func onCameraScreenEvent(event: Event<CameraScreenEventType>) {
        print("✏️ Camera: \(event.type.rawValue)")
    }
    
    func onReviewScreenEvent(event: Event<ReviewScreenEventType>) {
        print("✏️ Review: \(event.type.rawValue)")
    }
}

final class ScreenAPICoordinator: NSObject, Coordinator, UINavigationControllerDelegate {
    weak var resultsDelegate: GiniCaptureResultsDelegate?
    weak var delegate: ScreenAPICoordinatorDelegate?
    var childCoordinators: [Coordinator] = []
    var rootViewController: UIViewController {
        return screenAPIViewController
    }
    var screenAPIViewController: UINavigationController!
    var trackingDelegate = TrackingDelegate()
    let client: Client
    let documentMetadata: Document.Metadata?
    weak var analysisDelegate: GiniBankAnalysisDelegate?
    var visionDocuments: [GiniCaptureDocument]?
    var configuration: GiniBankConfiguration
    var manuallyCreatedDocument: Document?
	private var extractedResults: [Extraction] = []
	
	// {extraction name} : {entity name}
	private let editableSpecificExtractions = ["paymentRecipient" : "companyname",
											   "paymentReference" : "reference",
											   "paymentPurpose" : "text",
											   "iban" : "iban",
											   "bic" : "bic",
											   "amountToPay" : "amount",
                                               "instantPayment" : "instantPayment"]
    
    private let apiEnvironment: APIEnvironment

    init(apiEnvironment: APIEnvironment,
         configuration: GiniBankConfiguration,
         importedDocuments documents: [GiniCaptureDocument]?,
         client: Client,
         documentMetadata: Document.Metadata?) {
        self.apiEnvironment = apiEnvironment
        self.configuration = configuration
        self.visionDocuments = documents
        self.client = client
        self.documentMetadata = documentMetadata
        super.init()
    }
    
    func start() {
        
// MARK: - Screen API with default networking
    let viewController = GiniBank.viewController(withClient: client,
                                                 importedDocuments: visionDocuments,
                                                 configuration: configuration,
                                                 resultsDelegate: self,
                                                 documentMetadata: documentMetadata,
                                                 api: apiEnvironment.api,
                                                 userApi: apiEnvironment.userApi,
                                                 trackingDelegate: trackingDelegate)
// MARK: - Screen API with custom networking
//        let viewController = GiniBank.viewController(importedDocuments: visionDocuments,
//                                                     configuration: configuration,
//                                                     resultsDelegate: self,
//                                                     documentMetadata: documentMetadata,
//                                                     trackingDelegate: trackingDelegate,
//                                                     networkingService: self,
//                                                     configurationService: nil)
// MARK: - Screen API - UI Only
//        let viewController = GiniBank.viewController(withDelegate: self, withConfiguration: configuration)

        screenAPIViewController = RootNavigationController(rootViewController: viewController)
        screenAPIViewController.setNavigationBarHidden(true, animated: false)
        screenAPIViewController.delegate = self
        screenAPIViewController.interactivePopGestureRecognizer?.delegate = nil
    }
    
    fileprivate func showResultsScreen(results: [Extraction], document: Document?) {
        if let document = document {
            print("🧾 Showing results for Gini Bank API document id: \(document.id)")
        } else {
            print("❓ Showing results for unknown Gini Bank API document")
        }
        
        let customResultsScreen = (UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "resultScreen") as? TransactionSummaryTableViewController)!

        customResultsScreen.delegate = self

        configuration.transactionDocsDataCoordinator.presentingViewController = customResultsScreen
        customResultsScreen.result = results
        // This option is unavailable for cross-border transactions
//		customResultsScreen.editableFields = editableSpecificExtractions

        DispatchQueue.main.async { [weak self] in
            if #available(iOS 15.0, *) {
                if let config = self?.configuration.captureConfiguration(),
                   config.customNavigationController == nil {
                    self?.screenAPIViewController.applyStyle(withConfiguration: config)
                }
            }
            self?.screenAPIViewController.setNavigationBarHidden(false, animated: false)
            
            self?.screenAPIViewController.pushViewController(customResultsScreen, animated: true)
        }
    }
    
    private func closeSreenAPIAndSendTransferSummary() {
        var extractionAmount = ExtractionAmount(value: 0.0, currency: .EUR)
        var extractionAmountString = ""
        if let amountValue = extractedResults.first(where: { $0.name == "amountToPay"})?.value {
            if amountValue.split(separator: ":").count > 0 {
                let value = Decimal(string: String(amountValue.split(separator: ":")[0])) ?? 0.0
                extractionAmount = ExtractionAmount(value: value,
                                                    currency: .EUR)
                extractionAmountString = "\(amountValue.split(separator: ":")[0]) EUR"
            }
        }

        let paymentRecipient = extractedResults.first(where: { $0.name == "paymentRecipient"})?.value ?? ""
        let paymentReference = extractedResults.first(where: { $0.name == "paymentReference"})?.value ?? ""
        let paymentPurpose = extractedResults.first(where: { $0.name == "paymentPurpose"})?.value ?? ""
        let iban = extractedResults.first(where: { $0.name == "iban"})?.value ?? ""
        let bic = extractedResults.first(where: { $0.name == "bic"})?.value ?? ""

        // `instantPayment` is currently a String, but it should be a Bool.
        // In GiniSDK, this parameter must be a Boolean to restrict the possible values
        // and ensure the correct data type is sent in the transfer summary to the backend.
        let instantPaymentString = extractedResults.first(where: { $0.name == "instantPayment"})?.value ?? ""
        let amoutToPay = extractionAmount
        configuration.sendTransferSummary(paymentRecipient: paymentRecipient,
                                          paymentReference: paymentReference,
                                          paymentPurpose: paymentPurpose,
                                          iban: iban,
                                          bic: bic,
                                          amountToPay: amoutToPay,
                                          instantPayment: instantPaymentString.lowercased() == "true")

        // GiniBankSDK requires both `documentId` and `originalFileName`
        // to properly display attachment information in the transaction details screen.
        // Example usage in `TransactionListViewController`:
        //
        // GiniTransactionDoc(
        //     documentId: documentId,
        //     originalFileName: filename
        // )

        let attachments = configuration.transactionDocsDataCoordinator.transactionDocs.map {
            return Attachment(documentId: $0.documentId,
                              filename: $0.fileName,
                              type: $0.isFile ? .document : .image)
        }

        let transaction = Transaction(date: Date(),
                                      paidAmount: extractionAmountString,
                                      paymentPurpose: paymentPurpose,
                                      paymentRecipient: paymentRecipient,
                                      iban: iban,
                                      paymentReference: paymentReference,
                                      attachments: attachments)
        updateJSONFileWithTransaction(transaction)

        configuration.cleanup()

        delegate?.screenAPI(coordinator: self, didFinish: ())
    }

    private func updateJSONFileWithTransaction(_ transaction: Transaction) {
        let fileManager = FileManagerHelper(fileName: "transaction_list.json")

        // Read transactions (automatically creates an empty file if it doesn't exist)
        let _: [Transaction] = fileManager.read()
        fileManager.append([transaction])
    }

    private func showAlertOnDidEnterManually(){
        let alert = UIAlertController(title: "GiniCaptureResultsDelegate was called",
                                      message: nil,
                                      preferredStyle: .alert)

        let ok = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.rootViewController.dismiss(animated: true)
        }

        alert.addAction(ok)
        rootViewController.present(alert, animated: true)
    }
}
// MARK: - TransactionSummaryTableViewControllerDelegate
extension ScreenAPICoordinator: TransactionSummaryTableViewControllerDelegate {
    func didTapToScanAgain() {
        configuration.cleanup()
        delegate?.didRequestRescan(coordinator: self)
    }
    
    func didTapCloseAndSendTransferSummary() {
        closeSreenAPIAndSendTransferSummary()
    }
}

// MARK: - GiniCaptureResultsDelegate
extension ScreenAPICoordinator: GiniCaptureResultsDelegate {

    func giniCaptureDidEnterManually() {
        showAlertOnDidEnterManually()
    }
    
    func giniCaptureAnalysisDidFinishWith(result: AnalysisResult) {
//		extractedResults = result.extractions.map { $0.value}
        extractedResults = []

//		for extraction in editableSpecificExtractions {
//			if (extractedResults.first(where: { $0.name == extraction.key }) == nil) {
//				extractedResults.append(Extraction(box: nil, candidates: nil, entity: extraction.value, value: "", name: extraction.key))
//			}
//		}
        
//        // Add cross-border payment extractions
//        if let crossBorderGroups = result.crossBorderPayment {
//            for group in crossBorderGroups {
//                for extraction in group {
//                    // Only add if not already present
//                    if extractedResults.first(where: { $0.name == extraction.name }) == nil {
//                        extractedResults.append(extraction)
//                    }
//                }
//            }
//        }
        
        
        
        if let crossBorderGroups = result.crossBorderPayment {
               for group in crossBorderGroups {
                   for extraction in group {
                       extractedResults.append(extraction)
                   }
               }
           }
        showResultsScreen(results: extractedResults, document: result.document)
    }
    
    func giniCaptureDidCancelAnalysis() {
        delegate?.screenAPI(coordinator: self, didFinish: ())
    }
}

// MARK: - Screen API with custom networking GiniCaptureNetworkService
extension ScreenAPICoordinator: GiniCaptureNetworkService {
    func delete(document: Document, completion: @escaping (Result<String, GiniError>) -> Void) {
        print("💻 custom networking - delete document event called")
    }
    
    func cleanup() {
        print("💻 custom networking - cleanup event called")
    }
    
    func analyse(partialDocuments: [PartialDocumentInfo], metadata: Document.Metadata?, cancellationToken: CancellationToken, completion: @escaping (Result<(document: Document, extractionResult: ExtractionResult), GiniError>) -> Void) {
        print("💻 custom networking - analyse documents event called")
        
        let extractionPaymentPurpose = Extraction.init(box: nil, candidates: nil, entity: "text", value: "20980000", name: "paymentPurpose")
        let extractionAmountToPay = Extraction.init(box: nil, candidates: "amounts", entity: "amount", value: "12.00:EUR", name: "amountToPay")
        let extractionIban = Extraction.init(box: nil, candidates: "ibans", entity: "amount", value: "DE74700500000000028273", name: "iban")
        let extractionPaymentRecipient = Extraction.init(box: nil, candidates: nil, entity: "text", value: "Deutsche Post AG", name: "paymentRecipient")
        let extractionsBaseGross = Extraction.init(box: nil, candidates: "", entity: "amount", value: "14.99:EUR", name: "baseGross")
        let extractionDescription = Extraction.init(box: nil, candidates: "", entity: "text", value: "T-Shirt, black Size S", name: "description")
        let extractionArtNumber = Extraction.init(box: nil, candidates: "", entity: "text", value: "10101", name: "artNumber")
        let extractionQuantity = Extraction.init(box: nil, candidates: "", entity: "numeric", value: "1", name: "quantity")

        let lineItem = [extractionQuantity, extractionsBaseGross, extractionDescription, extractionArtNumber]
        let extractionResult = ExtractionResult.init(extractions: [extractionPaymentPurpose, extractionAmountToPay, extractionIban, extractionPaymentRecipient],
                                                     lineItems: [lineItem, lineItem],
                                                     returnReasons: [],
                                                     candidates: [:])
        if let doc = self.manuallyCreatedDocument {
            let result = (document: doc, extractionResult: extractionResult)
            completion(.success(result))
        } else {
            completion(.failure(.noResponse))
        }
    }
    
    func upload(document: GiniCaptureDocument, metadata: Document.Metadata?, completion: @escaping UploadDocumentCompletion) {
        print("💻 custom networking - upload document event called")
        let creationDate = Date()
        if let defaultUrl = URL.init(string: "https://pay-api.gini.net/documents/3008db90-c499-11ec-a6b8-d5d497bfXXXX") {
            let links = Document.Links.init(giniAPIDocumentURL: defaultUrl)
            let manuallyCreatedDoc = Document.init(creationDate: creationDate, id: "3008db90-c499-11ec-a6b8-d5d497bfXXXX", name: "manuallyCreatedDocument", links: links, sourceClassification: .scanned)
            self.manuallyCreatedDocument = manuallyCreatedDoc
            completion(.success(manuallyCreatedDoc))
        } else {
            completion(.failure(.noResponse))
        }
    }
    
    func sendFeedback(document: Document, updatedExtractions: [Extraction], updatedCompoundExtractions: [String : [[Extraction]]]?, completion: @escaping (Result<Void, GiniError>) -> Void) {
        print("💻 custom networking - send feedback event called")
    }
    
    func log(errorEvent: ErrorEvent, completion: @escaping (Result<Void, GiniError>) -> Void) {
        print("💻 custom networking - log error event called")
    }
}

// MARK: Screen API - UI Only - GiniCaptureDelegate

extension ScreenAPICoordinator: GiniCaptureDelegate {

    func didPressEnterManually() {
        // Add your  implementation
    }
    
    func didCapture(document: GiniCaptureDocument, networkDelegate: GiniCaptureNetworkDelegate) {
        // Add your  implementation
    }
    
    func didReview(documents: [GiniCaptureDocument], networkDelegate: GiniCaptureNetworkDelegate) {
        // Add your  implementation
    }
    
    func didCancelCapturing() {
        // Add your  implementation
    }
    
    func didCancelReview(for document: GiniCaptureDocument) {
        // Add your  implementation
    }
    
    func didCancelAnalysis() {
        // Add your  implementation
    }
}
