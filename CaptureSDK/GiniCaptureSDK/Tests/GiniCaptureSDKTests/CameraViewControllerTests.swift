//
//  CameraViewControllerTests.swift
//  GiniCaptureSDK
//
//  Copyright © 2026 Gini GmbH. All rights reserved.


import XCTest
@testable import GiniCaptureSDK

final class CameraViewControllerTests: XCTestCase {

    private func makeQRScanEnabledCameraViewController() -> CameraViewController {
        let giniConfiguration = GiniConfiguration()
        giniConfiguration.qrCodeScanningEnabled = true
        let viewController = CameraViewController(giniConfiguration: giniConfiguration,
                                                  viewModel: CameraButtonsViewModel())
        viewController.loadViewIfNeeded()
        return viewController
    }

    // MARK: - Take-photo opt-out title behavior

    func testOptOutFollowedByRotationPreservesScanInvoiceTitle() {
        let viewController = makeQRScanEnabledCameraViewController()
        let onlyInvoiceLabel = NSLocalizedString("ginicapture.camera.infoLabel.only.invoice",
                                                 bundle: giniCaptureBundle(),
                                                 comment: "")

        // Real entry point — mirrors the alert's "Take photo of document" action.
        viewController.handleTakePhotoOfDocument()

        // Simulate a rotation — viewWillTransition invokes configureTitle inside its coordinator.
        viewController.viewWillTransition(to: CGSize(width: 800, height: 600),
                                          with: ImmediateTransitionCoordinator())

        XCTAssertEqual(viewController.cameraPane.cameraTitleLabel?.text, onlyInvoiceLabel,
                       "Bottom pane info label should still read 'Scan invoice' after opt-out and rotation")

        // Nav title carries "Scan invoice" only on layouts without the bottom pane label
        // (iPad and iPhone landscape). Portrait iPhone intentionally keeps the default cameraTitle.
        if !(UIDevice.current.isIphone && UIDevice.current.isPortrait) {
            XCTAssertEqual(viewController.title, onlyInvoiceLabel,
                           "Navigation title should stay 'Scan invoice' after opt-out and rotation on iPad / iPhone landscape")
        }
    }

    // MARK: - "Scan another QR code" behavior

    func testScanAnotherQRCodeAppliesQRScanOnlyPresentation() {
        let viewController = makeQRScanEnabledCameraViewController()
        let cameraTitle = NSLocalizedString("ginicapture.navigationbar.camera.title",
                                            bundle: giniCaptureBundle(),
                                            comment: "")

        viewController.handleScanAnotherQRCode()

        XCTAssertEqual(viewController.cameraPane.alpha, 0,
                       "cameraPane should be alpha 0 so the capture UI is invisible")
        XCTAssertFalse(viewController.cameraPane.captureButton.isEnabled,
                       "Capture button should be disabled while in QR-scan-only presentation")
        XCTAssertTrue(viewController.cameraPreviewViewController.cameraFrameView.isHidden,
                      "Large document focus frame should be hidden")
        XCTAssertFalse(viewController.cameraPreviewViewController.qrCodeFrameView.isHidden,
                       "Small QR focus frame should be visible")
        XCTAssertEqual(viewController.cameraPane.cameraTitleLabel?.text, "",
                       "Bottom pane info label should be cleared")
        XCTAssertEqual(viewController.title, cameraTitle,
                       "Navigation title should read the plain 'Scan' camera title")
    }

    func testTakePhotoOfDocumentRestoresCaptureUIAfterScanAnother() {
        let viewController = makeQRScanEnabledCameraViewController()

        viewController.handleScanAnotherQRCode()
        viewController.handleTakePhotoOfDocument()

        XCTAssertEqual(viewController.cameraPane.alpha, 1,
                       "cameraPane should be visible again after Take photo of document")
        XCTAssertTrue(viewController.cameraPane.captureButton.isEnabled,
                      "Capture button should be re-enabled after Take photo of document")
        XCTAssertFalse(viewController.cameraPreviewViewController.cameraFrameView.isHidden,
                       "Large document focus frame should be visible again")
        XCTAssertTrue(viewController.cameraPreviewViewController.qrCodeFrameView.isHidden,
                      "Small QR focus frame should be hidden again")
    }
}

// Fires the animate closure synchronously so tests can exercise viewWillTransition without a real transition.
private final class ImmediateTransitionCoordinator: NSObject, UIViewControllerTransitionCoordinator {
    var isAnimated: Bool = false
    var presentationStyle: UIModalPresentationStyle = .none
    var initiallyInteractive: Bool = false
    var isInterruptible: Bool = false
    var isInteractive: Bool = false
    var isCancelled: Bool = false
    var transitionDuration: TimeInterval = 0
    var percentComplete: CGFloat = 0
    var completionVelocity: CGFloat = 0
    var completionCurve: UIView.AnimationCurve = .linear
    var containerView: UIView = UIView()
    var targetTransform: CGAffineTransform = .identity

    func animate(alongsideTransition animation: ((UIViewControllerTransitionCoordinatorContext) -> Void)?,
                 completion: ((UIViewControllerTransitionCoordinatorContext) -> Void)? = nil) -> Bool {
        animation?(self)
        completion?(self)
        return true
    }

    func animateAlongsideTransition(in view: UIView?,
                                    animation: ((UIViewControllerTransitionCoordinatorContext) -> Void)?,
                                    completion: ((UIViewControllerTransitionCoordinatorContext) -> Void)?) -> Bool {
        animation?(self)
        completion?(self)
        return true
    }

    func notifyWhenInteractionEnds(_ handler: @escaping (UIViewControllerTransitionCoordinatorContext) -> Void) {}
    func notifyWhenInteractionChanges(_ handler: @escaping (UIViewControllerTransitionCoordinatorContext) -> Void) {}
    func view(forKey key: UITransitionContextViewKey) -> UIView? { nil }
    func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? { nil }
}
