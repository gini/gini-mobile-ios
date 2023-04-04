//
//  ScreenAPICoordinator.swift
//  GiniCapture_Example
//
//  Created by Enrique del Pozo Gómez on 11/10/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation
import GiniBankAPILibrary
import GiniCaptureSDK
import UIKit

protocol ScreenAPICoordinatorDelegate: AnyObject {
    func screenAPI(coordinator: ScreenAPICoordinator, didFinish: ())
}

final class ScreenAPICoordinator: NSObject, Coordinator {
    weak var delegate: ScreenAPICoordinatorDelegate?
    var childCoordinators: [Coordinator] = []
    var rootViewController: UIViewController {
        return screenAPIViewController
    }

    var screenAPIViewController: UINavigationController!

    let client: Client
    let documentMetadata: Document.Metadata?
    weak var analysisDelegate: AnalysisDelegate?
    var visionDocuments: [GiniCaptureDocument]?
    var visionConfiguration: GiniConfiguration
	private var extractedResults: [Extraction] = []
	
	// {extraction name} : {entity name}
	private let editableSpecificExtractions = ["paymentRecipient" : "companyname", "paymentReference" : "reference", "paymentPurpose" : "text", "iban" : "iban", "bic" : "bic", "amountToPay" : "amount"]

    init(configuration: GiniConfiguration,
         importedDocuments documents: [GiniCaptureDocument]?,
         client: Client,
         documentMetadata: Document.Metadata?) {
        visionConfiguration = configuration
        visionDocuments = documents
        self.client = client
        self.documentMetadata = documentMetadata
        super.init()
    }

    func start() {
        let viewController = GiniCapture.viewController(withClient: client,
                                                        importedDocuments: visionDocuments,
                                                        configuration: visionConfiguration,
                                                        resultsDelegate: self,
                                                        documentMetadata: documentMetadata,
                                                        api: .default,
                                                        userApi: .default,
                                                        trackingDelegate: self)
// MARK: - Screen API with custom networking        
//        let viewController = GiniCapture.viewController(importedDocuments: visionDocuments,
//                                                        configuration: visionConfiguration,
//                                                        resultsDelegate: self,
//                                                        documentMetadata: documentMetadata,
//                                                        trackingDelegate: trackingDelegate,
//                                                        networkingService: self)
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
            .instantiateViewController(withIdentifier: "resultScreen") as? ResultTableViewController)!
        customResultsScreen.result = results
		customResultsScreen.editableFields = editableSpecificExtractions
		
        DispatchQueue.main.async { [weak self] in
            if #available(iOS 15.0, *) {
                if let config = self?.visionConfiguration,
                 config.customNavigationController == nil {
                    self?.screenAPIViewController.applyStyle(withConfiguration: config)
                }
             }
            self?.screenAPIViewController.setNavigationBarHidden(false, animated: false)
            self?.screenAPIViewController.pushViewController(customResultsScreen, animated: true)
        }
    }
}

// MARK: - UINavigationControllerDelegate

extension ScreenAPICoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // Since the ResultTableViewController is in the navigation stack,
        // when it is necessary to go back, it dismiss the ScreenAPI so the Analysis screen is not shown again

        if fromVC is ResultTableViewController {
			var extractionAmount = ExtractionAmount(value: 0.0, currency: .EUR)
			if let amountValue = extractedResults.first(where: { $0.name == "amountToPay"})?.value {
				extractionAmount = ExtractionAmount(value: Decimal(string: String(amountValue.split(separator: ":")[0])) ?? 0.0, currency: .EUR)
			}
		
			visionConfiguration.cleanup(paymentRecipient: extractedResults.first(where: { $0.name == "paymentRecipient"})?.value ?? "",
								  paymentReference: extractedResults.first(where: { $0.name == "paymentReference"})?.value ?? "",
								  paymentPurpose: extractedResults.first(where: { $0.name == "paymentPurpose"})?.value ?? "",
								  iban: extractedResults.first(where: { $0.name == "iban"})?.value ?? "",
								  bic: extractedResults.first(where: { $0.name == "bic"})?.value ?? "",
								  amountToPay: extractionAmount)
            delegate?.screenAPI(coordinator: self, didFinish: ())
        }

        return nil
    }
}

// MARK: - GiniCaptureResultsDelegate

extension ScreenAPICoordinator: GiniCaptureResultsDelegate {
    func giniCaptureDidEnterManually() {
        screenAPIViewController.dismiss(animated: true)
    }
    
    func giniCaptureAnalysisDidFinishWith(result: AnalysisResult) {
		extractedResults = result.extractions.map { $0.value}
		for extraction in editableSpecificExtractions {
			if (extractedResults.first(where: { $0.name == extraction.key }) == nil) {
				extractedResults.append(Extraction(box: nil, candidates: nil, entity: extraction.value, value: "", name: extraction.key))
			}
		}
        showResultsScreen(results: extractedResults, document: result.document)
    }

    func giniCaptureDidCancelAnalysis() {
        delegate?.screenAPI(coordinator: self, didFinish: ())
    }
}

// MARK: - GiniCaptureNetworkService

extension ScreenAPICoordinator: GiniCaptureNetworkService {
    func delete(document: Document, completion: @escaping (Result<String, GiniError>) -> Void) {
        print("custom networking - delete called")
    }

    func cleanup() {
        print("custom networking - cleanup called")
    }

    func analyse(partialDocuments: [PartialDocumentInfo],
                 metadata: Document.Metadata?,
                 cancellationToken: CancellationToken,
                 completion: @escaping (Result<(document: Document,
                                                extractionResult: ExtractionResult), GiniError>) -> Void) {
        print("custom networking - analyse called")
    }

    func upload(document: GiniCaptureDocument,
                metadata: Document.Metadata?,
                completion: @escaping UploadDocumentCompletion) {
        print("custom networking - upload called")
    }

    func sendFeedback(document: Document,
                      updatedExtractions: [Extraction],
                      updatedCompoundExtractions: [String : [[Extraction]]]?,
                      completion: @escaping (Result<Void, GiniError>) -> Void) {
        print("custom networking - sendFeedback called")
    }

    func log(errorEvent: ErrorEvent, completion: @escaping (Result<Void, GiniError>) -> Void) {
        print("custom networking - log error event called")
    }
}

// MARK: - GiniCaptureTrackingDelegate

extension ScreenAPICoordinator: GiniCaptureTrackingDelegate {
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
