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
    func screenAPI(coordinator: ScreenAPICoordinator, didFinish: (), withResults results: [Extraction]?)
}

final class CustomMenuItemViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.Gini.blue
    }
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

        screenAPIViewController = RootNavigationController(rootViewController: viewController)
        screenAPIViewController.navigationBar.barTintColor = visionConfiguration.navigationBarTintColor
        screenAPIViewController.navigationBar.tintColor = visionConfiguration.navigationBarTitleColor
        screenAPIViewController.setNavigationBarHidden(true, animated: false)
//        screenAPIViewController.delegate = self
        screenAPIViewController.interactivePopGestureRecognizer?.delegate = nil
    }

    fileprivate func showResultsScreen(results: [Extraction], document: Document?) {
        if let document = document {
            print("🧾 Showing results for Gini Bank API document id: \(document.id)")
        } else {
            print("❓ Showing results for unknown Gini Bank API document")
        }

        delegate?.screenAPI(coordinator: self, didFinish: (), withResults: results)
    }
}

// MARK: - GiniCaptureResultsDelegate

extension ScreenAPICoordinator: GiniCaptureResultsDelegate {
    func giniCaptureAnalysisDidFinishWith(result: AnalysisResult,
                                          sendFeedbackBlock: @escaping ([String: Extraction]) -> Void) {
        showResultsScreen(results: result.extractions.map { $0.value }, document: result.document)
        self.sendFeedbackBlock = sendFeedbackBlock
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            sendFeedbackBlock(result.extractions)
        }
    }

    func giniCaptureDidCancelAnalysis() {
        delegate?.screenAPI(coordinator: self, didFinish: (), withResults: nil)
    }

    func giniCaptureAnalysisDidFinishWithoutResults(_ showingNoResultsScreen: Bool) {

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
