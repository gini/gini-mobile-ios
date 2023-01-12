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
        self.isAccessibilityElement = false
        self.iconImageView.isAccessibilityElement = true
        self.headerLabel.isAccessibilityElement = true
        self.descriptionLabel.isAccessibilityElement = true
        self.iconImageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
    }

}
