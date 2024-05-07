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
        button.isExclusiveTouch = true
        // The color is set twice because in some iOS versions the `setTitleColor` does not change the color
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
        button.isExclusiveTouch = true
        // The color is set twice because in some iOS versions the `setTitleColor` does not change the color
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
		stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = Constants.stackViewSpacing
        return stackView
    }()

	private let nameContainerView = UIView()

    private lazy var nameLabelView: NameLabelView = {
        let view = NameLabelView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()

	private lazy var nameErrorView: ErrorView = {
		let view = ErrorView()
		view.alpha = 0
		view.translatesAutoresizingMaskIntoConstraints = false
		let errorTitle = NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.edit.name.error",
																  comment: "Name error title")
		view.set(errorTitle: errorTitle)
		return view
	}()

	private let priceContainerView = UIView()

    private lazy var priceLabelView: PriceLabelView = {
        let view = PriceLabelView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

	private lazy var priceErrorView: ErrorView = {
		let view = ErrorView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.alpha = 0

		let errorTitle = NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.edit.price.error",
																  comment: "Price error title")
		view.set(errorTitle: errorTitle)
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
        nameLabelView.text = viewModel.name
        priceLabelView.priceValue = viewModel.price
        priceLabelView.currencyValue = viewModel.currency
        quantityView.quantity = viewModel.quantity
        currencyPicker.currentCurrency = viewModel.currency
    }

    private func setupView() {
        backgroundColor = GiniColor(light: .GiniBank.light1, dark: .GiniBank.dark1).uiColor()
        addSubview(cancelButton)
        addSubview(titleLabel)
        addSubview(saveButton)

        addSubview(stackView)

        stackView.addArrangedSubview(nameContainerView)
        stackView.addArrangedSubview(priceContainerView)
        stackView.addArrangedSubview(quantityView)

		nameContainerView.addSubview(nameLabelView)
		nameContainerView.addSubview(nameErrorView)
		setupNameContainerViewConstraints()

		priceContainerView.addSubview(priceLabelView)
		priceContainerView.addSubview(priceErrorView)
		setupPriceContainerViewConstraints()
    }

	private func setupNameContainerViewConstraints() {
		NSLayoutConstraint.activate([
			nameLabelView.topAnchor.constraint(equalTo: nameContainerView.topAnchor, constant: 0),
			nameLabelView.leadingAnchor.constraint(equalTo: nameContainerView.leadingAnchor, constant: 0),
			nameLabelView.trailingAnchor.constraint(equalTo: nameContainerView.trailingAnchor, constant: 0),
			nameLabelView.heightAnchor.constraint(equalToConstant: Constants.itemContainerMaxHeight),

			nameErrorView.topAnchor.constraint(equalTo: nameLabelView.bottomAnchor, constant: Constants.errorPadding),
			nameErrorView.leadingAnchor.constraint(equalTo: nameContainerView.leadingAnchor, constant: 0),
			nameErrorView.trailingAnchor.constraint(equalTo: nameContainerView.trailingAnchor, constant: 0),
			nameErrorView.bottomAnchor.constraint(equalTo: nameContainerView.bottomAnchor, constant: 0)
		])
	}

	private func setupPriceContainerViewConstraints() {
		NSLayoutConstraint.activate([
			priceLabelView.topAnchor.constraint(equalTo: priceContainerView.topAnchor, constant: 0),
			priceLabelView.leadingAnchor.constraint(equalTo: priceContainerView.leadingAnchor, constant: 0),
			priceLabelView.trailingAnchor.constraint(equalTo: priceContainerView.trailingAnchor, constant: 0),
			priceLabelView.heightAnchor.constraint(equalToConstant: Constants.itemContainerMaxHeight),

			priceErrorView.topAnchor.constraint(equalTo: priceLabelView.bottomAnchor, constant: Constants.errorPadding),
			priceErrorView.leadingAnchor.constraint(equalTo: priceContainerView.leadingAnchor, constant: 0),
			priceErrorView.trailingAnchor.constraint(equalTo: priceContainerView.trailingAnchor, constant: 0),
			priceErrorView.bottomAnchor.constraint(equalTo: priceContainerView.bottomAnchor, constant: 0)
		])
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

			stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.verticalPadding),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalPadding),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalPadding),

			quantityView.heightAnchor.constraint(equalToConstant: Constants.itemContainerMaxHeight)
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
        if isNameLabelValid && isPriceLabelValid {
            viewModel?.didTapSave(name: nameLabelView.text,
                                  price: priceLabelView.priceValue,
                                  currency: priceLabelView.currencyValue,
                                  quantity: quantityView.quantity)
        } else {
            if !isNameLabelValid {
                showNameLabelError()
            }

            if !isPriceLabelValid {
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

	private var isNameLabelValid: Bool {
        return !(nameLabelView.text == nil || nameLabelView.text!.trimmingCharacters(in: .whitespaces).isEmpty)
    }

	private var isPriceLabelValid: Bool {
        return !(priceLabelView.priceValue <= 0)
    }

    private func showNameLabelError() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.nameErrorView.alpha = 1
        }
    }

    private func showPriceLabelError() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.priceErrorView.alpha = 1
        }
    }
}

extension EditLineItemView: NameLabelViewDelegate {
    func nameLabelViewTextFieldDidChange(on: NameLabelView) {
        if nameLabelView.text != nil && !nameLabelView.text!.isEmpty {
            UIView.animate(withDuration: Constants.animationDuration, animations: {
                self.nameErrorView.alpha = 0
            })
        }
    }
}

extension EditLineItemView: CurrencyPickerViewDelegate {
    func currencyPickerDidPick(_ currency: String, on view: CurrencyPickerView) {
        priceLabelView.currencyValue = currency

        UIView.animate(withDuration: Constants.animationDuration) {
            self.currencyPicker.alpha = 0
        }

        currencyPicker.removeFromSuperview()
    }
}

extension EditLineItemView: PriceLabelViewDelegate {
    func priceLabelViewTextFieldDidChange(on: PriceLabelView) {
        if priceLabelView.priceValue > 0 {
            UIView.animate(withDuration: Constants.animationDuration) {
                self.priceErrorView.alpha = 0
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

        UIView.animate(withDuration: Constants.animationDuration) {
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
        static let stackViewSpacing: CGFloat = 8
        static let currencyPickerPadding: CGFloat = 8
        static let currencyPickerWidth: CGFloat = 120
        static let maximumFontSize: CGFloat = 20
		static let itemContainerMaxHeight: CGFloat = 64
		static let animationDuration: CGFloat = 0.3
    }
}
