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
import GiniCaptureSDKPinning
import TrustKit
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
    var sendFeedbackBlock: (([String: Extraction]) -> Void)?
    let yourPublicPinningConfig = [
        kTSKPinnedDomains: [
        "pay-api.gini.net": [
            kTSKPublicKeyHashes: [
            // old *.gini.net public key
            "cNzbGowA+LNeQ681yMm8ulHxXiGojHE8qAjI+M7bIxU=",
            // new *.gini.net public key, active from around June 2020
            "zEVdOCzXU8euGVuMJYPr3DUU/d1CaKevtr0dW0XzZNo="
        ]],
        "user.gini.net": [
            kTSKPublicKeyHashes: [
            // old *.gini.net public key
            "cNzbGowA+LNeQ681yMm8ulHxXiGojHE8qAjI+M7bIxU=",
            // new *.gini.net public key, active from around June 2020
            "zEVdOCzXU8euGVuMJYPr3DUU/d1CaKevtr0dW0XzZNo="
        ]]
    ]] as [String: Any]

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
                                                        publicKeyPinningConfig: yourPublicPinningConfig,
                                                        documentMetadata: documentMetadata,
                                                        api: .default,
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

        DispatchQueue.main.async { [weak self] in
            if #available(iOS 15.0, *) {
                let config = self?.visionConfiguration
                self?.screenAPIViewController.applyStyle(withConfiguration: config ?? GiniConfiguration())
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
        // Since the NoResultViewController and ResultTableViewController are in the navigation stack,
        // when it is necessary to go back, it dismiss the ScreenAPI so the Analysis screen is not shown again

        if fromVC is NoResultViewController {
            delegate?.screenAPI(coordinator: self, didFinish: ())
        }

        if let fromVC = fromVC as? ResultTableViewController {
            sendFeedbackBlock?(fromVC.result.reduce([:]) {
                guard let name = $1.name else { return $0 }
                var result = $0
                result[name] = $1
                return result
            })
            delegate?.screenAPI(coordinator: self, didFinish: ())
        }

        return nil
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

    func giniCaptureDidEnterManually() {
        screenAPIViewController.dismiss(animated: true)
    }
    
    func giniCaptureAnalysisDidFinishWith(result: AnalysisResult,
                                          sendFeedbackBlock: @escaping ([String: Extraction]) -> Void) {
        showResultsScreen(results: result.extractions.map { $0.value }, document: result.document)
        self.sendFeedbackBlock = sendFeedbackBlock
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            sendFeedbackBlock(result.extractions)
        }
    }

    func giniCaptureDidCancelAnalysis() {
        delegate?.screenAPI(coordinator: self, didFinish: ())
    }

    func giniCaptureAnalysisDidFinishWithoutResults(_ showingNoResultsScreen: Bool) {
        if !showingNoResultsScreen {
            let customNoResultsScreen = (UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "noResultScreen") as? NoResultViewController)!
            customNoResultsScreen.delegate = self
            screenAPIViewController.setNavigationBarHidden(false, animated: false)
            screenAPIViewController.pushViewController(customNoResultsScreen, animated: true)
        }
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
