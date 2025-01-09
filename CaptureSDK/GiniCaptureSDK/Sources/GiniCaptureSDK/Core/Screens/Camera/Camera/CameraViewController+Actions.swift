//
//  CameraViewController+Actions.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

// MARK: - Toggle UI elements

extension CameraViewController {

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

    public func setupCamera(bottomAnchor: NSLayoutYAxisAnchor) {
        cameraPreviewViewController.setupCamera(bottomAnchor: bottomAnchor)
    }

    public func stopLoadingIndicater() {
        cameraPreviewViewController.stopLoadingIndicator()
    }
}
