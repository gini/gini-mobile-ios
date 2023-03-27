//
//  Camera2ViewController+Actions.swift
//  
//
//  Created by Krzysztof Kryniecki on 14/09/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
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

    public func setupCamera() {
        cameraPreviewViewController.setupCamera()
    }
}
