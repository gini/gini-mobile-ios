//
//  Camera2ViewController+Extension.swift
//  
//
//  Created by Krzysztof Kryniecki on 14/09/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit

// MARK: - Document import

extension CameraViewController {

    @objc func showImportFileSheet() {
        let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let alertViewControllerMessage: String = NSLocalizedStringPreferredFormat(
            "ginicapture.camera.popupTitleImportPDForPhotos",
            comment: "Info label")
        if giniConfiguration.fileImportSupportedTypes == .pdf_and_images {
            alertViewController.addAction(UIAlertAction(title: NSLocalizedStringPreferredFormat(
                "ginicapture.camera.popupOptionPhotos",
                comment: "Photos action"),
                                                        style: .default) { [unowned self] _ in
                self.delegate?.camera(self, didSelect: .gallery)
            })
        }

        alertViewController.view.tintColor = .GiniCapture.accent1

        alertViewController.addAction(UIAlertAction(title: NSLocalizedStringPreferredFormat(
            "ginicapture.camera.popupOptionFiles",
            comment: "files action"),
                                                    style: .default) { [unowned self] _ in
            self.delegate?.camera(self, didSelect: .explorer)
        })
        alertViewController.addAction(UIAlertAction(title: NSLocalizedStringPreferredFormat(
            "ginicapture.camera.popupCancel",
            comment: "cancel action"),
                                                    style: .cancel, handler: nil))
        if alertViewControllerMessage.count > 0 {
            alertViewController.message = alertViewControllerMessage
        } else {
            alertViewController.message = nil
        }
        alertViewController.popoverPresentationController?.sourceView = cameraPane.fileUploadButton
        self.present(alertViewController, animated: true, completion: nil)
    }
}
