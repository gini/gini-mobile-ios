//
//  HelpFormatCell.swift
//  
//
//  Created by Krzysztof Kryniecki on 03/08/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit

final class HelpFormatCell: UITableViewCell, HelpCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var separatorView: UIView!
    static var reuseIdentifier: String = "kHelpFormatCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        configureAccessibility()
        var bgConfig = UIBackgroundConfiguration.listPlainCell()
        bgConfig.backgroundColor = UIColor.clear
        backgroundConfiguration = bgConfig
    }

    // Group icon and description as a single VoiceOver element per row.
    // The section title is already read by HelpFormatSectionHeader.
    private func configureAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = .staticText
        iconImageView.isAccessibilityElement = false
        descriptionLabel.isAccessibilityElement = false
    }
}
