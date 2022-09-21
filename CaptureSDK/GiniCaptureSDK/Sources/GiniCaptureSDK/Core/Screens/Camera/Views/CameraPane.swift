//
//  CameraPane.swift
//  
//
//  Created by Krzysztof Kryniecki on 14/09/2022.
//

import UIKit

final class CameraPane: UIView {
    @IBOutlet weak var cameraTitleLabel: UILabel!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var fileUploadButton: BottomLabelButton!
    @IBOutlet weak var flashButton: BottomLabelButton!
    @IBOutlet weak var thumbnailView: ThumbnailView!
    var giniConfiguration: GiniConfiguration! = nil

    func configureView(giniConfiguration: GiniConfiguration) {
        self.giniConfiguration = giniConfiguration
        backgroundColor = GiniColor(
            light: UIColor.GiniCapture.dark1,
            dark: UIColor.GiniCapture.dark1).uiColor().withAlphaComponent(0.4)
        captureButton.setTitle("", for: .normal)
        thumbnailView.isHidden = true
        fileUploadButton.configureButton(
            image: UIImageNamedPreferred(
                named: "folder") ?? UIImage(),
            name: NSLocalizedStringPreferredFormat(
            "ginicapture.camera.fileImportButtonLabel",
            comment: "Import photo"))
        flashButton.configureButton(
            image: UIImageNamedPreferred(named: "flashOff") ?? UIImage(),
            name: NSLocalizedStringPreferredFormat(
            "ginicapture.camera.flashButtonLabel",
            comment: "Flash button"))
        flashButton.iconView.image = UIImageNamedPreferred(named: "flashOff")
        flashButton.actionLabel.font = giniConfiguration.textStyleFonts[.caption1]
        flashButton.actionLabel.textColor = GiniColor(
            light: UIColor.GiniCapture.light1,
            dark: UIColor.GiniCapture.light1).uiColor()
        fileUploadButton.actionLabel.textColor = GiniColor(
            light: UIColor.GiniCapture.light1,
            dark: UIColor.GiniCapture.light1).uiColor()
        fileUploadButton.actionLabel.font = giniConfiguration.textStyleFonts[.caption1]
        if cameraTitleLabel != nil {
            cameraTitleLabel.adjustsFontForContentSizeCategory = true
            cameraTitleLabel.font = giniConfiguration.textStyleFonts[.footnote]
            cameraTitleLabel.textColor = GiniColor(
                light: UIColor.GiniCapture.light1,
                dark: UIColor.GiniCapture.light1).uiColor()
        }
    }

    func setupFlashButton(state: Bool) {
        if state {
            flashButton.configureButton(
                image: UIImageNamedPreferred(named: "flashOn") ?? UIImage(),
                name: NSLocalizedStringPreferredFormat(
                "ginicapture.camera.flashButtonLabel.On",
                comment: "Flash button"))
        } else {
            flashButton.configureButton(
                image: UIImageNamedPreferred(named: "flashOff") ?? UIImage(),
                name: NSLocalizedStringPreferredFormat(
                "ginicapture.camera.flashButtonLabel.Off",
                comment: "Flash button"))
        }
    }

    func toggleFlashButtonActivation(state: Bool) {
        flashButton.isHidden = !state
    }

    func toggleCaptureButtonActivation(state: Bool) {
        captureButton.isUserInteractionEnabled = state
        captureButton.isEnabled = state
    }

    func setupAuthorization(isHidden: Bool) {
        self.isHidden = isHidden
        captureButton.isHidden = isHidden
        flashButton.isHidden = isHidden
        if cameraTitleLabel != nil {
            cameraTitleLabel.isHidden = isHidden
        }
        fileUploadButton.isHidden = isHidden
        thumbnailView.isHidden = isHidden
    }
}
