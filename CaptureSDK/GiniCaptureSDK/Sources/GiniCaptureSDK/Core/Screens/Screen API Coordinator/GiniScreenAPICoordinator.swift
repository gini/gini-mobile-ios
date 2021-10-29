//
//  GiniScreenAPICoordinator.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 12/19/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation
import UIKit
protocol Coordinator: AnyObject {
    var rootViewController: UIViewController { get }
}

open class GiniScreenAPICoordinator: NSObject, Coordinator {
    
    var rootViewController: UIViewController {
        return screenAPINavigationController
    }
    
    public lazy var screenAPINavigationController: UINavigationController = {
        let navigationController = UINavigationController()
        navigationController.delegate = self
        navigationController.applyStyle(withConfiguration: self.giniConfiguration)
        return navigationController
    }()
    
    // Tracking
    public weak var trackingDelegate: GiniCaptureTrackingDelegate?
    
    // Screens
    var analysisViewController: AnalysisViewController?
    var cameraViewController: CameraViewController?
    var imageAnalysisNoResultsViewController: ImageAnalysisNoResultsViewController?
    var reviewViewController: ReviewViewController?
    lazy var multiPageReviewViewController: MultipageReviewViewController = {
        return self.createMultipageReviewScreenContainer(with: [])
    }()
    lazy var documentPickerCoordinator: DocumentPickerCoordinator = {
        return DocumentPickerCoordinator(giniConfiguration: giniConfiguration)
    }()
    
    // Properties
    public var giniConfiguration: GiniConfiguration
    public var pages: [GiniCapturePage] = []
    public weak var visionDelegate: GiniCaptureDelegate?
    
    // When there was an error uploading a document or analyzing it and the analysis screen
    // had not been initialized yet, both the error message and action has to be saved to show in the analysis screen.
    var analysisErrorAndAction: (message: String, action: () -> Void)?
    
    // Resources
    fileprivate(set) lazy var backButtonResource =
        GiniPreferredButtonResource(image: "navigationReviewBack",
                                    title: "ginicapture.navigationbar.review.back",
                                    comment: "Button title in the navigation bar for the back button on the review screen",
                                    configEntry: self.giniConfiguration.navigationBarReviewTitleBackButton)
    fileprivate(set) lazy var backToCameraFromHelpMenuButtonResource =
        GiniPreferredButtonResource(image: "navigationHelpBack",
                                    title: "ginicapture.navigationbar.help.backToCamera",
                                    comment: "Button title in the navigation bar for the back button on the help screen",
                                    configEntry: self.giniConfiguration.navigationBarHelpMenuTitleBackToCameraButton)
    fileprivate(set) lazy var cancelButtonResource =
        giniConfiguration.cancelButtonResource ??
            GiniPreferredButtonResource(image: "navigationAnalysisBack",
                                        title: "ginicapture.navigationbar.analysis.back",
                                        comment: "Button title in the navigation bar for" +
                "the back button on the analysis screen",
                                        configEntry: self.giniConfiguration.navigationBarAnalysisTitleBackButton)
    fileprivate(set) lazy var closeButtonResource =
        giniConfiguration.closeButtonResource ??
            GiniPreferredButtonResource(image: "navigationCameraClose",
                                        title: "ginicapture.navigationbar.camera.close",
                                        comment: "Button title in the navigation bar for the close button on the camera screen",
                                        configEntry: self.giniConfiguration.navigationBarCameraTitleCloseButton)
    fileprivate(set) lazy var helpButtonResource =
        giniConfiguration.helpButtonResource ??
            GiniPreferredButtonResource(image: "navigationCameraHelp",
                                        title: "ginicapture.navigationbar.camera.help",
                                        comment: "Button title in the navigation bar for the help button on the camera screen",
                                        configEntry: self.giniConfiguration.navigationBarCameraTitleHelpButton)
    fileprivate(set) lazy var nextButtonResource =
        giniConfiguration.nextButtonResource ??
            GiniPreferredButtonResource(image: "navigationReviewContinue",
                                        title: "ginicapture.navigationbar.review.continue",
                                        comment: "Button title in the navigation bar for " +
                "the continue button on the review screen",
                                        configEntry: self.giniConfiguration.navigationBarReviewTitleContinueButton)
    fileprivate lazy var backToHelpMenuButtonResource =
        GiniPreferredButtonResource(image: "arrowBack",
                                    title: "ginicapture.navigationbar.help.backToMenu",
                                    comment: "Button title in the navigation bar for the back button on the help screen",
                                    configEntry: self.giniConfiguration.navigationBarHelpScreenTitleBackToMenuButton)
    
    public init(withDelegate delegate: GiniCaptureDelegate?,
                giniConfiguration: GiniConfiguration) {
        self.visionDelegate = delegate
        self.giniConfiguration = giniConfiguration
        super.init()
    }
    
    public func start(withDocuments documents: [GiniCaptureDocument]?) -> UIViewController {
        var viewControllers: [UIViewController] = []

        if let documents = documents, !documents.isEmpty {
            var errorMessage: String? = nil
            
            if documents.count > 1, !giniConfiguration.multipageEnabled {
                errorMessage = "You are trying to import several files from other app when the Multipage feature is not " +
                    "enabled. To enable it just set `multipageEnabled` to `true` in the `GiniConfiguration`"
                
            }

            if !documents.containsDifferentTypes {
                let pages: [GiniCapturePage] = documents.map { GiniCapturePage(document: $0) }
                self.addToDocuments(new: pages)
                if !giniConfiguration.openWithEnabled {
                    errorMessage = "You are trying to import a file from other app when the Open With feature is not " +
                        "enabled. To enable it just set `openWithEnabled` to `true` in the `GiniConfiguration`"
                }

                pages.forEach { visionDelegate?.didCapture(document: $0.document, networkDelegate: self) }
                viewControllers = initialViewControllers(with: pages)
            } else {
                errorMessage = "You are trying to import both PDF and images at the same time. " +
                    "For now it is only possible to import either images or one PDF"
            }
            
            if let errorMessage = errorMessage {
                let errorLog = ErrorLog(description: errorMessage)
                giniConfiguration.errorLogger.handleErrorLog(error: errorLog)
                fatalError(errorMessage)
            }
        } else {
            self.cameraViewController = self.createCameraViewController()
            viewControllers = [self.cameraViewController!]
        }

        self.screenAPINavigationController.setViewControllers(viewControllers, animated: false)
        return ContainerNavigationController(rootViewController: self.screenAPINavigationController,
                                             parent: self)
    }
    
    private func initialViewControllers(with pages: [GiniCapturePage]) -> [UIViewController] {
        if pages.type == .image {
            if giniConfiguration.multipageEnabled {
                self.cameraViewController = self.createCameraViewController()
                self.cameraViewController?
                    .replaceCapturedStackImages(with: pages.compactMap { $0.document.previewImage })
                
                self.multiPageReviewViewController =
                    createMultipageReviewScreenContainer(with: pages)
                
                return [self.cameraViewController!, self.multiPageReviewViewController]
            } else {
                self.cameraViewController = self.createCameraViewController()
                self.reviewViewController = self.createReviewScreen(withDocument: pages[0].document)
                return [self.cameraViewController!, self.reviewViewController!]
            }
        } else {
            self.analysisViewController = createAnalysisScreen(withDocument: pages[0].document)
            return [self.analysisViewController!]
        }
    }
}

// MARK: - Session documents

extension GiniScreenAPICoordinator {
    func addToDocuments(new pages: [GiniCapturePage]) {
        self.pages.append(contentsOf: pages)
        
        if giniConfiguration.multipageEnabled, pages.type == .image {
            refreshMultipageReviewNextButton(with: self.pages)
            multiPageReviewViewController.updateCollections(with: self.pages)
        }
    }
    
    func removeFromDocuments(document: GiniCaptureDocument) {
        pages.remove(document)
        
        if giniConfiguration.multipageEnabled, pages.type == .image {
            refreshMultipageReviewNextButton(with: pages)
        }
    }
    
    func updateDocument(for document: GiniCaptureDocument) {
        if let index = pages.index(of: document) {
            pages[index].document = document
        }
    }
    
    func update(_ document: GiniCaptureDocument, withError error: Error?, isUploaded: Bool) {
        if let index = pages.index(of: document) {
            pages[index].isUploaded = isUploaded
            pages[index].error = error
        }
        
        if giniConfiguration.multipageEnabled, pages.type == .image {
            refreshMultipageReviewNextButton(with: pages)
            multiPageReviewViewController.updateCollections(with: pages)
        }
    }
    
    func replaceDocuments(with pages: [GiniCapturePage]) {
        self.pages = pages
    }
    
    func clearDocuments() {
        pages.removeAll()
    }
}

// MARK: - Button actions

extension GiniScreenAPICoordinator {
    
    @objc func back() {
        
        switch screenAPINavigationController.topViewController {
        case is CameraViewController:
            trackingDelegate?.onCameraScreenEvent(event: Event(type: .exit))
        case is AnalysisViewController:
            trackingDelegate?.onAnalysisScreenEvent(event: Event(type: .cancel))
        default:
            break
        }
        
        if self.screenAPINavigationController.viewControllers.count == 1 {
            self.closeScreenApi()
        } else {
            self.screenAPINavigationController.popViewController(animated: true)
        }
    }
    
    @objc func closeScreenApi() {
        self.visionDelegate?.didCancelCapturing()
    }
    
    @objc func showHelpMenuScreen() {
        
        trackingDelegate?.onCameraScreenEvent(event: Event(type: .help))
        
        let helpMenuViewController = HelpMenuViewController(giniConfiguration: giniConfiguration)
        helpMenuViewController.delegate = self
        helpMenuViewController.setupNavigationItem(usingResources: backToCameraFromHelpMenuButtonResource,
                                                   selector: #selector(back),
                                                   position: .left,
                                                   target: self)
        if helpMenuViewController.menuItems.count == 1 {
            screenAPINavigationController
                .pushViewController(helpItemViewController(for: helpMenuViewController.menuItems[0]),
                                    animated: true)
        } else {
            screenAPINavigationController
                .pushViewController(helpMenuViewController, animated: true)
        }
    }
    
    @objc func showAnalysisScreen() {
        
        if screenAPINavigationController.topViewController is MultipageReviewViewController ||
        screenAPINavigationController.topViewController is ReviewViewController {
            trackingDelegate?.onReviewScreenEvent(event: Event(type: .next))
        }
        
        guard let firstDocument = pages.first?.document else {
            return
        }
        
        if pages.type == .image {
            visionDelegate?.didReview(documents: pages.map { $0.document }, networkDelegate: self)
        }
        analysisViewController = createAnalysisScreen(withDocument: firstDocument)
        analysisViewController?.trackingDelegate = trackingDelegate
        
        if let (message, action) = analysisErrorAndAction {
            displayError(withMessage: message, andAction: action)
        }
        
        self.screenAPINavigationController.pushViewController(analysisViewController!, animated: true)
    }
    
    @objc func backToCamera() {
        if let cameraViewController = cameraViewController {
            screenAPINavigationController.popToViewController(cameraViewController, animated: true)
        }
    }
}

// MARK: - Navigation delegate

extension GiniScreenAPICoordinator: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if fromVC is AnalysisViewController {
            analysisViewController = nil
            if operation == .pop {
                visionDelegate?.didCancelAnalysis()
            }
        }
        
        if fromVC is ReviewViewController && operation == .pop {
            reviewViewController = nil            
            if let firstDocument = pages.first?.document {
                visionDelegate?.didCancelReview(for: firstDocument)
            }
        }
        
        if toVC is CameraViewController &&
            (fromVC is ReviewViewController ||
                fromVC is AnalysisViewController ||
                fromVC is ImageAnalysisNoResultsViewController) {
            // When going directly from the analysis or from the single page review screen to the camera the pages
            // collection should be cleared, since the document processed in that cases is not going to be reused
            clearDocuments()
        }
                
        if fromVC is MultipageReviewViewController, let cameraVC = toVC as? CameraViewController {
            cameraVC.replaceCapturedStackImages(with: pages.compactMap { $0.document.previewImage })
        }
                
        return nil
    }
    
}

// MARK: - HelpMenuViewControllerDelegate

extension GiniScreenAPICoordinator: HelpMenuViewControllerDelegate {
    public func help(_ menuViewController: HelpMenuViewController, didSelect item: HelpMenuViewController.Item) {
        screenAPINavigationController.pushViewController(helpItemViewController(for: item),
                                                         animated: true)
    }
    
    func helpItemViewController(for item: HelpMenuViewController.Item) -> UIViewController {
        var viewController: UIViewController
        switch item {
        case .noResultsTips:
            let imageNoResultViewController = item.viewController as? ImageAnalysisNoResultsViewController
            imageNoResultViewController?.didTapBottomButton = { [weak self] in
                guard let self = self, let cameraViewController = self.cameraViewController else { return }
                self.screenAPINavigationController.popToViewController(cameraViewController, animated: true)
            }
            
            viewController = imageNoResultViewController!
        case .openWithTutorial, .supportedFormats:
            viewController = item.viewController
        case .custom(_, let customViewController):
            viewController = customViewController
        }
        
        viewController.setupNavigationItem(usingResources: backToHelpMenuButtonResource,
                                           selector: #selector(back),
                                           position: .left,
                                           target: self)
        
        return viewController
    }
}
