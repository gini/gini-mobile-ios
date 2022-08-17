//
//  HelpTipCell.swift
//  
//
//  Created by Krzysztof Kryniecki on 01/08/2022.
//

import UIKit

public class HelpTipCell: UITableViewCell, HelpCell {
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    public static var reuseIdentifier: String = "kHelpTipCell"

    public override func awakeFromNib() {
        super.awakeFromNib()
        self.iconImageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
        self.headerLabel.font = UIFont.boldSystemFont(ofSize: 18)
    }

}
