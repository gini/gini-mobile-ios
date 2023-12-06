//
//  CameraViewControllerDelegate.swift
//  
//
//  Created by Krzysztof Kryniecki on 12/09/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import Foundation
import UIKit

/**
 The CameraViewControllerDelegate protocol defines methods that allow you to handle captured images and user
 actions.
 */
 protocol CameraViewControllerDelegate: AnyObject {
    /**
     Called when a user takes a picture, imports a PDF/QRCode or imports one or several images.
     Once the method has been implemented, it is necessary to check if the number of
     documents accumulated doesn't exceed the minimun (`GiniImageDocument.maxPagesCount`).
     
     - parameter viewController: `CameraScreenViewController` where the documents were taken.
     - parameter document: One or several documents either captured or imported in
     the `CameraViewController`. They can contain an error produced in the validation process.
     */
    func camera(_ viewController: CameraViewController,
                didCapture document: GiniCaptureDocument)

    /**
     Called when a user selects a picker from the picker selector sheet.
     
     - parameter viewController: `CameraViewController` where the documents were taken.
     - parameter documentPicker: `DocumentPickerType` selected in the sheet.
     */
    func camera(_ viewController: CameraViewController, didSelect documentPicker: DocumentPickerType)

    /**
     Called when the `CameraViewController` appears.
     
     - parameter viewController: Camera view controller that appears.
     */
    func cameraDidAppear(_ viewController: CameraViewController)

    /**
     Called when a user taps the `MultipageReviewButton` (the one with the thumbnail of the images(s) taken).
     Once this method is called, the `MultipageReviewViewController` should be presented.
     
     - parameter viewController: Camera view controller where the button was tapped.
     */
    func cameraDidTapReviewButton(_ viewController: CameraViewController)
}
