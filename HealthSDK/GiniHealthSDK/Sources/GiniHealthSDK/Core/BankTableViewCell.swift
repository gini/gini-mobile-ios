//
//  BankTableViewCell.swift
//  
//
//  Created by Nadya Karaban on 13.12.21.
//

import UIKit
class BankTableViewCell: UITableViewCell {
    @IBOutlet var bankIcon: UIImageView!
    @IBOutlet var bankName: UILabel!
    @IBOutlet var selectionIndicator: UIImageView!

    var viewModel: BankTableViewCellViewModel? {
        didSet {
            contentView.backgroundColor = UIColor.from(giniColor: GiniHealthConfiguration.shared.bankSelectionScreenBackgroundColor)
            bankName?.text = viewModel?.name
            bankName?.textColor = UIColor.from(giniColor: GiniHealthConfiguration.shared.bankSelectionCellTextColor)
            bankName?.font = GiniHealthConfiguration.shared.customFont.regular
            bankIcon?.image = viewModel?.icon
            bankIcon.layer.cornerRadius = GiniHealthConfiguration.shared.bankSelectionCellIconCornerRadius
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if(selected) {
            selectionIndicator.image = UIImageNamedPreferred(named: "selectionIndicator")
        } else {
            selectionIndicator.image = nil
        }
    }
}
