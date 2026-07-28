//
//  CameraPreviewViewControllerTests.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 2/11/19.
//

import XCTest
import AVFoundation
@testable import GiniCaptureSDK

final class CameraPreviewViewControllerTests: XCTestCase {
    
    var cameraPreviewViewController: CameraPreviewViewController!
    
    override func setUp() {
        super.setUp()
        let camera = CameraMock(state: .authorized)
        cameraPreviewViewController = CameraPreviewViewController(giniConfiguration: GiniConfiguration(),
                                                                  camera: camera)
    }
    
    func testSessionWhenViewIsLoaded() {
        _ = cameraPreviewViewController.view
        XCTAssertTrue(cameraPreviewViewController.view.subviews.contains(cameraPreviewViewController.previewView),
                      "previewView must be added when loading the view")
        XCTAssertNotNil(cameraPreviewViewController.previewView.session,
                        "session must be assigned to previewView when view is loaded")
    }
    
    func testAddNotAuthroizedView() {
        let camera = CameraMock(state: .unauthorized)
        cameraPreviewViewController = CameraPreviewViewController(giniConfiguration: GiniConfiguration(),
                                                                  camera: camera)
        let bottomAnchor = cameraPreviewViewController.view.bottomAnchor
        cameraPreviewViewController.setupCamera(bottomAnchor: bottomAnchor)
        
        let notAuthorizedView = cameraPreviewViewController
            .view
            .subviews
            .compactMap { $0 as? CameraNotAuthorizedView }
            .first
        
        XCTAssertNotNil(notAuthorizedView, "Not authorized view should be shown when camera permission not authorized")
    }
    
    func testQrOutputSetUp() {
        let giniConfiguration = GiniConfiguration()
        giniConfiguration.qrCodeScanningEnabled = true
        cameraPreviewViewController = CameraPreviewViewController(giniConfiguration: giniConfiguration)
        _ = cameraPreviewViewController.view
        let bottomAnchor = cameraPreviewViewController.view.bottomAnchor
        // Verifies setupCamera does not crash when QR scanning is enabled.
        // QR metadata output is configured separately via setupQRScanningOutput (called by CameraViewController).
        cameraPreviewViewController.setupCamera(bottomAnchor: bottomAnchor)
    }
    
    func testCaptureImage() {
        let expect = expectation(description: "an image is captured")
        let giniConfiguration = GiniConfiguration()
        giniConfiguration.debugModeOn = true
        cameraPreviewViewController = CameraPreviewViewController(giniConfiguration: giniConfiguration)
        _ = cameraPreviewViewController.view
        let bottomAnchor = cameraPreviewViewController.view.bottomAnchor
        cameraPreviewViewController.setupCamera(bottomAnchor: bottomAnchor)

        cameraPreviewViewController.captureImage { imageData, _ in
            XCTAssertNotNil(imageData, "image captured data should not be nil")
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1.0)
    }
    
    func testFlashToggle() {
        let camera = CameraMock(state: .authorized)
        let defaultFlashState = camera.isFlashOn
        let giniConfiguration = GiniConfiguration()
        giniConfiguration.flashToggleEnabled = true

        cameraPreviewViewController = CameraPreviewViewController(giniConfiguration: giniConfiguration,
                                                                  camera: camera)
        _ = cameraPreviewViewController.view
        cameraPreviewViewController.isFlashOn = false

        XCTAssertNotEqual(defaultFlashState, camera.isFlashOn, "camera flash state should change it after toggle it")
    }

    // MARK: - QR Detection Pause/Resume

    private func makeCamera() -> Camera {
        return Camera(giniConfiguration: GiniConfiguration())
    }

    private func cleanSessionQueue(_ camera: Camera, timeout: TimeInterval = 2.0) {
        let expect = expectation(description: "session queue flushed")
        camera.sessionQueue.async {
            expect.fulfill()
        }
        wait(for: [expect], timeout: timeout)
    }

    func testPauseQRDetectionBeforeSetupDoesNotCrash() {
        let camera = makeCamera()

        camera.pauseQRDetection()
        cleanSessionQueue(camera)
    }

    func testResumeQRDetectionBeforeSetupDoesNotCrash() {
        let camera = makeCamera()

        camera.resumeQRDetection()
        cleanSessionQueue(camera)
    }

    func testPauseQRDetectionClearsMetadataObjectTypes() {
        let camera = makeCamera()
        let output = AVCaptureMetadataOutput()
        camera.setQRMetadataOutputForTesting(output)

        camera.pauseQRDetection()
        cleanSessionQueue(camera)

        XCTAssertTrue(output.metadataObjectTypes.isEmpty,
                      "metadataObjectTypes should be empty after pauseQRDetection")
    }

    func testResumeQRDetectionGuardsAgainstUnavailableQRType() {
        let camera = makeCamera()
        let output = AVCaptureMetadataOutput()
        camera.setQRMetadataOutputForTesting(output)

        camera.resumeQRDetection()
        cleanSessionQueue(camera)

        // On CI simulators .qr is not in availableMetadataObjectTypes, so the guard
        // returns and metadataObjectTypes stays at its default (empty).
        XCTAssertTrue(output.metadataObjectTypes.isEmpty,
                      "metadataObjectTypes should remain unchanged when .qr is unavailable")
    }

    func testSetupQRScanningOutputAssignsMetadataOutput() {
        let camera = makeCamera()

        // Trigger setup but don't wait for the main-queue completion callback —
        // just flush the serial sessionQueue, which runs after configureQROutput finishes.
        camera.setupQRScanningOutput { _ in }
        cleanSessionQueue(camera, timeout: 10.0)

        XCTAssertNotNil(camera.qrMetadataOutput,
                        "qrMetadataOutput should be assigned after configureQROutput runs")
    }

    func testResumeQRDetectionEnablesQRTypeWhenAvailable() {
        let camera = makeCamera()
        let output = FakeQRAvailableMetadataOutput()
        camera.setQRMetadataOutputForTesting(output)

        camera.resumeQRDetection()
        cleanSessionQueue(camera)

        XCTAssertEqual(output.metadataObjectTypes, [.qr],
                       "metadataObjectTypes should be set to [.qr] when .qr is available")
    }

    // MARK: - CameraViewController opt-out title behavior

    func testOptOutFollowedByRotationPreservesScanInvoiceTitle() {
        let giniConfiguration = GiniConfiguration()
        giniConfiguration.qrCodeScanningEnabled = true
        let viewController = CameraViewController(giniConfiguration: giniConfiguration,
                                                  viewModel: CameraButtonsViewModel())
        viewController.loadViewIfNeeded()

        let onlyInvoiceLabel = NSLocalizedString("ginicapture.camera.infoLabel.only.invoice",
                                                 bundle: giniCaptureBundle(),
                                                 comment: "")

        // Simulate the post-"Take photo of document" state (handleTakePhotoOfDocument is private).
        viewController.cameraPane.cameraTitleLabel?.text = onlyInvoiceLabel
        viewController.cameraPaneHorizontal?.cameraTitleLabel?.text = onlyInvoiceLabel
        viewController.title = onlyInvoiceLabel

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

// Test stub that pretends .qr is supported, allowing the `availableMetadataObjectTypes.contains(.qr)`
// guard branch in resumeQRDetection to be exercised on CI simulators (which have no real camera).
private final class FakeQRAvailableMetadataOutput: AVCaptureMetadataOutput {
    private var _objectTypes: [AVMetadataObject.ObjectType]? = []

    override var availableMetadataObjectTypes: [AVMetadataObject.ObjectType] {
        return [.qr]
    }

    override var metadataObjectTypes: [AVMetadataObject.ObjectType]! {
        get { _objectTypes }
        set { _objectTypes = newValue }
    }
}
