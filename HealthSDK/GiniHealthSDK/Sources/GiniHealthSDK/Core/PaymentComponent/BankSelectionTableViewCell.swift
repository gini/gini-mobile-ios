//
//  BankSelectionTableViewCell.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

class BankSelectionTableViewCell: UITableViewCell {
    static let identifier = "BankSelectionTableViewCell"

    var cellViewModel: BankSelectionTableViewCellModel? {
        didSet {
            guard let cellViewModel else { return }
            cellView.backgroundColor = cellViewModel.backgroundColor
            bankImageView.image = cellViewModel.bankImageIcon
            bankImageView.layer.cornerRadius = Constants.bankIconCornerRadius
            bankImageView.layer.borderWidth = Constants.bankIconBorderWidth
            bankImageView.layer.borderColor = cellViewModel.bankIconBorderColor.cgColor
            bankNameLabel.text = cellViewModel.bankName
            bankNameLabel.font = cellViewModel.bankNameLabelFont
            bankNameLabel.textColor = cellViewModel.bankNameLabelAccentColor

            setBorder(isSelected: cellViewModel.shouldShowSelectionIcon,
                      selectedBorderColor: cellViewModel.selectedBankBorderColor,
                      notSelectedBorderColor: cellViewModel.notSelectedBankBorderColor)
            
            appStoreImageView.isHidden = !cellViewModel.shouldShowAppStoreIcon
            selectionIndicatorImageView.image = cellViewModel.selectionIndicatorImage
            selectionIndicatorImageView.isHidden = !cellViewModel.shouldShowSelectionIcon

            appStoreBankNameSpacingConstraint.priority = !cellViewModel.shouldShowAppStoreIcon ? .required - 1 : .required
            selectionIndicatorBankNameSpacingConstraint.priority = !cellViewModel.shouldShowSelectionIcon ? .required - 1 : .required
        }
    }

    @IBOutlet private weak var cellView: UIView!
    @IBOutlet private weak var bankImageView: UIImageView!
    @IBOutlet private weak var bankNameLabel: UILabel!
    @IBOutlet private weak var appStoreImageView: UIImageView!
    @IBOutlet private weak var selectionIndicatorImageView: UIImageView!
    @IBOutlet private weak var appStoreBankNameSpacingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var selectionIndicatorBankNameSpacingConstraint: NSLayoutConstraint!

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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        appStoreBankNameSpacingConstraint.priority = .required - 1
        selectionIndicatorBankNameSpacingConstraint.priority = .required - 1
    }
}

extension BankSelectionTableViewCell {
    private enum Constants {
        static let viewCornerRadius = 8.0
        static let selectedBorderWidth = 3.0
        static let notSelectedBorderWidth = 1.0
        static let bankIconBorderWidth = 1.0
        static let bankIconCornerRadius = 6.0
    }
}
