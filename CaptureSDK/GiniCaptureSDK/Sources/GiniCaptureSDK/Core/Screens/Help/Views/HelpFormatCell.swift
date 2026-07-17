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
        // Group icon and description as a single VoiceOver element per row.
        // The section title is already read by HelpFormatSectionHeader.
        self.isAccessibilityElement = true
        self.iconImageView.isAccessibilityElement = false
        self.descriptionLabel.isAccessibilityElement = false
        if #available(iOS 14.0, *) {
            var bgConfig = UIBackgroundConfiguration.listPlainCell()
            bgConfig.backgroundColor = UIColor.clear
            backgroundConfiguration = bgConfig
        }
    }
}
