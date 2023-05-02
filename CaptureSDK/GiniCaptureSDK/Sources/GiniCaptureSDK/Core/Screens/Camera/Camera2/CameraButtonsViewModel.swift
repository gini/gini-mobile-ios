//
//  CameraButtonsViewModel.swift
//  
//
//  Created by Krzysztof Kryniecki on 14/09/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import Foundation
import UIKit

public final class CameraButtonsViewModel {
    // Pane buttons
    var isFlashOn: Bool = false
    var flashAction: (( Bool) -> Void)?
    var importAction: (() -> Void)?
    var captureAction: (() -> Void)?
    var imageStackAction: (() -> Void)?

    // NavigationBar buttons
    var cancelAction: (() -> Void)?
    var helpAction: (() -> Void)?
    var backButtonAction: (() -> Void)?
    var imagesUpdated: (([UIImage]) -> Void)?

    var images: [UIImage] = [] {
        didSet {
            imagesUpdated?(images)
        }
    }

    public weak var trackingDelegate: CameraScreenTrackingDelegate?
    public init(
        trackingDelegate: CameraScreenTrackingDelegate? = nil
    ) {
        self.trackingDelegate = trackingDelegate
    }

    @objc func toggleFlash() {
        isFlashOn = !isFlashOn
        flashAction?(isFlashOn)
    }

    @objc func importPressed() {
        importAction?()
    }

    @objc func thumbnailPressed() {
        imageStackAction?()
    }

    @objc func cancelPressed() {
        cancelAction?()
    }

    @objc func capturePressed() {
        trackingDelegate?.onCameraScreenEvent(event: Event(type: .takePicture))
        captureAction?()
    }

    func didCapture(
        imageData: Data?,
        processedImageData: Data?,
        error: CameraError?,
        orientation: UIInterfaceOrientation,
        giniConfiguration: GiniConfiguration
    ) -> GiniImageDocument? {
        guard let imageData = imageData,
              let processedImageData = processedImageData,
            error == nil else {
            let errorMessage = error?.message ?? "Image data was nil"
            let errorLog = ErrorLog(
                description: "There was an error while capturing a picture: \(String(describing: errorMessage))",
                                    error: error)
            giniConfiguration.errorLogger.handleErrorLog(error: errorLog)
            return nil
        }
        let imageDocument = GiniImageDocument(
            data: imageData,
            processedImageData: processedImageData,
            imageSource: .camera,
            deviceOrientation: orientation)
        return imageDocument
    }
}
