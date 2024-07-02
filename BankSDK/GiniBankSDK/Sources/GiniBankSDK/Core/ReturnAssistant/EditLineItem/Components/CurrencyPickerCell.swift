//
//  CurrencyPickerCell.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

final class CurrencyPickerCell: UITableViewCell {
    private lazy var configuration = GiniBankConfiguration.shared
    static let reuseIdentifier = "CurrencyPickerCell"

    private lazy var checkMarkIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let checkMark = prefferedImage(named: "checkmark_icon")?
                        .tintedImageWithColor(GiniColor(light: .GiniBank.dark6, dark: .GiniBank.light6).uiColor())
        imageView.image = checkMark
        imageView.isHidden = true
        return imageView
    }()

    private lazy var currencyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = configuration.textStyleFonts[.body]
        label.textColor = GiniColor(light: .GiniBank.dark6, dark: .GiniBank.light6).uiColor()
        return label
    }()

    var currency: String? {
        didSet {
            currencyLabel.text = currency
        }
    }

    var isActive: Bool = false {
        didSet {
            checkMarkIconView.isHidden = !isActive
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupViews()
        setupConstraints()
    }

    private func setupViews() {
        backgroundColor = .clear
        selectionStyle = .none
        clipsToBounds = true
        preservesSuperviewLayoutMargins = false
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero

        contentView.addSubview(checkMarkIconView)
        contentView.addSubview(currencyLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            checkMarkIconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                       constant: 2 * Constants.padding),
            checkMarkIconView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor,
                                                   constant: Constants.padding),
            checkMarkIconView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor,
                                                      constant: -Constants.padding),
            checkMarkIconView.heightAnchor.constraint(equalToConstant: Constants.iconSize.height),
            checkMarkIconView.widthAnchor.constraint(equalToConstant: Constants.iconSize.width),
            checkMarkIconView.centerYAnchor.constraint(equalTo: centerYAnchor),

            currencyLabel.leadingAnchor.constraint(equalTo: checkMarkIconView.trailingAnchor,
                                                   constant: 2 * Constants.padding),
            currencyLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor,
                                               constant: Constants.padding),
            currencyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            currencyLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor,
                                                  constant: -Constants.padding),
            currencyLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            currencyLabel.heightAnchor.constraint(equalToConstant: Constants.labelHeight)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        currency = nil
        isActive = false
    }
}

extension CurrencyPickerCell {
    private enum Constants {
        static let labelHeight: CGFloat = 36
        static let padding: CGFloat = 4
        static let iconSize = CGSize(width: 12, height: 12)
    }
}
