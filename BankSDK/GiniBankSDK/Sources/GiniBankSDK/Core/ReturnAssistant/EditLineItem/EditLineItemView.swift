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
        let title = NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.cancelButtonTitle",
                                                             comment: "Cancel")
        let button = UIButton()
        button.setAttributedTitle(NSAttributedString(string: title, attributes: textAttributes(for: .body)),
                                  for: .normal)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        // The color is set twice beacuse in some iOS versions the `setTitleColor` does not change the color
        button.setTitleColor(.GiniBank.accent1, for: .normal)
        button.titleLabel?.textColor = .GiniBank.accent1
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.accessibilityValue = title
        return button
    }()

    private lazy var titleLabel: UILabel = {
        let title = NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.edit.title",
                                                             comment: "Edit")
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()
        label.attributedText = NSAttributedString(string: title, attributes: textAttributes(for: .bodyBold))
        label.adjustsFontForContentSizeCategory = true
        label.accessibilityValue = title
        return label
    }()

    private lazy var saveButton: UIButton = {
        let title = NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.lineitem.savebutton",
                                                             comment: "Save")
        let button = UIButton()
        button.setAttributedTitle(NSAttributedString(string: title, attributes: textAttributes(for: .bodyBold)),
                                  for: .normal)
        button.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        // The color is set twice beacuse in some iOS versions the `setTitleColor` does not change the color
        button.setTitleColor(.GiniBank.accent1, for: .normal)
        button.titleLabel?.textColor = .GiniBank.accent1
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.accessibilityValue = title
        return button
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = Constants.stackViewSpacing
        return stackView
    }()

    private lazy var nameLabel: NameLabelView = {
        let view = NameLabelView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()

    private lazy var nameErrorLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .GiniBank.error3
        label.alpha = 0
        label.text = NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.edit.name.error",
                                                              comment: "Name error title")
        if let font = configuration.textStyleFonts[.caption2] {
            if font.pointSize > Constants.maximumFontSize {
                label.font = configuration.textStyleFonts[.caption2]?.withSize(Constants.maximumFontSize)
            } else {
                label.font = configuration.textStyleFonts[.caption2]
            }
        }
        return label
    }()

    private lazy var priceLabel: PriceLabelView = {
        let view = PriceLabelView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var priceErrorLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .GiniBank.error3
        label.alpha = 0
        label.text = NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.edit.price.error",
                                                              comment: "Price error title")
        if let font = configuration.textStyleFonts[.caption2] {
            if font.pointSize > Constants.maximumFontSize {
                label.font = configuration.textStyleFonts[.caption2]?.withSize(Constants.maximumFontSize)
            } else {
                label.font = configuration.textStyleFonts[.caption2]
            }
        }
        return label
    }()

    private lazy var quantityView: QuantityView = {
        let view = QuantityView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var currencyPicker: CurrencyPickerView = {
        let view = CurrencyPickerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        view.delegate = self
        return view
    }()

    var viewModel: EditLineItemViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            setupData(with: viewModel)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupData(with viewModel: EditLineItemViewModel) {
        nameLabel.text = viewModel.name
        priceLabel.priceValue = viewModel.price
        priceLabel.currencyValue = viewModel.currency
        quantityView.quantity = viewModel.quantity
        currencyPicker.currentCurrency = viewModel.currency
    }

    private func setupView() {
        backgroundColor = GiniColor(light: .GiniBank.light1, dark: .GiniBank.dark1).uiColor()
        addSubview(cancelButton)
        addSubview(titleLabel)
        addSubview(saveButton)

        addSubview(stackView)

        stackView.setContentHuggingPriority(.defaultLow, for: .vertical)
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        priceLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        quantityView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(priceLabel)
        stackView.addArrangedSubview(quantityView)

        addSubview(nameErrorLabel)
        addSubview(priceErrorLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                  constant: Constants.horizontalPadding),
            cancelButton.topAnchor.constraint(equalTo: topAnchor,
                                              constant: Constants.verticalPadding),

            titleLabel.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: cancelButton.trailingAnchor,
                                                constant: Constants.titlePadding),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: saveButton.leadingAnchor,
                                                constant: -Constants.titlePadding),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            saveButton.topAnchor.constraint(equalTo: topAnchor,
                                            constant: Constants.verticalPadding),
            saveButton.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                 constant: -Constants.horizontalPadding),

            stackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.stackViewPadding),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalPadding),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalPadding),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -Constants.horizontalPadding),

            nameErrorLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor, constant: 16),
            nameErrorLabel.topAnchor.constraint(greaterThanOrEqualTo: nameLabel.bottomAnchor,
                                                constant: Constants.errorPadding),
            nameErrorLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            nameErrorLabel.bottomAnchor.constraint(lessThanOrEqualTo: priceLabel.topAnchor,
                                                   constant: -Constants.errorPadding),
            nameErrorLabel.centerYAnchor.constraint(equalTo: nameLabel.bottomAnchor,
                                                    constant: Constants.stackViewSpacing / 2),

            priceErrorLabel.leadingAnchor.constraint(equalTo: priceLabel.leadingAnchor, constant: 16),
            priceErrorLabel.topAnchor.constraint(greaterThanOrEqualTo: priceLabel.bottomAnchor,
                                                 constant: Constants.errorPadding),
            priceErrorLabel.trailingAnchor.constraint(equalTo: priceLabel.trailingAnchor),
            priceErrorLabel.bottomAnchor.constraint(lessThanOrEqualTo: quantityView.topAnchor,
                                                    constant: -Constants.errorPadding),
            priceErrorLabel.centerYAnchor.constraint(equalTo: priceLabel.bottomAnchor,
                                                    constant: Constants.stackViewSpacing / 2)
        ])
    }

    func hideKeyBoard() {
        self.endEditing(true)
    }

    @objc
    private func didTapCancel() {
        viewModel?.didTapCancel()
    }

    @objc
    private func didTapSave() {
        if isNameLabelValid() && isPriceLabelValid() {
            viewModel?.didTapSave(name: nameLabel.text,
                                  price: priceLabel.priceValue,
                                  currency: priceLabel.currencyValue,
                                  quantity: quantityView.quantity)
        } else {
            if !isNameLabelValid() {
                showNameLabelError()
            }

            if !isPriceLabelValid() {
                showPriceLabelError()
            }
        }
    }

    private func textAttributes(for textStyle: UIFont.TextStyle) -> [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any]
        if let font = configuration.textStyleFonts[textStyle] {
            if font.pointSize > Constants.maximumFontSize {
                attributes = [NSAttributedString.Key.font: font.withSize(Constants.maximumFontSize)]
            } else {
                attributes = [NSAttributedString.Key.font: font]
            }
        } else {
            let font = configuration.textStyleFonts[textStyle] as Any
            attributes = [NSAttributedString.Key.font: font]
        }
        return attributes
    }

    private func isNameLabelValid() -> Bool {
        return !(nameLabel.text == nil || nameLabel.text!.trimmingCharacters(in: .whitespaces).isEmpty)
    }

    private func isPriceLabelValid() -> Bool {
        return !(priceLabel.priceValue <= 0)
    }

    private func showNameLabelError() {
        UIView.animate(withDuration: 0.3) {
            self.nameErrorLabel.alpha = 1
        }
    }

    private func showPriceLabelError() {
        UIView.animate(withDuration: 0.3) {
            self.priceErrorLabel.alpha = 1
        }
    }
}

extension EditLineItemView: NameLabelViewDelegate {
    func nameLabelViewTextFieldDidChange(on: NameLabelView) {
        if nameLabel.text != nil && !nameLabel.text!.isEmpty {
            UIView.animate(withDuration: 0.3, animations: {
                self.nameErrorLabel.alpha = 0
            })
        }
    }
}

extension EditLineItemView: CurrencyPickerViewDelegate {
    func currencyPickerDidPick(_ currency: String, on view: CurrencyPickerView) {
        priceLabel.currencyValue = currency

        UIView.animate(withDuration: 0.3) {
            self.currencyPicker.alpha = 0
        }

        currencyPicker.removeFromSuperview()
    }
}

extension EditLineItemView: PriceLabelViewDelegate {
    func priceLabelViewTextFieldDidChange(on: PriceLabelView) {
        if priceLabel.priceValue > 0 {
            UIView.animate(withDuration: 0.3) {
                self.priceErrorLabel.alpha = 0
            }
        }
    }

    func showCurrencyPicker(on view: UIView) {
        addSubview(currencyPicker)

        NSLayoutConstraint.activate([
            currencyPicker.bottomAnchor.constraint(equalTo: view.topAnchor,
                                                   constant: -Constants.currencyPickerPadding),
            currencyPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            currencyPicker.widthAnchor.constraint(equalToConstant: Constants.currencyPickerWidth)
        ])

        UIView.animate(withDuration: 0.3) {
            self.currencyPicker.alpha = 1
        }
    }
}

private extension EditLineItemView {
    enum Constants {
        static let verticalPadding: CGFloat = 24
        static let horizontalPadding: CGFloat = 16
        static let titlePadding: CGFloat = 4
        static let errorPadding: CGFloat = 2
        static let stackViewPadding: CGFloat = 72
        static let stackViewSpacing: CGFloat = 26
        static let currencyPickerPadding: CGFloat = 8
        static let currencyPickerWidth: CGFloat = 120
        static let maximumFontSize: CGFloat = 20
    }
}
