//
//  CameraMock.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 2/11/19.
//

import Foundation
import AVFoundation
@testable import GiniCaptureSDK

final class CameraMock: CameraProtocol {
    
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
    
    init(state: CameraAuthState) {
        self.state = state
    }
    
    func captureStillImage(completion: @escaping (Data?, CameraError?) -> Void) {
        
    }
    
    func focus(withMode mode: AVCaptureDevice.FocusMode,
               exposeWithMode exposureMode: AVCaptureDevice.ExposureMode,
               atDevicePoint point: CGPoint,
               monitorSubjectAreaChange: Bool) {
        
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
        
    }
    
    func start() {
        
    }
    
    func stop() {
        
    }
}
