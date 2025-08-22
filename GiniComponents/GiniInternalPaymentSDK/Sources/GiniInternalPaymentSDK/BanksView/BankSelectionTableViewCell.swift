//
//  BankSelectionTableViewCell.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniUtilites

class BankSelectionTableViewCell: UITableViewCell, ReusableView {
    private let cellView = UIView()
    
    private let bankNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let bankImageView = UIImageView()
    private let selectionIndicatorImageView = UIImageView()
    
    var cellViewModel: BankSelectionTableViewCellModel? {
        didSet { updateCell(cellViewModel) }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private

private extension BankSelectionTableViewCell {
    enum Constants {
        static let viewCornerRadius = 8.0
        static let selectedBorderWidth = 3.0
        static let notSelectedBorderWidth = 1.0
        static let bankIconBorderWidth = 1.0
        static let bankIconCornerRadius = 6.0
        static let bankIconSide = 32.0
        static let sectionIconSide = 24.0
        static let paddingHorizontal = 16.0
        static let paddingVertical = 4.0
        static let contentPadding = 16.0
    }
}

private extension BankSelectionTableViewCell {
    func setupViews() {
        contentView.addSubview(cellView)
        backgroundColor = .clear
        selectionStyle = .none
        accessibilityTraits = .button
        
        cellView.addSubview(bankImageView)
        cellView.addSubview(bankNameLabel)
        cellView.addSubview(selectionIndicatorImageView)
        cellView.layer.cornerRadius = Constants.viewCornerRadius
        
        bankImageView.layer.cornerRadius = Constants.bankIconCornerRadius
        bankImageView.layer.borderWidth = Constants.bankIconBorderWidth
        bankImageView.clipsToBounds = true
    }
    
    func setupConstraints() {
        cellView.translatesAutoresizingMaskIntoConstraints = false
        bankImageView.translatesAutoresizingMaskIntoConstraints = false
        selectionIndicatorImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cellView.topAnchor.constraint(equalTo: contentView.topAnchor,
                                          constant: Constants.paddingVertical),
            cellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                             constant: -Constants.paddingVertical),

            bankImageView.centerYAnchor.constraint(equalTo: cellView.centerYAnchor),
            bankImageView.leadingAnchor.constraint(equalTo: cellView.leadingAnchor,
                                                   constant: Constants.paddingHorizontal),
            bankImageView.widthAnchor.constraint(equalToConstant: Constants.bankIconSide),
            bankImageView.heightAnchor.constraint(equalToConstant: Constants.bankIconSide),
            bankNameLabel.topAnchor.constraint(equalTo: cellView.topAnchor,
                                               constant: Constants.contentPadding),
            bankNameLabel.bottomAnchor.constraint(equalTo: cellView.bottomAnchor,
                                                  constant: -Constants.contentPadding),
            bankNameLabel.leadingAnchor.constraint(equalTo: bankImageView.trailingAnchor,
                                                   constant: Constants.paddingHorizontal),
            selectionIndicatorImageView.centerYAnchor.constraint(equalTo: cellView.centerYAnchor),
            selectionIndicatorImageView.trailingAnchor.constraint(equalTo: cellView.trailingAnchor,
                                                                  constant: -Constants.paddingHorizontal),
            selectionIndicatorImageView.leadingAnchor.constraint(equalTo: bankNameLabel.trailingAnchor,
                                                                 constant: -Constants.paddingHorizontal),
            selectionIndicatorImageView.widthAnchor.constraint(equalToConstant: Constants.sectionIconSide),
            selectionIndicatorImageView.heightAnchor.constraint(equalToConstant: Constants.sectionIconSide)
        ])
    }
    
    func updateCell(_ cellViewModel: BankSelectionTableViewCellModel?) {
        guard let cellViewModel else { return }
        
        let isSelected = cellViewModel.shouldShowSelectionIcon

        accessibilityTraits = isSelected ? [.button, .selected] : .button
        bankImageView.image = cellViewModel.bankImageIcon
        bankImageView.layer.borderColor = cellViewModel.colors.bankIconBorderColor.cgColor

        bankNameLabel.text = cellViewModel.bankName
        bankNameLabel.font = cellViewModel.bankNameFont
        bankNameLabel.textColor = cellViewModel.colors.bankNameAccentColor

        cellView.backgroundColor = cellViewModel.colors.backgroundColor
        cellView.layer.borderWidth = isSelected ? Constants.selectedBorderWidth : Constants.notSelectedBorderWidth
        cellView.layer.borderColor = isSelected ? cellViewModel.colors.selectedBankBorderColor.cgColor : cellViewModel.colors.notSelectedBankBorderColor.cgColor

        selectionIndicatorImageView.image = cellViewModel.selectionIndicatorImage
        selectionIndicatorImageView.isHidden = !isSelected
    }
}
