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
        
        customResultsScreen.navigationItem
            .rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("close",
                                                                           comment: "close button text"),
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(closeSreenAPI))
        
        DispatchQueue.main.async { [weak self] in
            if #available(iOS 15.0, *) {
                let config = self?.configuration.captureConfiguration()
                 self?.screenAPIViewController.applyStyle(withConfiguration: config ?? GiniConfiguration())
             }
            self?.screenAPIViewController.setNavigationBarHidden(false, animated: false)
            
            self?.screenAPIViewController.pushViewController(customResultsScreen, animated: true)
        }
    }
    
    @objc private func closeSreenAPI() {
        delegate?.screenAPI(coordinator: self, didFinish: ())
    }
}


// MARK: - NoResultsScreenDelegate

extension ScreenAPICoordinator: NoResultsScreenDelegate {
    func noResults(viewController: NoResultViewController, didTapRetry: ()) {
        screenAPIViewController.popToRootViewController(animated: true)
    }
}

// MARK: - GiniCaptureResultsDelegate

extension ScreenAPICoordinator: GiniCaptureResultsDelegate {
    
    func giniCaptureAnalysisDidFinishWith(result: AnalysisResult,
                                         sendFeedbackBlock: @escaping ([String: Extraction]) -> Void) {
        
        showResultsScreen(results: result.extractions.map { $0.value}, document: result.document)
        self.sendFeedbackBlock = sendFeedbackBlock
    }
    
    func giniCaptureDidCancelAnalysis() {
        delegate?.screenAPI(coordinator: self, didFinish: ())
    }
    
    func giniCaptureAnalysisDidFinishWithoutResults(_ showingNoResultsScreen: Bool) {
        if !showingNoResultsScreen {
            let customNoResultsScreen = (UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "noResultScreen") as? NoResultViewController)!
            customNoResultsScreen.delegate = self
            self.screenAPIViewController.setNavigationBarHidden(false, animated: false)
            self.screenAPIViewController.pushViewController(customNoResultsScreen, animated: true)
        }
    }
}

extension ScreenAPICoordinator: GiniCaptureNetworkService {
    func delete(document: Document, completion: @escaping (Result<String, GiniError>) -> Void) {
        print("💻 custom networking - delete document event called")
    }
    
    func cleanup() {
        print("💻 custom networking - cleanup event called")

    }
    
    func analyse(partialDocuments: [PartialDocumentInfo], metadata: Document.Metadata?, cancellationToken: CancellationToken, completion: @escaping (Result<(document: Document, extractionResult: ExtractionResult), GiniError>) -> Void) {
        print("💻 custom networking - analyse documents event called")
    }
    
    func upload(document: GiniCaptureDocument, metadata: Document.Metadata?, completion: @escaping UploadDocumentCompletion) {
        print("💻 custom networking - upload document event called")
    }
    
    func sendFeedback(document: Document, updatedExtractions: [Extraction], completion: @escaping (Result<Void, GiniError>) -> Void) {
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
