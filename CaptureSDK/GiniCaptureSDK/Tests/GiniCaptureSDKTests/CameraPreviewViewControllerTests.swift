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

    // MARK: - Camera frame color across rotation (PP-3305)

    func testCameraFrameKeepsColorAfterOrientationUpdate() {
        _ = cameraPreviewViewController.view
        XCTAssertNotNil(UIImageNamedPreferred(named: "cameraFocus"),
                        "cameraFocus asset must be available for this test to be meaningful")

        cameraPreviewViewController.changeCameraFrameColor(to: .red)
        XCTAssertTrue(hasPixel(matching: .red, in: cameraPreviewViewController.cameraFrameView.image),
                      "frame image should be tinted red after changeCameraFrameColor")

        // What viewWillTransition triggers on device rotation — it rebuilds the frame image.
        cameraPreviewViewController.updatePreviewViewOrientation()

        XCTAssertTrue(hasPixel(matching: .red, in: cameraPreviewViewController.cameraFrameView.image),
                      "frame image should stay red after an orientation update")
    }

    /**
     Scans the image for at least one mostly-opaque pixel whose color matches `color`.
     */
    private func hasPixel(matching color: UIColor, in image: UIImage?) -> Bool {
        guard let cgImage = image?.cgImage else { return false }
        let width = cgImage.width
        let height = cgImage.height
        var data = [UInt8](repeating: 0, count: width * height * 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: &data,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: width * 4,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return false
        }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let tolerance: CGFloat = 0.1
        for index in stride(from: 0, to: data.count, by: 4) {
            let pixelAlpha = CGFloat(data[index + 3]) / 255
            guard pixelAlpha > 0.5 else { continue }
            /// Un-premultiply before comparing against the target color.
            let pixelRed = CGFloat(data[index]) / 255 / pixelAlpha
            let pixelGreen = CGFloat(data[index + 1]) / 255 / pixelAlpha
            let pixelBlue = CGFloat(data[index + 2]) / 255 / pixelAlpha
            if abs(pixelRed - red) < tolerance,
               abs(pixelGreen - green) < tolerance,
               abs(pixelBlue - blue) < tolerance {
                return true
            }
        }
        return false
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
