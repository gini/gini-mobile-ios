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

    private func flushSessionQueue(_ camera: Camera, timeout: TimeInterval = 2.0) {
        let expect = expectation(description: "session queue flushed")
        camera.sessionQueue.async {
            expect.fulfill()
        }
        wait(for: [expect], timeout: timeout)
    }

    func testPauseQRDetectionBeforeSetupDoesNotCrash() {
        let camera = makeCamera()

        camera.pauseQRDetection()
        flushSessionQueue(camera)
    }

    func testResumeQRDetectionBeforeSetupDoesNotCrash() {
        let camera = makeCamera()

        camera.resumeQRDetection()
        flushSessionQueue(camera)
    }

    func testPauseQRDetectionClearsMetadataObjectTypes() {
        let camera = makeCamera()
        let output = AVCaptureMetadataOutput()
        camera.setQRMetadataOutputForTesting(output)

        camera.pauseQRDetection()
        flushSessionQueue(camera)

        XCTAssertTrue(output.metadataObjectTypes.isEmpty,
                      "metadataObjectTypes should be empty after pauseQRDetection")
    }

    func testResumeQRDetectionGuardsAgainstUnavailableQRType() {
        let camera = makeCamera()
        let output = AVCaptureMetadataOutput()
        camera.setQRMetadataOutputForTesting(output)

        camera.resumeQRDetection()
        flushSessionQueue(camera)

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
        flushSessionQueue(camera, timeout: 10.0)

        XCTAssertNotNil(camera.qrMetadataOutput,
                        "qrMetadataOutput should be assigned after configureQROutput runs")
    }

    func testResumeQRDetectionEnablesQRTypeWhenAvailable() {
        let camera = makeCamera()
        let output = FakeQRAvailableMetadataOutput()
        camera.setQRMetadataOutputForTesting(output)

        camera.resumeQRDetection()
        flushSessionQueue(camera)

        XCTAssertEqual(output.metadataObjectTypes, [.qr],
                       "metadataObjectTypes should be set to [.qr] when .qr is available")
    }
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
