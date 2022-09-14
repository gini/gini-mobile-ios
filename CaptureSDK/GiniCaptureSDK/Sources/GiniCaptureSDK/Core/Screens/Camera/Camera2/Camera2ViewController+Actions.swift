//
//  Camera2ViewController+Actions.swift
//  
//
//  Created by Krzysztof Kryniecki on 14/09/2022.
//

import UIKit

// MARK: - Toggle UI elements

extension Camera2ViewController {
    
    /**
     Show the capture button. Should be called when onboarding is dismissed.
     */
    public func showCaptureButton() {
        cameraPane.captureButton.alpha = 1
    }
    
    /**
     Hide the capture button. Should be called when onboarding is presented.
     */
    public func hideCaptureButton() {
        cameraPane.captureButton.alpha = 0
    }
    
    /**
     Show the camera overlay. Should be called when onboarding is dismissed.
     */
    public func showCameraOverlay() {
        cameraPreviewViewController.showCameraOverlay()
    }
    
    /**
     Hide the camera overlay. Should be called when onboarding is presented.
     */
    public func hideCameraOverlay() {
        cameraPreviewViewController.hideCameraOverlay()
    }
    
    /**
     Disable captureButton and flashToggleButton.
     */
    fileprivate func configureCameraButtonsForFileImportTip() {
        cameraPane.captureButton.isEnabled = false
        cameraPane.flashButton.isEnabled = false
    }
    
    /**
     Show the fileImportTip. Should be called when onboarding is dismissed.
     */
    public func showFileImportTip() {
        configureCameraButtonsForFileImportTip()
        createFileImportTip(giniConfiguration: giniConfiguration)
        fileImportToolTipView?.show {
            self.opaqueView?.alpha = 1
        }
        ToolTipView.shouldShowFileImportToolTip = false
    }
    
    /**
     Hide the fileImportTip. Should be called when onboarding is presented.
     */
    public func hideFileImportTip() {
        fileImportToolTipView?.alpha = 0
    }
    
    /**
     Show the QR code Tip. Should be called when fileImportTip is dismissed.
     */
    public func showQrCodeTip() {
        if ToolTipView.shouldShowQRCodeToolTip && giniConfiguration.qrCodeScanningEnabled {
            cameraPane.configureCameraButtonsForQRCodeTip()
            createQRCodeTip(giniConfiguration: giniConfiguration)
            qrCodeToolTipView?.show {
                self.opaqueView?.alpha = 1
            }
            ToolTipView.shouldShowQRCodeToolTip = false
            shouldShowQRCodeNext = false
        }
    }
    
    /**
     Hide the QR code Tip. Should be called when onboarding is presented.
     */
    public func hideQrCodeTip() {
        self.qrCodeToolTipView?.alpha = 0
    }

}
