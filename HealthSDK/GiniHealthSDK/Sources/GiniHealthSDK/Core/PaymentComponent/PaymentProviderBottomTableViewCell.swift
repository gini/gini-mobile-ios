//
//  PaymentProviderBottomTableViewCell.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

class PaymentProviderBottomTableViewCell: UITableViewCell {
    static let identifier = "PaymentProviderBottomTableViewCell"

    var cellViewModel: PaymentProviderBottomTableViewCellModel? {
        didSet {
            guard let cellViewModel else { return }
            cellView.backgroundColor = cellViewModel.backgroundColor
            bankImageView.image = cellViewModel.bankImageIcon
            bankNameLabel.text = cellViewModel.bankName
            bankNameLabel.font = cellViewModel.bankNameLabelFont
            bankNameLabel.textColor = cellViewModel.bankNameLabelAccentColor

            setBorder(isSelected: cellViewModel.shouldShowSelectionIcon,
                      selectedBorderColor: cellViewModel.selectedBankBorderColor,
                      notSelectedBorderColor: cellViewModel.notSelectedBankBorderColor)

            appStoreImageView.isHidden = cellViewModel.shouldShowAppStoreIcon
            selectionIndicatorImageView.isHidden = cellViewModel.shouldShowSelectionIcon

            appStoreBankNameSpacingConstraint.priority = cellViewModel.shouldShowAppStoreIcon ? .required - 1 : .required
            selectionIndicatorBankNameSpacingConstraint.priority = cellViewModel.shouldShowSelectionIcon ? .required - 1 : .required
        }
    }

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var bankImageView: UIImageView!
    @IBOutlet weak var bankNameLabel: UILabel!
    @IBOutlet weak var appStoreImageView: UIImageView!
    @IBOutlet weak var selectionIndicatorImageView: UIImageView!
    @IBOutlet weak var appStoreBankNameSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectionIndicatorBankNameSpacingConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    private func setBorder(isSelected: Bool, selectedBorderColor: UIColor, notSelectedBorderColor: UIColor) {
        cellView.roundCorners(corners: .allCorners, radius: Constants.viewCornerRadius)
        if isSelected {
            cellView.layer.borderColor = selectedBorderColor.cgColor
            cellView.layer.borderWidth = Constants.selectedBorderWidth
        } else {
            cellView.layer.borderColor = notSelectedBorderColor.cgColor
            cellView.layer.borderWidth = Constants.notSelectedBorderWidth
        }
    }
}

extension PaymentProviderBottomTableViewCell {
    private enum Constants {
        static let viewCornerRadius = 8.0
        static let selectedBorderWidth = 3.0
        static let notSelectedBorderWidth = 1.0
    }
}
