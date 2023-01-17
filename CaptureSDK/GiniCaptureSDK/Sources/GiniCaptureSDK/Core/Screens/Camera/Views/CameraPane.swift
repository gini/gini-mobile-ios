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
    @IBOutlet weak var leftButtonsStack: UIView!
    @IBOutlet weak var thumbnailConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftStackViewMargin: NSLayoutConstraint!

    private var shouldShowFlashButton: Bool = false
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    func setupView() {
        let giniConfiguration = GiniConfiguration.shared
        backgroundColor = GiniColor(
            light: UIColor.GiniCapture.dark1,
            dark: UIColor.GiniCapture.dark1).uiColor().withAlphaComponent(0.4)
        captureButton.setTitle("", for: .normal)
        thumbnailView.isHidden = true
        fileUploadButton.setupButton(with: UIImageNamedPreferred(named: "folder") ?? UIImage(),
                                     name: NSLocalizedStringPreferredFormat("ginicapture.camera.fileImportButtonLabel",
                                                                            comment: "Upload file button title"))
        flashButton.setupButton(with: UIImageNamedPreferred(named: "flashOff") ?? UIImage(),
                                name: NSLocalizedStringPreferredFormat("ginicapture.camera.flashButtonLabel",
                                                                       comment: "Flash button title"))

        flashButton.actionLabel.font = giniConfiguration.textStyleFonts[.caption1]
        fileUploadButton.actionLabel.font = giniConfiguration.textStyleFonts[.caption1]

        flashButton.configure(with: giniConfiguration.cameraControlButtonConfiguration)
        fileUploadButton.configure(with: giniConfiguration.cameraControlButtonConfiguration)

        if cameraTitleLabel != nil {
            configureTitle(giniConfiguration: giniConfiguration)
        }
        captureButton.accessibilityLabel = ""
        captureButton.accessibilityValue =  NSLocalizedStringPreferredFormat(
            "ginicapture.camera.capturebutton",
            comment: "Capture")
    }

    private func configureTitle(giniConfiguration: GiniConfiguration) {
        cameraTitleLabel.text = NSLocalizedStringPreferredFormat(
            "ginicapture.camera.infoLabel",
            comment: "Info label")
        cameraTitleLabel.adjustsFontForContentSizeCategory = true
        cameraTitleLabel.adjustsFontSizeToFitWidth = true
        cameraTitleLabel.numberOfLines = 1
        cameraTitleLabel.minimumScaleFactor = 5/UIFont.labelFontSize
        cameraTitleLabel.font = giniConfiguration.textStyleFonts[.footnote]
        cameraTitleLabel.textColor = GiniColor(
            light: UIColor.GiniCapture.light1,
            dark: UIColor.GiniCapture.light1).uiColor()
    }

    func setupFlashButton(state: Bool) {
        if state {
            flashButton.setupButton(with: UIImageNamedPreferred(named: "flashOn") ?? UIImage(),
                                    name: NSLocalizedStringPreferredFormat("ginicapture.camera.flashButtonLabel.On",
                                                                           comment: "Flash button on voice-over title"))
            flashButton.accessibilityValue = NSLocalizedStringPreferredFormat(
                "ginicapture.camera.flashButtonLabel.On.Voice.Over",
                comment: "Flash button voice over")
        } else {
            flashButton.setupButton(with: UIImageNamedPreferred(named: "flashOff") ?? UIImage(),
                                    name: NSLocalizedStringPreferredFormat("ginicapture.camera.flashButtonLabel.Off",
                                                                           comment: "Flash button title"))
            flashButton.accessibilityValue = NSLocalizedStringPreferredFormat(
                "ginicapture.camera.flashButtonLabel.Off.Voice.Over",
                comment: "Flash button off voice over")
        }
    }

    func toggleFlashButtonActivation(state: Bool) {
        shouldShowFlashButton = state
        flashButton.isHidden = !state
    }

    func toggleCaptureButtonActivation(state: Bool) {
        captureButton.isUserInteractionEnabled = state
        captureButton.isEnabled = state
    }

    func setupAuthorization(isHidden: Bool) {
        let giniConfiguration = GiniConfiguration.shared
        self.isHidden = isHidden

        captureButton.isHidden = isHidden
        if shouldShowFlashButton {
            flashButton.isHidden = isHidden
        }
        if cameraTitleLabel != nil {
            cameraTitleLabel.isHidden = isHidden
        }
        if giniConfiguration.fileImportSupportedTypes != .none {
            fileUploadButton.isHidden = isHidden
        }
        if thumbnailView.thumbnailImageView.image != nil {
            thumbnailView.isHidden = isHidden
        }
    }

}
