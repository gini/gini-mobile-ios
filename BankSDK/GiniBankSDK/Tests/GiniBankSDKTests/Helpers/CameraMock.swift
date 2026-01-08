//
//  CameraMock.swift
//  GiniCapture
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import Foundation
import AVFoundation
@testable import GiniCaptureSDK

final class CameraMock: CameraProtocol {
    var didDetectIBANs: (([String]) -> Void)?

    func startOCR() {
        // This method will remain empty; no implementation is needed.
    }

    func setupIBANDetection(textOrientation: CGImagePropertyOrientation,
                            regionOfInterest: CGRect?,
                            videoPreviewLayer: AVCaptureVideoPreviewLayer?,
                            visionToAVFTransform: CGAffineTransform) {
        // This method will remain empty; no implementation is needed.
    }

    enum CameraAuthState {
        case authorized
        case unauthorized
    }
    
    var session: AVCaptureSession = .init()
    var videoDeviceInput: AVCaptureDeviceInput?
    var didDetectQR: ((GiniQRCodeDocument) -> Void)?
    var didDetectInvalidQR: ((GiniCaptureSDK.GiniQRCodeDocument) -> Void)?
    let state: CameraAuthState
    var isFlashOn: Bool = true
    var isFlashSupported: Bool = true
    var hasInitialized: Bool = true

    init(state: CameraAuthState) {
        self.state = state
    }
    
    func captureStillImage(completion: @escaping (Data?, CameraError?) -> Void) {
        // This method will remain empty; no implementation is needed.
    }

    func switchTo(newVideoDevice: AVCaptureDevice) {
        // This method will remain empty; no implementation is needed.
    }
    
    func focus(withMode mode: AVCaptureDevice.FocusMode,
               exposeWithMode exposureMode: AVCaptureDevice.ExposureMode,
               atDevicePoint point: CGPoint,
               monitorSubjectAreaChange: Bool) {
        // This method will remain empty; no implementation is needed.
    }
    
    func setup(completion: ((CameraError?) -> Void)) {
        switch state {
        case .authorized:
            completion(nil)
        case .unauthorized:
            completion(.notAuthorizedToUseDevice)
        }
    }
    
    func setupQRScanningOutput(completion: @escaping ((GiniCaptureSDK.CameraError?) -> Void)) {
        // This method will remain empty; no implementation is needed.
    }
    
    func start() {
        // This method will remain empty; no implementation is needed.
    }
    
    func stop() {
        // This method will remain empty; no implementation is needed.
    }
}
