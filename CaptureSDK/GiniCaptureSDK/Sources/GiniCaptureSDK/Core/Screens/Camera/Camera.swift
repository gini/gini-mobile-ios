//
//  Camera.swift
//  GiniCapture
//
//  Created by Peter Pult on 15/02/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

protocol CameraProtocol: AnyObject {
    var session: AVCaptureSession { get }
    var videoDeviceInput: AVCaptureDeviceInput? { get }
    var didDetectQR: ((GiniQRCodeDocument) -> Void)? { get set }
    var didDetectInvalidQR: ((GiniQRCodeDocument) -> Void)? { get set }
    var isFlashSupported: Bool { get }
    var isFlashOn: Bool { get set }

    func captureStillImage(completion: @escaping (Data?, CameraError?) -> Void)
    func focus(withMode mode: AVCaptureDevice.FocusMode,
               exposeWithMode exposureMode: AVCaptureDevice.ExposureMode,
               atDevicePoint point: CGPoint,
               monitorSubjectAreaChange: Bool)
    func setup(completion: @escaping ((CameraError?) -> Void))
    func switchTo(newVideoDevice: AVCaptureDevice)
    func setupQRScanningOutput(completion: @escaping ((CameraError?) -> Void))
    func start()
    func stop()
}

final class Camera: NSObject, CameraProtocol {
    
    // Callbacks
    var didDetectQR: ((GiniQRCodeDocument) -> Void)?
    var didDetectInvalidQR: ((GiniQRCodeDocument) -> Void)?
    var didCaptureImageHandler: ((Data?, CameraError?) -> Void)?
    
    // Session management
    var giniConfiguration: GiniConfiguration
    var isFlashOn: Bool
    var photoOutput: AVCapturePhotoOutput?
    var session: AVCaptureSession = AVCaptureSession()
    var videoDeviceInput: AVCaptureDeviceInput?

    lazy var isFlashSupported: Bool = {
        #if targetEnvironment(simulator)
        return true
        #else
        return videoDeviceInput?.device.hasFlash ?? AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back)?.hasFlash == true
        #endif
    }()
    
    fileprivate let application: UIApplication
    fileprivate let sessionQueue = DispatchQueue(label: "session queue")

    init(application: UIApplication = UIApplication.shared,
         giniConfiguration: GiniConfiguration) {
        self.application = application
        self.giniConfiguration = giniConfiguration
        self.isFlashOn = giniConfiguration.flashOnByDefault
        super.init()
    }
    
    fileprivate func configureSession(completion: @escaping ((CameraError?) -> Void)) {
        self.session.beginConfiguration()
        self.setupInput()
        self.setupPhotoCaptureOutput()
        self.session.commitConfiguration()
        if giniConfiguration.qrCodeScanningEnabled {
            self.setupQRScanningOutput(completion: completion)
        } else {
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }

    func switchTo(newVideoDevice: AVCaptureDevice) {
        guard let videoInput = videoDeviceInput else { return }

        sessionQueue.async { [weak self] in
            guard let self else { return }
            var newInput: AVCaptureDeviceInput

            do {
                newInput = try AVCaptureDeviceInput(device: newVideoDevice)
            } catch {
                return
            }

            self.session.beginConfiguration()
            self.session.removeInput(videoInput)

            if self.session.canAddInput(newInput) {
                self.session.addInput(newInput)
                self.videoDeviceInput = newInput
            } else {
                // Could not add the new input, so readding the old one.
                self.session.addInput(videoInput)
            }

            self.session.commitConfiguration()
        }
    }
    
    func setup(completion: @escaping ((CameraError?) -> Void)) {
        
        setupCaptureDevice() { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .failure(let cameraError):
                
                completion(cameraError)
                
            case .success(let captureDevice):
                
                do {
                    self.videoDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
                } catch {
                    completion(.notAuthorizedToUseDevice) // shouldn't happen
                }
                
                self.sessionQueue.async {
                    self.configureSession(completion: completion)
                }
                
                
            }
        }
    }
    
    func start() {
        sessionQueue.async {
            self.session.startRunning()
        }
    }
    
    func stop() {
        sessionQueue.async {
            self.session.stopRunning()
        }
    }
    
    func focus(withMode mode: AVCaptureDevice.FocusMode,
               exposeWithMode exposureMode: AVCaptureDevice.ExposureMode,
               atDevicePoint point: CGPoint,
               monitorSubjectAreaChange: Bool) {
        sessionQueue.async {
            guard let device = self.videoDeviceInput?.device else { return }
            guard case .some = try? device.lockForConfiguration() else {
                Log(message: "Could not lock device for configuration", event: .error)
                return
            }
            
            if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(mode) {
                device.focusPointOfInterest = point
                device.focusMode = mode
            }
            
            if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                device.exposurePointOfInterest = point
                device.exposureMode = exposureMode
            }
            
            device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
            device.unlockForConfiguration()
        }
    }
    
    func captureStillImage(completion: @escaping (Data?, CameraError?) -> Void) {
        
        // Reuse safely settings for multiple captures. Use init(from:) initializer if you want to use previous captureSettings.
        
        let capturePhotoSettings = AVCapturePhotoSettings.init(from: self.captureSettings)

        sessionQueue.async {
            // Connection will be `nil` when there is no valid input device; for example on iOS simulator
            guard let connection = self.photoOutput?.connection(with: .video) else {
                return completion(nil, .noInputDevice)
            }
            
            // Set the orientation according to the current orientation of the interface
            DispatchQueue.main.sync { [weak self] in
                guard let self = self else { return }
                connection.videoOrientation = AVCaptureVideoOrientation(self.application.statusBarOrientation)
            }

            // Trigger photo capturing
            self.didCaptureImageHandler = completion
            self.photoOutput?.capturePhoto(with: capturePhotoSettings, delegate: self)
        }
    }
    
    func setupQRScanningOutput(completion: @escaping ((CameraError?) -> Void)) {
        sessionQueue.async {
            self.configureQROutput()
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }

    private func configureQROutput() {
        session.beginConfiguration()
        let qrOutput = AVCaptureMetadataOutput()

        if !session.canAddOutput(qrOutput) {
            for previousQrOutput in session.outputs {
                session.removeOutput(previousQrOutput)
            }
        }
        session.addOutput(qrOutput)
        qrOutput.setMetadataObjectsDelegate(self, queue: sessionQueue)
        if qrOutput.availableMetadataObjectTypes.contains(.qr) {
            qrOutput.metadataObjectTypes = [.qr]
        }
        session.commitConfiguration()
    }
}

// MARK: - Fileprivate

fileprivate extension Camera {
    
    var captureSettings: AVCapturePhotoSettings {
        var captureSettings = AVCapturePhotoSettings(rawPixelFormatType: 0,
                                                     rawFileType: nil,
                                                     processedFormat: nil,
                                                     processedFileType: AVFileType.jpg)

        guard let device = self.videoDeviceInput?.device else { return captureSettings }
        
        #if !targetEnvironment(simulator)
        let flashMode: AVCaptureDevice.FlashMode = self.isFlashOn ? .on : .off
        if let imageOuput = self.photoOutput, imageOuput.supportedFlashModes.contains(flashMode) &&
            device.hasFlash {
            captureSettings.flashMode = flashMode
        }
        #endif
        
        return captureSettings
    }
    
    private func setupCaptureDevice(completion: @escaping (Result<AVCaptureDevice, CameraError>) -> Void) {
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                        for: .video,
                                                        position: .back) else {
                                                            
                                                            completion(.failure(.noInputDevice))
                                                            return
        }
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
        case .authorized:
            completion(.success(videoDevice))
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                
                DispatchQueue.main.async {
                    
                    if granted {
                        completion(.success(videoDevice))
                    } else {
                        completion(.failure(.notAuthorizedToUseDevice))
                    }
                }
            }
            
        case .denied, .restricted:
            completion(.failure(.notAuthorizedToUseDevice))
            
        @unknown default:
            completion(.failure(.notAuthorizedToUseDevice))
        }
    }
    
    func setupInput() {
        // Specify that we are capturing a photo, this will reset the format to be 4:3
        self.session.sessionPreset = .photo
        if let input = videoDeviceInput {
            if !session.canAddInput(input) {
                for previousInput in session.inputs {
                    session.removeInput(previousInput)
                }
            }
            session.addInput(input)
        }
    }
    
    func setupPhotoCaptureOutput() {
        let output = AVCapturePhotoOutput()

        if !session.canAddOutput(output) {
            for previousOutput in session.outputs {
                session.removeOutput(previousOutput)
            }
        }
        session.addOutput(output)
        photoOutput = output
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension Camera: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        if metadataObjects.isEmpty {
            return
        }

        if let metadataObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           metadataObj.type == AVMetadataObject.ObjectType.qr, let metaString = metadataObj.stringValue {
            let qrDocument = GiniQRCodeDocument(scannedString: metaString)
            do {
                try GiniCaptureDocumentValidator.validate(qrDocument, withConfig: giniConfiguration)
                DispatchQueue.main.async { [weak self] in
                    self?.didDetectQR?(qrDocument)
                }
            } catch DocumentValidationError.qrCodeFormatNotValid {
                DispatchQueue.main.async { [weak self] in
                    self?.didDetectInvalidQR?(qrDocument)
                }
            } catch {}
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension Camera: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?){
        if error != nil {
            didCaptureImageHandler?(nil, .captureFailed)
            return
        } else {
            let photoData = photo.fileDataRepresentation()
            didCaptureImageHandler?(photoData, nil)
        }
    }

}
