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
}
