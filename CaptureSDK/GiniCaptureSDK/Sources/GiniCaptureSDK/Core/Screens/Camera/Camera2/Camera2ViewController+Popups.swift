//
//  Camera2ViewController+Extension.swift
//  
//
//  Created by Krzysztof Kryniecki on 14/09/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit

extension Camera2ViewController {
    func showPopup(forQRDetected qrDocument: GiniQRCodeDocument, didTapDone: @escaping () -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            let newQRCodePopup = QRCodeDetectedPopupView(parent: self.view,
                                                         refView: self.cameraPreviewViewController.view,
                                                         document: qrDocument,
                                                         giniConfiguration: self.giniConfiguration)

            let didDismiss: () -> Void = { [weak self] in
                self?.detectedQRCodeDocument = nil
                self?.currentQRCodePopup = nil
            }

            if qrDocument.qrCodeFormat == nil {
                self.configurePopupViewForUnsupportedQR(newQRCodePopup, dismissCompletion: didDismiss)
            } else {
                newQRCodePopup.didTapDone = { [weak self] in
                    didTapDone()
                    self?.currentQRCodePopup?.hide(after: 0.0, completion: didDismiss)
                }
            }

            if self.currentQRCodePopup != nil {
                self.currentQRCodePopup?.hide { [weak self] in
                    self?.currentQRCodePopup = newQRCodePopup
                    self?.currentQRCodePopup?.show(didDismiss: didDismiss)
                }
            } else {
                self.currentQRCodePopup = newQRCodePopup
                self.currentQRCodePopup?.show(didDismiss: didDismiss)
            }
        }
    }

    fileprivate func configurePopupViewForUnsupportedQR(
        _ newQRCodePopup: QRCodeDetectedPopupView,
        dismissCompletion: @escaping () -> Void) {
            newQRCodePopup.backgroundColor = giniConfiguration.unsupportedQrCodePopupBackgroundColor.uiColor()
            newQRCodePopup.qrText.textColor =  giniConfiguration.unsupportedQrCodePopupTextColor.uiColor()
        newQRCodePopup.qrText.text = .localized(resource: CameraStrings.unsupportedQrCodeDetectedPopupMessage)
        newQRCodePopup.proceedButton.setTitle("✕", for: .normal)
        newQRCodePopup.proceedButton.setTitleColor(giniConfiguration.unsupportedQrCodePopupButtonColor, for: .normal)
        newQRCodePopup.proceedButton.setTitleColor(
            giniConfiguration.unsupportedQrCodePopupButtonColor.withAlphaComponent(0.5),
            for: .highlighted)
        newQRCodePopup.didTapDone = { [weak self] in
            self?.currentQRCodePopup?.hide(after: 0.0, completion: dismissCompletion)
        }
    }
}

// MARK: - Document import

extension Camera2ViewController {

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
