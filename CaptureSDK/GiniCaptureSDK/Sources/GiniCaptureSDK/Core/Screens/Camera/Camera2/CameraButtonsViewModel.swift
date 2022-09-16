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
    var isFlashOn: Bool = false
    var flashAction: (( Bool) -> Void)?
    var importAction: (() -> Void)?
    var captureAction: (() -> Void)?
    var imageStackAction: (() -> Void)?

    public weak var trackingDelegate: CameraScreenTrackingDelegate?
    public init(trackingDelegate: CameraScreenTrackingDelegate? = nil) {
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

    @objc func capturePressed() {
        trackingDelegate?.onCameraScreenEvent(event: Event(type: .takePicture))
        captureAction?()
    }

    func didCapture(
        imageData: Data?,
        error: CameraError?,
        orientation: UIInterfaceOrientation,
        giniConfiguration: GiniConfiguration
    ) -> GiniImageDocument? {
        guard let imageData = imageData,
            error == nil else {
            let errorMessage = error?.message ?? "Image data was nil"
            let errorLog = ErrorLog(
                description: "There was an error while capturing a picture: \(String(describing: errorMessage))",
                                    error: error)
            giniConfiguration.errorLogger.handleErrorLog(error: errorLog)
            assertionFailure("There was an error while capturing a picture")
            return nil
        }
        let imageDocument = GiniImageDocument(
            data: imageData,
            imageSource: .camera,
            deviceOrientation: orientation)
        return imageDocument
    }
}
