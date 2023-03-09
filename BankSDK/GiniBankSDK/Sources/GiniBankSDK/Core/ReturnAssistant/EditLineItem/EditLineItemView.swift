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
        button.setTitle(NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.cancelButtonTitle",
                                                                 comment: "Cancel"), for: .normal)
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
        label.text = NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.edit.title",
                                                              comment: "Edit")
        return label
    }()

    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.lineitem.savebutton",
                                                                 comment: "Save"), for: .normal)
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
        stackView.spacing = Constants.stackViewSpacing
        return stackView
    }()

    private lazy var nameLabel: NameLabelView = {
        let view = NameLabelView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var priceLabel: PriceLabelView = {
        let view = PriceLabelView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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

            stackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.stackViewPadding),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalPadding),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalPadding),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -Constants.horizontalPadding),
        ])
    }

    @objc
    private func didTapCancel() {
        viewModel?.didTapCancel()
    }

    /*Use this when currency picker is disabled for saving the currency:
     currency: priceLabel.currencyValue, */
    @objc
    private func didTapSave() {
        viewModel?.didTapSave(name: nameLabel.text,
                              price: priceLabel.priceValue,
                              currency: viewModel?.currency ?? "EUR", // Here
                              quantity: quantityView.quantity)
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
        static let stackViewPadding: CGFloat = 72
        static let stackViewSpacing: CGFloat = 8
        static let currencyPickerPadding: CGFloat = 8
        static let currencyPickerWidth: CGFloat = 120
    }
}
