//
//  CustomDigitalInvoiceOverviewBottomNavigationBar.swift
//  GiniBankSDKExample
//
//  Created by David Vizaknai on 02.03.2023.
//

import UIKit
import GiniBankSDK

final class CustomDigitalInvoiceOverviewBottomNavigationBar: UIView {

    lazy var payButton: UIButton = {
        let button = UIButton()
        button.setTitle("Pay here", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    lazy var helpButton: UIButton = {
        let button = UIButton()
        button.setTitle("Help", for: .normal)
        button.setTitleColor(.green, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var totalValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init() {
        super.init(frame: .zero)
        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(payButton)
        addSubview(helpButton)
        addSubview(totalValueLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            totalValueLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            totalValueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            payButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            payButton.topAnchor.constraint(equalTo: totalValueLabel.bottomAnchor, constant: 16),
            payButton.heightAnchor.constraint(equalToConstant: 44),
            payButton.widthAnchor.constraint(equalToConstant: 88),

            helpButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            helpButton.heightAnchor.constraint(equalToConstant: 44),
            helpButton.widthAnchor.constraint(equalToConstant: 88),
            helpButton.topAnchor.constraint(equalTo: totalValueLabel.bottomAnchor, constant: 16)
        ])
    }

    func setProceedButtonState(enabled: Bool) {
        payButton.isEnabled = enabled
    }

    func updatePrice(with price: String?) {
        totalValueLabel.text = price
    }

    func setupConstraints(relatedTo: UIView) {
        // This can be left empty if you don't want to allign the view to the tableview
    }
}

