//
//  HelpTipCell.swift
//  
//
//  Created by Krzysztof Kryniecki on 01/08/2022.
//

import UIKit

final class HelpTipCell: UITableViewCell, HelpCell {
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    static var reuseIdentifier: String = "kHelpTipCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    private func setupView() {
        let configuration = GiniConfiguration.shared
        isAccessibilityElement = false
        selectionStyle = .none
        backgroundColor = GiniColor(light: .GiniCapture.light1,
                                    dark: .GiniCapture.dark3).uiColor()

        iconImageView.isAccessibilityElement = true
        iconImageView.accessibilityTraits = .image
        iconImageView.adjustsImageSizeForAccessibilityContentSizeCategory = true

        headerLabel.isAccessibilityElement = true
        headerLabel.font = configuration.textStyleFonts[.calloutBold]
        headerLabel.adjustsFontForContentSizeCategory = true
        headerLabel.textColor = GiniColor(light: .GiniCapture.dark1,
                                          dark: UIColor.GiniCapture.light1).uiColor()

        descriptionLabel.isAccessibilityElement = true
        descriptionLabel.font = configuration.textStyleFonts[.subheadline]
        descriptionLabel.adjustsFontForContentSizeCategory = true
        descriptionLabel.textColor = GiniColor(light: .GiniCapture.dark6,
                                               dark: .GiniCapture.light6).uiColor()

        separatorView.backgroundColor = GiniColor(light: .GiniCapture.light3,
                                                  dark: .GiniCapture.dark4).uiColor()
    }

}
