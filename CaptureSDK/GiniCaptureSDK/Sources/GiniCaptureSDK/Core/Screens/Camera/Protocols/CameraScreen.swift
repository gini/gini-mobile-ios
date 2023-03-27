//
//  CameraScreen.swift
//  
//
//  Created by Krzysztof Kryniecki on 12/09/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit

@objc public protocol CameraScreen: CameraTips where Self: UIViewController {
    weak var delegate: CameraViewControllerDelegate? {get set}
    func setupCamera(ofType type: AVCaptureDevice.DeviceType)
    func addValidationLoadingView() -> UIView
    func replaceCapturedStackImages(with images: [UIImage])
}

@objc public protocol CameraTips {
    func hideCaptureButton()
    func showCaptureButton()
}
