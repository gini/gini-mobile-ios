//
//  GiniScreenAPICoordinator.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
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
        var navigationController: UINavigationController
        if let customNavigationController = giniConfiguration.customNavigationController {
            navigationController = customNavigationController
        } else {
            navigationController = UINavigationController()
            navigationController.applyStyle(withConfiguration: self.giniConfiguration)
        }
        navigationController.delegate = self
        return navigationController
    }()

    // Tracking
    public weak var trackingDelegate: GiniCaptureTrackingDelegate?

    // Screens
    var analysisViewController: AnalysisViewController?
    weak var cameraScreen: CameraViewController?
    var noResultsViewController: NoResultScreenViewController?
    lazy var reviewViewController: ReviewViewController = {
        return self.createReviewScreenContainer(with: [])
    }()
    lazy var documentPickerCoordinator: DocumentPickerCoordinator = {
        return DocumentPickerCoordinator(giniConfiguration: giniConfiguration)
    }()

    // Properties
    public var giniConfiguration: GiniConfiguration
    public var pages: [GiniCapturePage] = []
    public weak var visionDelegate: GiniCaptureDelegate?
    // Resources
    fileprivate(set) lazy var cancelButtonResource =
        giniConfiguration.cancelButtonResource ??
            GiniPreferredButtonResource(image: "navigationAnalysisBack",
                                        title: "ginicapture.navigationbar.analysis.back",
                                        comment: "Button title in the navigation bar for" +
                "the back button on the analysis screen",
                                        configEntry: self.giniConfiguration.navigationBarAnalysisTitleBackButton)
    fileprivate(set) lazy var closeButtonResource =
        giniConfiguration.closeButtonResource ??
            GiniPreferredButtonResource(
                image: "navigationCameraClose",
                title: "ginicapture.navigationbar.camera.close",
                comment: "Button title in the navigation bar for the close button on the camera screen",
                configEntry: giniConfiguration.navigationBarCameraTitleCloseButton)
    fileprivate(set) lazy var helpButtonResource =
        giniConfiguration.helpButtonResource ??
            GiniPreferredButtonResource(
                image: "navigationCameraHelp",
                title: "ginicapture.navigationbar.camera.help",
                comment: "Button title in the navigation bar for the help button on the camera screen",
                configEntry: giniConfiguration.navigationBarCameraTitleHelpButton)
    fileprivate(set) lazy var nextButtonResource =
        giniConfiguration.nextButtonResource ??
            GiniPreferredButtonResource(
                image: "navigationReviewContinue",
                title: "ginicapture.navigationbar.review.continue",
                comment: "Button title in the navigation bar for " +
                "the continue button on the review screen",
                configEntry: giniConfiguration.navigationBarReviewTitleContinueButton)

    public init(withDelegate delegate: GiniCaptureDelegate?,
                giniConfiguration: GiniConfiguration) {
        self.visionDelegate = delegate
        self.giniConfiguration = giniConfiguration
        super.init()
    }

    public func start(withDocuments documents: [GiniCaptureDocument]?,
                      backAnimated: Bool = false,
                      animated: Bool = false) -> UIViewController {
        var viewControllers: [UIViewController] = []

        if let documents = documents, !documents.isEmpty {
            var errorMessage: String?

            if documents.count > 1, !giniConfiguration.multipageEnabled {
                errorMessage = "You are trying to import several files from" +
                " other app when the Multipage feature is not " +
                    "enabled. To enable it just set `multipageEnabled`" +
                    " to `true` in the `GiniConfiguration`"
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
            let cameraViewController = createCameraViewController()
            cameraScreen = cameraViewController
            viewControllers = [reviewViewController, cameraViewController]
        }

        if backAnimated {
            let delegate = SingleTransitionLeftSlideNavigationDelegate()
            screenAPINavigationController.delegate = delegate
            screenAPINavigationController.setViewControllers(viewControllers, animated: true)
        } else {
            screenAPINavigationController.setViewControllers(viewControllers, animated: animated)
        }
        return ContainerNavigationController(rootViewController: self.screenAPINavigationController,
                                             parent: self)
    }

    private func initialViewControllers(with pages: [GiniCapturePage]) -> [UIViewController] {
        // Creating an array of GiniImageDocuments and filtering it for 'isFromOtherApp'
        if pages.compactMap({ $0.document as? GiniImageDocument }).filter({ $0.isFromOtherApp }).isNotEmpty {
            self.analysisViewController = createAnalysisScreen(withDocument: pages[0].document)
            return [self.analysisViewController!]
        }

        if pages.type == .image {
            reviewViewController = createReviewScreenContainer(with: pages)

            return [reviewViewController]
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

        if pages.type == .image {
            reviewViewController.updateCollections(with: self.pages, finishedUpload: false)
        }
    }

    func removeFromDocuments(document: GiniCaptureDocument) {
        pages.remove(document)
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

        if pages.type == .image {
            reviewViewController.updateCollections(with: self.pages, finishedUpload: pages.allSatisfy(\.isUploaded))
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
            navigateBackFromCameraViewController()
        case is AnalysisViewController:
            navigateBackFromAnalysisViewController()
        default:
            navigateBack()
        }
    }

    @objc func finishWithRetake() {
        self.pages = []
        self.trackingDelegate?.onAnalysisScreenEvent(event: Event(type: .retry))
        self.backToCamera()
    }

    @objc public func finishWithCancellation() {
        if let delegate = self.visionDelegate {
            delegate.didCancelCapturing()
        } else {
            Log(message: "GiniCaptureResultsDelegate is not implemented", event: .error)
        }
    }

    @objc func finishWithEnterManually() {
        if let delegate = self.visionDelegate {
            delegate.didPressEnterManually()
        } else {
            Log(message: "GiniCaptureResultsDelegate is not implemented", event: .error)
        }
    }

    private func navigateBackFromCameraViewController() {
        trackingDelegate?.onCameraScreenEvent(event: Event(type: .exit))
        GiniAnalyticsManager.track(event: .closeTapped, screenName: screenName())
        guard pages.type != .qrcode else {
            finishWithCancellation()
            return
        }

        if pages.count > 0 {
            navigateBack()
        } else {
            finishWithCancellation()
        }
    }

    private func navigateBackFromAnalysisViewController() {
        trackingDelegate?.onAnalysisScreenEvent(event: Event(type: .cancel))
        GiniAnalyticsManager.track(event: .closeTapped, screenName: .analysis)
        finishWithCancellation()
    }

    private func navigateBack() {
        if screenAPINavigationController.viewControllers.count > 1 {
            screenAPINavigationController.popViewController(animated: true)
        } else {
            finishWithCancellation()
        }
    }

    // Determine the screen name based on the top view controller
    private func screenName() -> GiniAnalyticsScreen {
        if let topViewController = screenAPINavigationController.topViewController as? CameraViewController,
           !topViewController.cameraPreviewViewController.isAuthorized {
            return .cameraAccess
        } else {
            return .camera
        }
    }

    @objc func showHelpMenuScreen() {
        let topViewController = screenAPINavigationController.topViewController as? CameraViewController
        guard let topViewController, topViewController.shouldShowHelp else {
            return
        }

        GiniAnalyticsManager.track(event: .helpTapped, screenName: screenName())

        let helpMenuViewController = HelpMenuViewController(giniConfiguration: giniConfiguration)

        helpMenuViewController.delegate = self
        trackingDelegate?.onCameraScreenEvent(event: Event(type: .help))

        let backButtonTitle = NSLocalizedStringPreferredFormat("ginicapture.navigationbar.help.backToCamera",
                                                               comment: "Camera")
        let barButton = GiniBarButton(ofType: .back(title: backButtonTitle))
        barButton.addAction(self, #selector(backToCameraTapped))
        helpMenuViewController.navigationItem.leftBarButtonItem = barButton.barButton

        // In case of 1 menu item it's better to show the item immediately without any selection

        let menuItems = helpMenuViewController.dataSource.items
        let helpViewControllerForOneItem = helpItemViewController(for: helpMenuViewController.dataSource.items[0])
        let helpViewControllerToPush = menuItems.count == 1 ? helpViewControllerForOneItem : helpMenuViewController

        screenAPINavigationController.pushViewController(helpViewControllerToPush, animated: true)

    }

    @objc func backToCameraTapped() {
        GiniAnalyticsManager.track(event: .closeTapped, screenName: .help)
        back()
    }

    @objc func showAnalysisScreen() {
        if screenAPINavigationController.topViewController is ReviewViewController {
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
        self.screenAPINavigationController.pushViewController(analysisViewController!, animated: true)
    }

    @objc func backToCamera() {
        _ = start(withDocuments: nil, backAnimated: true)
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

        if toVC is CameraViewController &&
            (fromVC is AnalysisViewController ||
             fromVC is NoResultScreenViewController) {
            // When going directly from the analysis or from the single page review screen to the camera the pages
            // collection should be cleared, since the document processed in that cases is not going to be reused
            clearDocuments()
        }

        if fromVC is ReviewViewController, let cameraVC = toVC as? CameraViewController {
            cameraVC.replaceCapturedStackImages(with: pages.compactMap { $0.document.previewImage })
        }

        return nil
    }

}

// MARK: - HelpMenuViewControllerDelegate

extension GiniScreenAPICoordinator: HelpMenuViewControllerDelegate {
    func help(_ menuViewController: HelpMenuViewController, didSelect item: HelpMenuItem) {
        screenAPINavigationController.pushViewController(helpItemViewController(for: item),
                                                         animated: true)
    }

    func helpItemViewController(for item: HelpMenuItem) -> UIViewController {
        var viewController: UIViewController

        switch item {
        case .noResultsTips:
            let title: String = NSLocalizedStringPreferredFormat("ginicapture.noresults.title",
                                                                 comment: "Tips")
            viewController = HelpTipsViewController(giniConfiguration: giniConfiguration)
            viewController.title = title
        case .openWithTutorial:
            viewController = HelpImportViewController(giniConfiguration: giniConfiguration)
        case .supportedFormats:
            viewController = HelpFormatsViewController(giniConfiguration: giniConfiguration)
        case .custom(_, let customViewController):
            viewController = customViewController
        }

        let backButtonTitle = NSLocalizedStringPreferredFormat("ginicapture.navigationbar.help.backToMenu",
                                                               comment: "Help")
        let barButton = GiniBarButton(ofType: .back(title: backButtonTitle))
        barButton.addAction(self, #selector(back))
        viewController.navigationItem.leftBarButtonItem = barButton.barButton
        return viewController
    }
}
