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
            configureTitle(giniConfiguration: giniConfiguration)
        }
        captureButton.accessibilityLabel = ""
        captureButton.accessibilityValue =  NSLocalizedStringPreferredFormat(
            "ginicapture.camera.capturebutton",
            comment: "Capture")
        updateThumbnailConstraint()
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
            flashButton.configureButton(
                image: UIImageNamedPreferred(named: "flashOn") ?? UIImage(),
                name: NSLocalizedStringPreferredFormat(
                "ginicapture.camera.flashButtonLabel.On",
                comment: "Flash button on voice over"))
            flashButton.accessibilityValue = NSLocalizedStringPreferredFormat(
                "ginicapture.camera.flashButtonLabel.On.Voice.Over",
                comment: "Flash button voice over")
        } else {
            flashButton.configureButton(
                image: UIImageNamedPreferred(named: "flashOff") ?? UIImage(),
                name: NSLocalizedStringPreferredFormat(
                "ginicapture.camera.flashButtonLabel.Off",
                comment: "Flash button"))
            flashButton.accessibilityValue = NSLocalizedStringPreferredFormat(
                "ginicapture.camera.flashButtonLabel.Off.Voice.Over",
                comment: "Flash button off voice over")
        }
    }

    func toggleFlashButtonActivation(state: Bool) {
        flashButton.isHidden = !state
        updateThumbnailConstraint()
    }

    func toggleCaptureButtonActivation(state: Bool) {
        captureButton.isUserInteractionEnabled = state
        captureButton.isEnabled = state
    }

    func setupAuthorization(isHidden: Bool) {
        let giniConfiguration = GiniConfiguration.shared
        self.isHidden = isHidden
        captureButton.isHidden = isHidden
        flashButton.isHidden = isHidden
        if cameraTitleLabel != nil {
            cameraTitleLabel.isHidden = isHidden
        }
        if giniConfiguration.fileImportSupportedTypes != .none {
            fileUploadButton.isHidden = isHidden
        }
        if thumbnailView.thumbnailImageView.image != nil {
            thumbnailView.isHidden = isHidden
        }
        updateThumbnailConstraint()
    }

    private func numberOfVisibleButtons() -> Int {
        var number = 2
        if flashButton.isHidden {
            number -= 1
        }
        if fileUploadButton.isHidden {
            number -= 1
        }
        return number
    }

    private func onlyLeftVisibleButtonImgWidth() -> CGFloat {
        if flashButton.isHidden == false {
            return flashButton.iconView.image?.size.width ?? 0
        }
        return fileUploadButton.iconView.image?.size.width ?? 0
    }

    func updateThumbnailConstraint(
    ) {
        if UIDevice.current.isIphone {
            let numberOfButtons = numberOfVisibleButtons()
            if numberOfButtons == 0 || numberOfButtons == 2 {
                let flashWidth = (flashButton.iconView.image?.size.width ?? 0 ) * 0.5
                let buttonWidth = leftButtonsStack.bounds.size.width * 0.5 - 2.5
                thumbnailConstraint.constant = 30 + buttonWidth * 0.5 - flashWidth
                leftStackViewMargin.constant = 30
            } else {
                leftStackViewMargin.constant = 0
                let rightSide = UIScreen.main.bounds.size.width * 0.5 - captureButton.bounds.size.width * 0.5
                thumbnailConstraint.constant = rightSide * 0.5 - thumbnailView.bounds.size.width * 0.5
            }
            layoutSubviews()
        }
    }
}
