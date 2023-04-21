//
//  DigitalInvoiceAddOnListCell.swift
//  GiniBank
//
//  Created by Maciej Trybilo on 11.12.19.
//

import GiniCaptureSDK
import UIKit

class DigitalInvoiceAddOnListCell: UITableViewCell {
    static let reuseIdentifier = "DigitalInvoiceAddOnListCell"
    private lazy var addOnStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
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

    var addOns: [DigitalInvoiceAddon]? {
        didSet {
            if oldValue != addOns {
                updateLabels()
            }
        }
    }

    private func setupViews() {
        selectionStyle = .none
        backgroundColor = GiniColor(light: .GiniBank.light1, dark: .GiniBank.dark3).uiColor()
        clipsToBounds = true
        layer.cornerRadius = 8
        layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]

        contentView.addSubview(addOnStackView)
        contentView.addSubview(separatorView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            addOnStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.verticalPadding),
            addOnStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                    constant: Constants.horizontalPadding),
            addOnStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                     constant: -Constants.horizontalPadding),
            addOnStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                   constant: -Constants.verticalPadding),

            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separatorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: Constants.separatorHeight)
        ])
    }

    private func updateLabels() {
        addOnStackView.arrangedSubviews.forEach { view in
            addOnStackView.removeArrangedSubview(view)
        }

        if let addOns = addOns {
            if addOns.isEmpty {
                let currency = addOns.first?.price.currencyCode ?? "EUR"
                let zeroPrice = Price(value: 0, currencyCode: currency)
                let addOnTitle = NSLocalizedStringPreferredGiniBankFormat(
                                    "ginibank.digitalinvoice.addonname.othercharges", comment: "Other charges")
                let view = DigitalInvoiceAddOnListView(addOnTitle: addOnTitle, addOnPrice: zeroPrice)

                addOnStackView.addArrangedSubview(view)
            } else {
                addOns.forEach { addOn in
                    let view = DigitalInvoiceAddOnListView(addOnTitle: addOn.name, addOnPrice: addOn.price)
                    addOnStackView.addArrangedSubview(view)
                }
            }
        }
    }
}

private extension DigitalInvoiceAddOnListCell {
    enum Constants {
        static let separatorHeight: CGFloat = 1
        static let verticalPadding: CGFloat = 24
        static let horizontalPadding: CGFloat = 16
    }
}
