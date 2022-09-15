//
//  Camera2ViewController+Extension.swift
//  
//
//  Created by Krzysztof Kryniecki on 14/09/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit

extension Camera2ViewController {
    /*
    func createFileImportTip(giniConfiguration: GiniConfiguration) {
        opaqueView = OpaqueViewFactory.create(with: giniConfiguration.toolTipOpaqueBackgroundStyle)
        opaqueView?.alpha = 0
        view.addSubview(opaqueView!)

        fileImportToolTipView = ToolTipView(text: .localized(resource: CameraStrings.fileImportTipLabel),
                                  giniConfiguration: giniConfiguration,
                                            referenceView: cameraPane.fileUploadButton,
                                  superView: self.view,
                                  position: UIDevice.current.isIpad ? .left : .above,
                                  distanceToRefView: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        
        fileImportToolTipView?.willDismiss = { [weak self] in
            guard let self = self else { return }
            self.opaqueView?.removeFromSuperview()
            self.fileImportToolTipView = nil
            if !ToolTipView.shouldShowFileImportToolTip && ToolTipView.shouldShowQRCodeToolTip && self.shouldShowQRCodeNext {
                self.cameraPane.configureCameraWhenTooltipDismissed()
                self.showQrCodeTip()
            } else {
                self.cameraPane.configureCameraWhenTooltipDismissed()
            }
        }
        fileImportToolTipView?.willDismissOnCloseButtonTap = { [weak self] in
            guard let self = self else { return }
            self.opaqueView?.removeFromSuperview()
            self.fileImportToolTipView = nil
            if !ToolTipView.shouldShowFileImportToolTip && ToolTipView.shouldShowQRCodeToolTip {
                self.cameraPane.configureCameraWhenTooltipDismissed()
                self.showQrCodeTip()
            } else {
                self.cameraPane.configureCameraWhenTooltipDismissed()
            }
        }
    }
    
    func createQRCodeTip(giniConfiguration: GiniConfiguration) {
        qrCodeToolTipView = ToolTipView(text: .localized(resource: CameraStrings.qrCodeTipLabel),
                                  giniConfiguration: giniConfiguration,
                                        referenceView: cameraPane.captureButton,
                                  superView: self.view,
                                  position: UIDevice.current.isIpad ? .left : .above,
                                  distanceToRefView: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        
        qrCodeToolTipView?.willDismiss = { [weak self] in
            self?.cameraPane.configureCameraWhenTooltipDismissed()
        }
        
        qrCodeToolTipView?.willDismissOnCloseButtonTap = { [weak self] in
            self?.cameraPane.configureCameraWhenTooltipDismissed()
        }
    }
    */
    
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
        newQRCodePopup.proceedButton.setTitleColor(giniConfiguration.unsupportedQrCodePopupButtonColor.withAlphaComponent(0.5), for: .highlighted)
        newQRCodePopup.didTapDone = { [weak self] in
            self?.currentQRCodePopup?.hide(after: 0.0, completion: dismissCompletion)
        }
    }
}
