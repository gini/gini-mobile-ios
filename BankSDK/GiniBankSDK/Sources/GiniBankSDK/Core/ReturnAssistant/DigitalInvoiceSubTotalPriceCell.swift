//
//  DigitalInvoiceSubTotalPriceCell.swift
//  GiniBank
//
//  Created by Maciej Trybilo on 11.12.19.
//

import GiniCaptureSDK
import UIKit

class DigitalInvoiceSubTotalPriceCell: UITableViewCell {
    private lazy var configuration = GiniBankConfiguration.shared
    private lazy var subTotalLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = configuration.textStyleFonts[.body]
        label.textColor = .GiniBank.dark7

        return label
    }()
    private lazy var subTotalValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.font = configuration.textStyleFonts[.bodyBold]
        label.textColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()

        return label
    }()

    private lazy var addOnLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = configuration.textStyleFonts[.body]
        label.textColor = .GiniBank.dark7

        return label
    }()

    private lazy var addOnValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.font = configuration.textStyleFonts[.bodyBold]
        label.textColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()
        return label
    }()

    private var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = GiniColor(light: .GiniBank.light3, dark: .GiniBank.dark4).uiColor()
        return view
    }()

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
    
    var totalPrice: Price? {
        didSet {
            updateLabels()
        }
    }

    var addOns: [DigitalInvoiceAddon]? {
        didSet {
            updateLabels()
        }
    }
    
    private func setupViews() {
        selectionStyle = .none
        backgroundColor = GiniColor(light: .GiniBank.light1, dark: .GiniBank.dark3).uiColor()
        clipsToBounds = true
        layer.cornerRadius = 8
        layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]

        [subTotalLabel, subTotalValueLabel, addOnLabel, addOnValueLabel, separatorView].forEach { label in
            contentView.addSubview(label)
        }

        subTotalLabel.text = NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.lineitem.subTotalTitle",
                                                                      comment: "Subtotal")
        addOnLabel.text = NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.lineitem.addOnTitle",
                                                                   comment: "Subtotal")
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            subTotalLabel.topAnchor.constraint(equalTo: contentView.topAnchor,
                                               constant: Constants.verticalPadding),
            subTotalLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                   constant: Constants.horizontalPadding),
            subTotalLabel.trailingAnchor.constraint(equalTo: subTotalValueLabel.leadingAnchor,
                                                    constant: -Constants.labelPadding),
            subTotalLabel.bottomAnchor.constraint(equalTo: addOnLabel.topAnchor,
                                                  constant: -Constants.labelPadding),

            subTotalValueLabel.centerYAnchor.constraint(equalTo: subTotalLabel.centerYAnchor),
            subTotalValueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                         constant: -Constants.horizontalPadding),
            subTotalValueLabel.bottomAnchor.constraint(equalTo: addOnValueLabel.topAnchor,
                                                       constant: -Constants.labelPadding),

            addOnLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                constant: Constants.horizontalPadding),
            addOnLabel.trailingAnchor.constraint(equalTo: addOnValueLabel.leadingAnchor,
                                                 constant: -Constants.labelPadding),
            addOnLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                               constant: -Constants.verticalPadding),

            addOnValueLabel.centerYAnchor.constraint(equalTo: addOnLabel.centerYAnchor),
            addOnValueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                      constant: -Constants.horizontalPadding),
            addOnValueLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                    constant: -Constants.verticalPadding),

            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separatorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: Constants.separatorHeight)
        ])
    }

    private func updateLabels() {
        if let totalPriceString = totalPrice?.string {
            subTotalValueLabel.text = totalPriceString
        }

        if let addOns = addOns {
            if addOns.isEmpty {
                let currency = addOns.first?.price.currencyCode ?? "EUR"
                let zeroPrice = Price(value: 0, currencyCode: currency)
                addOnValueLabel.text = zeroPrice.string
            } else {
                let totalAddonValue = addOns.map({ $0.price.value }).reduce(0, +)
                let currency = addOns.first?.price.currencyCode ?? "EUR"

                let totalAddonPrice = Price(value: totalAddonValue, currencyCode: currency).string

                addOnValueLabel.text = totalAddonPrice
            }
        }
    }
}

private extension DigitalInvoiceSubTotalPriceCell {
    enum Constants {
        static let separatorHeight:   CGFloat = 1
        static let verticalPadding:   CGFloat = 24
        static let horizontalPadding: CGFloat = 16
        static let labelPadding:      CGFloat = 8
    }
}
