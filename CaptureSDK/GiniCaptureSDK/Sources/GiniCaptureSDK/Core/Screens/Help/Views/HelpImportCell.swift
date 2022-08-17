//
//  HelpImportCell.swift
//  
//
//  Created by Krzysztof Kryniecki on 03/08/2022.
//

import UIKit

class HelpImportCell: UITableViewCell {
    static var reuseIdentifier: String = "kHelpImportCell"

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var importImageView: UIImageView!

    public override func awakeFromNib() {
        super.awakeFromNib()
        self.isAccessibilityElement = false
        self.headerLabel.isAccessibilityElement = true
        self.descriptionLabel.isAccessibilityElement = true
        self.importImageView.isAccessibilityElement = true
    }
}
