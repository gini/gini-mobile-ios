//
//  ScreenAPICoordinator.swift
//  GiniCapture_Example
//
//  Created by Enrique del Pozo Gómez on 11/10/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation
import UIKit
import GiniCaptureSDK
import GiniBankAPILibrary

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

final class ScreenAPICoordinator: NSObject, Coordinator {
    
    weak var delegate: ScreenAPICoordinatorDelegate?
    var childCoordinators: [Coordinator] = []
    var rootViewController: UIViewController {
        return screenAPIViewController
    }
    var screenAPIViewController: UINavigationController!
    
    private let trackingDelegate = TrackingDelegate()
    
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
        self.visionConfiguration = configuration
        self.visionDocuments = documents
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
                                                       trackingDelegate: trackingDelegate)
        screenAPIViewController = RootNavigationController(rootViewController: viewController)
        screenAPIViewController.navigationBar.barTintColor = visionConfiguration.navigationBarTintColor
        screenAPIViewController.navigationBar.tintColor = visionConfiguration.navigationBarTitleColor
        screenAPIViewController.setNavigationBarHidden(true, animated: false)
        screenAPIViewController.delegate = self
        screenAPIViewController.interactivePopGestureRecognizer?.delegate = nil
    }
    
    fileprivate func showResultsScreen(results: [Extraction]) {
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
            self.delegate?.screenAPI(coordinator: self, didFinish: ())
        }
        
        if let fromVC = fromVC as? ResultTableViewController {
            self.sendFeedbackBlock?(fromVC.result.reduce([:]) {
                guard let name = $1.name else { return $0 }
                var result = $0
                result[name] = $1
                return result
            })
            self.delegate?.screenAPI(coordinator: self, didFinish: ())
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
    func giniCaptureAnalysisDidFinishWith(result: AnalysisResult, sendFeedbackBlock: @escaping ([String: Extraction]) -> Void) {
        showResultsScreen(results: result.extractions.map { $0.value })
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
