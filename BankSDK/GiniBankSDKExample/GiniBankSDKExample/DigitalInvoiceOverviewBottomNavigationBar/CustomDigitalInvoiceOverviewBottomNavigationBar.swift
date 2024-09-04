//
//  CustomDigitalInvoiceBottomNavigationBar.swift
//  GiniBankSDKExample
//
//  Created by David Vizaknai on 02.03.2023.
//

import UIKit
import GiniBankSDK

final class CustomDigitalInvoiceBottomNavigationBar: UIView {

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

    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [payButton, helpButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()

    private lazy var totalLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .vertical)
        label.text = "Total"
        return label
    }()

    private lazy var totalValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()

    private lazy var skontoBadgeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var skontoBadgeView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(skontoBadgeLabel)
        return view
    }()
    
    private lazy var savedAmountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .green
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [totalValueLabel, skontoBadgeView, savedAmountLabel, buttonsStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        return stackView
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
        addSubview(stackView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    func setProceedButtonState(enabled: Bool) {
        payButton.isEnabled = enabled
    }

    func updatePrice(with price: String?) {
        totalValueLabel.text = price
    }
    
    func updateSkontoPercentageBadge(with discount: String?) {
        skontoBadgeLabel.text = discount
    }

    func updateSkontoPercentageBadgeVisibility(hidden: Bool) {
        skontoBadgeView.isHidden = hidden
    }

    func updateSkontoSavingsInfo(with text: String?) {
        savedAmountLabel.text = text
    }

    func updateSkontoSavingsInfoVisibility(hidden: Bool) {
        savedAmountLabel.isHidden = hidden
    }

    func setupConstraints(relatedTo: UIView) {
        // This can be left empty if you don't want to allign the view to the tableview
    }
}

