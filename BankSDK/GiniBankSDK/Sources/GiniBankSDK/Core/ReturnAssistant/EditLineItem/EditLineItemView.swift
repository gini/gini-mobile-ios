//
//  EditLineItemView.swift
//  
//
//  Created by David Vizaknai on 07.03.2023.
//

import GiniCaptureSDK
import UIKit

final class EditLineItemView: UIView {
    private lazy var configuration = GiniBankConfiguration.shared

    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        button.titleLabel?.font = configuration.textStyleFonts[.body]
        button.setTitleColor(.GiniBank.accent1, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = configuration.textStyleFonts[.bodyBold]
        label.textColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()
        label.text = "Edit article"
        return label
    }()

    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        button.titleLabel?.font = configuration.textStyleFonts[.bodyBold]
        button.setTitleColor(.GiniBank.accent1, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()

    private lazy var nameLabel: NameLabelView = {
        let view = NameLabelView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var priceLabel: PriceLabelView = {
        let view = PriceLabelView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var quantityView: QuantityView = {
        let view = QuantityView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = GiniColor(light: .GiniBank.light1, dark: .GiniBank.dark1).uiColor()
        addSubview(cancelButton)
        addSubview(titleLabel)
        addSubview(saveButton)

        addSubview(stackView)

        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(priceLabel)
        stackView.addArrangedSubview(quantityView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                  constant: Constants.horizontalPadding),
            cancelButton.topAnchor.constraint(equalTo: topAnchor,
                                              constant: Constants.verticalPadding),

            titleLabel.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: cancelButton.leadingAnchor,
                                                constant: Constants.horizontalPadding),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: saveButton.leadingAnchor,
                                                constant: -Constants.horizontalPadding),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            saveButton.topAnchor.constraint(equalTo: topAnchor,
                                            constant: Constants.verticalPadding),
            saveButton.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                 constant: -Constants.horizontalPadding),

            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 72),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalPadding),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalPadding),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -Constants.horizontalPadding),
        ])
    }

    @objc
    private func didTapCancel() {

    }

    @objc
    private func didTapSave() {

    }
}

private extension EditLineItemView {
    enum Constants {
        static let verticalPadding: CGFloat = 24
        static let horizontalPadding: CGFloat = 16
    }
}


