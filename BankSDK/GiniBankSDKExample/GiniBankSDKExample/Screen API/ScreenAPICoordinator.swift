//
//  ScreenAPICoordinator.swift
//  Example Swift
//
//  Created by Nadya Karaban on 19.02.21.
//

import Foundation
import UIKit
import GiniBankAPILibrary
import GiniBankSDK
import GiniCaptureSDK

protocol ScreenAPICoordinatorDelegate: AnyObject {
    func screenAPI(coordinator: ScreenAPICoordinator, didFinish:())
    func screenAPIShowNoResults(coordinator: ScreenAPICoordinator)
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
    var sendFeedbackBlock: (([String: Extraction]) -> Void)?
    var extractionsForFeedback: [String: Extraction]?
    var manuallyCreatedDocument: Document?
	private var extractedResults: [Extraction] = []
	
	// {extraction name} : {entity name}
	private let editableSpecificExtractions = ["paymentRecipient" : "companyname", "paymentReference" : "reference", "paymentPurpose" : "text", "iban" : "iban", "bic" : "bic", "amountToPay" : "amount"]

    
    init(configuration: GiniBankConfiguration,
         importedDocuments documents: [GiniCaptureDocument]?,
         client: Client,
         documentMetadata: Document.Metadata?) {
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
                                                 api: .default,
                                                 userApi: .default,
                                                 trackingDelegate: trackingDelegate)
// MARK: - Screen API with custom networking
//        let viewController = GiniBank.viewController(importedDocuments: visionDocuments,
//                                                        configuration: configuration,
//                                                        resultsDelegate: self,
//                                                        documentMetadata: documentMetadata,
//                                                        trackingDelegate: trackingDelegate,
//                                                        networkingService: self)
// MARK: - Screen API - UI Only
//        let viewController = GiniBank.viewController(withDelegate: self, withConfiguration: configuration)

        screenAPIViewController = RootNavigationController(rootViewController: viewController)
        screenAPIViewController.navigationBar.barTintColor = configuration.navigationBarTintColor
        screenAPIViewController.navigationBar.tintColor = configuration.navigationBarTitleColor
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
            .instantiateViewController(withIdentifier: "resultScreen") as? ResultTableViewController)!
        customResultsScreen.result = results
		customResultsScreen.editableFields = editableSpecificExtractions
        customResultsScreen.navigationItem.setHidesBackButton(true, animated: true)
        let title =
        NSLocalizedStringPreferredFormat("results.sendfeedback.button.title", fallbackKey: "Send feedback and close", comment: "title for send feedback button", isCustomizable: true)
        customResultsScreen.navigationItem
            .rightBarButtonItem = UIBarButtonItem(title: title,
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(closeSreenAPIAndSendFeedback))
        DispatchQueue.main.async { [weak self] in
            if #available(iOS 15.0, *) {
                let config = self?.configuration.captureConfiguration()
                 self?.screenAPIViewController.applyStyle(withConfiguration: config ?? GiniConfiguration())
             }
            self?.screenAPIViewController.setNavigationBarHidden(false, animated: false)
            
            self?.screenAPIViewController.pushViewController(customResultsScreen, animated: true)
        }
    }
    
    @objc private func closeSreenAPIAndSendFeedback() {
        if let sendFeedbackBlock = sendFeedbackBlock, let extractionsForFeedback = extractionsForFeedback {
            print("💬 Sending extractions feedback")
            sendFeedbackBlock(extractionsForFeedback)
        } else {
            print("❌ Extractions feedback was not sent")
        }
        delegate?.screenAPI(coordinator: self, didFinish: ())
    }
}

// MARK: - GiniCaptureResultsDelegate
extension ScreenAPICoordinator: GiniCaptureResultsDelegate {
    
    func giniCaptureAnalysisDidFinishWith(result: AnalysisResult,
                                         sendFeedbackBlock: @escaping ([String: Extraction]) -> Void) {
        showResultsScreen(results: result.extractions.map { $0.value}, document: result.document)
        self.extractionsForFeedback = result.extractions
        self.sendFeedbackBlock = sendFeedbackBlock
    }
    
    func giniCaptureDidCancelAnalysis() {
        delegate?.screenAPI(coordinator: self, didFinish: ())
    }
    
    func giniCaptureAnalysisDidFinishWithoutResults(_ showingNoResultsScreen: Bool) {
        if !showingNoResultsScreen {
            delegate?.screenAPIShowNoResults(coordinator: self)
        }
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
        let extractionResult = ExtractionResult.init(extractions: [extractionPaymentPurpose,extractionAmountToPay,extractionIban,extractionPaymentRecipient], lineItems: [lineItem, lineItem] , returnReasons: [], candidates: [:])
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
