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
        self.isAccessibilityElement = false
        self.iconImageView.isAccessibilityElement = true
        self.descriptionLabel.isAccessibilityElement = true
    }
}
