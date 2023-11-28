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

@objc public class CameraScreen: UIViewController, CameraTips {
    public func hideCaptureButton() { }
    
    public func showCaptureButton() { }
    
    public weak var delegate: CameraViewControllerDelegate?
    func setupCamera() { }
    func addValidationLoadingView() -> UIView { UIView() }
    func replaceCapturedStackImages(with images: [UIImage]) { }
}

@objc public protocol CameraTips {
    func hideCaptureButton()
    func showCaptureButton()
}
