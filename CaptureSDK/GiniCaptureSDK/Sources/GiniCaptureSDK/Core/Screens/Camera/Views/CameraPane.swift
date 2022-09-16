//
//  CameraPane.swift
//  
//
//  Created by Krzysztof Kryniecki on 14/09/2022.
//

import UIKit

class CameraPane: UIView {
    @IBOutlet weak var cameraTitleLabel: UILabel!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var fileUploadButton: BottomLabelButton!
    @IBOutlet weak var flashButton: BottomLabelButton!
    @IBOutlet weak var thumbnailView: ThumbnailView!
    let giniConfiguration: GiniConfiguration! = nil

    func configureView(giniConfiguration: GiniConfiguration) {
        thumbnailView.isHidden = true
        fileUploadButton.configureButton(
            image: UIImageNamedPreferred(
                named: "folder") ?? UIImage(),
            name: NSLocalizedStringPreferredFormat(
            "ginicapture.camera.fileImportButtonLabel",
            comment: "Import photo"),
            giniconfiguration: giniConfiguration)
        flashButton.configureButton(
            image: UIImageNamedPreferred(named: "flashOff") ?? UIImage(),
            name: NSLocalizedStringPreferredFormat(
            "ginicapture.camera.flashButtonLabel",
            comment: "Flash button"),
            giniconfiguration: giniConfiguration)
        flashButton.iconView.image = UIImageNamedPreferred(named: "flashOn")
    }

    func toggleCaptureButtonActivation(state: Bool) {
        captureButton.isUserInteractionEnabled = state
        captureButton.isEnabled = state
    }
}
