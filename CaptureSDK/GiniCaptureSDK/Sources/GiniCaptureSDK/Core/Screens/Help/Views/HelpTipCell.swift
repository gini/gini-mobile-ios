//
//  HelpTipCell.swift
//  
//
//  Created by Krzysztof Kryniecki on 01/08/2022.
//

import UIKit

public class HelpTipCell: UITableViewCell, HelpCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    public static var reuseIdentifier: String = "kHelpTipCell"

    public override func awakeFromNib() {
        super.awakeFromNib()
        self.headerLabel.font = UIFont.boldSystemFont(ofSize: 18)
    }

    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
