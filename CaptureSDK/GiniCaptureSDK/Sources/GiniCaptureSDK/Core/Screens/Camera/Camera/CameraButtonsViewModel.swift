//
//  CameraButtonsViewModel.swift
//  
//
//  Created by Krzysztof Kryniecki on 14/09/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import Foundation
import GiniBankAPILibrary
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

        GiniAnalyticsManager.track(event: .flashTapped,
                                   screenName: .camera,
                                   properties: [GiniAnalyticsProperty(key: .flashActive, value: isFlashOn)])
    }

    @objc func importPressed() {
        GiniAnalyticsManager.track(event: .importFilesTapped, screenName: .camera)
        importAction?()
    }

    @objc func thumbnailPressed() {
        GiniAnalyticsManager.track(event: .multiplePagesCapturedTapped,
                                   screenName: .camera,
                                   properties: [GiniAnalyticsProperty(key: .numberOfPagesScanned, value: images.count)])
        imageStackAction?()
    }

    @objc func cancelPressed() {
        GiniAnalyticsManager.track(event: .closeTapped, screenName: .camera)
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
        let uploadMeta = Document.UploadMetadata(
            giniCaptureVersion: GiniCaptureSDKVersion,
            deviceOrientation: orientation.isLandscape ? "landscape" : "portrait",
            source: DocumentSource.camera.value,
            importMethod: "",
            entryPoint: {
                switch GiniConfiguration.shared.entryPoint {
                case .button: "button"
                case .field: "field"
                }
            }()
        )
        let imageDocument = GiniImageDocument(
            data: imageData,
            processedImageData: processedImageData,
            imageSource: .camera,
            deviceOrientation: orientation,
            uploadMetadata: uploadMeta)
        return imageDocument
    }
}
