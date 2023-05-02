//
//  DigitalInvoiceTableViewHeader.swift
//  
//
//  Created by David Vizaknai on 22.02.2023.
//

import UIKit
import GiniCaptureSDK

class DigitalInvoiceTableViewTitleCell: UITableViewCell {
    static let reuseIdentifier = "DigitalInvoiceTableViewTitleCell"
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = GiniBankConfiguration.shared.textStyleFonts[.caption1]
        titleLabel.text = NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.lineitem.title",
                                                                   comment: "Articles").uppercased()
        titleLabel.textColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.adjustsFontForContentSizeCategory = true
        return titleLabel
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }

    private func setup() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
}
