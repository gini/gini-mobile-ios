//
//  CameraViewController+Extension.swift
//
//
//  Created by Krzysztof Kryniecki on 14/09/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit

// MARK: - Document import

extension CameraViewController {

    @objc func showImportFileSheet() {
        let alertMessage = NSLocalizedStringPreferredFormat("ginicapture.camera.popupTitleImportPDForPhotos",
                                                            comment: "Info label")
        let message = alertMessage.isEmpty ? nil : alertMessage
        let alertViewController = UIAlertController(title: nil,
                                                    message: message,
                                                    preferredStyle: .actionSheet)

        if giniConfiguration.fileImportSupportedTypes == .pdf_and_images {
            let photosAlertActionTitle = NSLocalizedStringPreferredFormat("ginicapture.camera.popupOptionPhotos",
                                                                          comment: "Photos action")
            let photosAlertAction = UIAlertAction(title: photosAlertActionTitle,
                                                  style: .default) { [unowned self] _ in
                GiniAnalyticsManager.track(event: .uploadPhotosTapped, screenName: .camera)
                self.delegate?.camera(self, didSelect: .gallery)
            }
            alertViewController.addAction(photosAlertAction)
        }

        alertViewController.view.tintColor = .GiniCapture.accent1
        let filesAlertActionTitle = NSLocalizedStringPreferredFormat("ginicapture.camera.popupOptionFiles",
                                                                     comment: "files action")
        let filesAlertAction = UIAlertAction(title: filesAlertActionTitle,
                                             style: .default) { [unowned self] _ in
            GiniAnalyticsManager.track(event: .uploadDocumentsTapped, screenName: .camera)
            self.delegate?.camera(self, didSelect: .explorer)
        }
        alertViewController.addAction(filesAlertAction)

        if let eInvoiceEnabled = GiniCaptureUserDefaultsStorage.eInvoiceEnabled, eInvoiceEnabled {
            let eInvoiceAlertActionTitle = NSLocalizedStringPreferredFormat("ginicapture.camera.popupOptionEInvoice",
                                                                         comment: "E-Invoice action")
            let eInvoiceAlertAction = UIAlertAction(title: eInvoiceAlertActionTitle,
                                                 style: .default) { [unowned self] _ in
                GiniAnalyticsManager.track(event: .uploadDocumentsTapped, screenName: .camera)
                self.delegate?.camera(self, didSelect: .eInvoice)
            }
            alertViewController.addAction(eInvoiceAlertAction)
        }

        let cancelAlertActionTitle = NSLocalizedStringPreferredFormat("ginicapture.camera.popupCancel",
                                                                      comment: "cancel action")
        let cancelAlertAction = UIAlertAction(title: cancelAlertActionTitle,
                                              style: .cancel, handler: nil)
        alertViewController.addAction(cancelAlertAction)

        alertViewController.popoverPresentationController?.sourceView = cameraPane.fileUploadButton
        self.present(alertViewController, animated: true, completion: nil)
    }
}
