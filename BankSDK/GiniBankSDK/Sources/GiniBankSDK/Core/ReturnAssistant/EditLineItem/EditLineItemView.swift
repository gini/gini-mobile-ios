//
//  EditLineItemView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Combine
import GiniCaptureSDK
import UIKit

final class EditLineItemView: UIView {
    private lazy var configuration = GiniBankConfiguration.shared

    private lazy var cancelButton: UIButton = {
        let title = Strings.cancelButtonTitle
        let button = UIButton()
        button.setAttributedTitle(NSAttributedString(string: title,
                                                     attributes: textAttributes(for: .body)),
                                  for: .normal)
        button.setTitle(title, for: .normal)
        button.titleLabel?.numberOfLines = 0
        button.addTarget(self, action: #selector(didTapCancel),
                         for: .touchUpInside)
        button.isExclusiveTouch = true
        // The color is set twice because in some iOS versions the `setTitleColor` does not change the color
        button.setTitleColor(.GiniBank.accent1, for: .normal)
        button.titleLabel?.textColor = .GiniBank.accent1
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        return button
    }()

    private lazy var titleLabel: UILabel = {
        let title = Strings.editTitle
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = GiniColor(light: .GiniBank.dark1,
                                    dark: .GiniBank.light1).uiColor()
        label.attributedText = NSAttributedString(string: title,
                                                  attributes: textAttributes(for: .bodyBold))
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private lazy var saveButton: UIButton = {
        let title = Strings.saveButtonTitle
        let button = UIButton()
        button.titleLabel?.numberOfLines = 0
        button.setAttributedTitle(NSAttributedString(string: title,
                                                     attributes: textAttributes(for: .bodyBold)),
                                  for: .normal)
        button.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        button.isExclusiveTouch = true
        // The color is set twice because in some iOS versions the `setTitleColor` does not change the color
        button.setTitleColor(.GiniBank.accent1, for: .normal)
        button.titleLabel?.textColor = .GiniBank.accent1
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        return button
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
		stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = Constants.stackViewSpacing
        return stackView
    }()

	private let nameContainerView = UIView()

    private lazy var nameLabelView: NameLabelView = {
        let view = NameLabelView()
        view.delegate = self
        return view
    }()

	private lazy var nameErrorView: ErrorView = {
		let view = ErrorView()
		view.alpha = 0
		view.set(errorTitle: Strings.nameErrorTitle)
		return view
	}()

	private let priceContainerView = UIView()

    private lazy var priceLabelView: PriceLabelView = {
        let view = PriceLabelView()
        view.delegate = self
        return view
    }()

	private lazy var priceErrorView: ErrorView = {
		let view = ErrorView()
		view.alpha = 0
		view.set(errorTitle: Strings.priceErrorTitle)
		return view
	}()

    private lazy var quantityView: QuantityView = {
        let view = QuantityView()
        return view
    }()

    private lazy var currencyPicker: CurrencyPickerView = {
        let view = CurrencyPickerView()
        view.alpha = 0
        view.delegate = self
        return view
    }()

    private var cancellables: Set<AnyCancellable> = []

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
        bindViews()
        setupAccessibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupAccessibility() {
        var elements: [Any] = [
            cancelButton,
            titleLabel,
            saveButton,
            nameLabelView,
            priceLabelView,
            quantityView
        ]
        if !nameErrorView.isHidden && nameErrorView.alpha > 0 {
            elements.append(nameErrorView)
        }
        if !priceErrorView.isHidden && priceErrorView.alpha > 0 {
            elements.append(priceErrorView)
        }
        accessibilityElements = elements
    }

    private func setupData(with viewModel: EditLineItemViewModel) {
        nameLabelView.text = viewModel.name
        priceLabelView.priceValue = viewModel.price
        priceLabelView.currencyValue = viewModel.currency
        quantityView.quantity = viewModel.quantity
        currencyPicker.currentCurrency = viewModel.currency
    }

    private func setupView() {
        backgroundColor = GiniColor(light: .GiniBank.light1,
                                    dark: .GiniBank.dark1).uiColor()
        addSubview(cancelButton)
        addSubview(titleLabel)
        addSubview(saveButton)

        addSubview(stackView)

        stackView.addArrangedSubview(nameContainerView)
        stackView.addArrangedSubview(priceContainerView)
        stackView.addArrangedSubview(quantityView)

		nameContainerView.addSubview(nameLabelView)
		nameContainerView.addSubview(nameErrorView)

		priceContainerView.addSubview(priceLabelView)
		priceContainerView.addSubview(priceErrorView)
        setupInputAccessoryView(for: [nameLabelView, priceLabelView])
    }

    private func bindViews() {
        nameLabelView.$didStartEditing
            .dropFirst()
            .sink { [weak self] _ in
                guard let self else { return }
                updateCurrentField(nameLabelView)
            }.store(in: &cancellables)

        priceLabelView.$didStartEditing
            .dropFirst()
            .sink { [weak self] _ in
                guard let self else { return }
                updateCurrentField(priceLabelView)
            }.store(in: &cancellables)
    }

    private func setupConstraints() {
        // Cancel button
        cancelButton.giniMakeConstraints {
            $0.leading.equalToSuperview().constant(Constants.horizontalPadding)
            $0.top.equalToSuperview().constant(Constants.verticalPadding)
            $0.height.greaterThanOrEqualTo(Constants.headerButtonMinimumHeight)
        }

        // Title label
        titleLabel.giniMakeConstraints {
            $0.centerY.equalTo(cancelButton)
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(cancelButton.trailing).constant(Constants.titlePadding)
            $0.trailing.lessThanOrEqualTo(saveButton.leading).constant(Constants.titlePadding)
        }

        // Save button
        saveButton.giniMakeConstraints {
            $0.top.equalToSuperview().constant(Constants.verticalPadding)
            $0.trailing.equalToSuperview().constant(-Constants.horizontalPadding)
            $0.height.greaterThanOrEqualTo(Constants.headerButtonMinimumHeight)
        }

        // Stack view
        stackView.giniMakeConstraints {
            $0.top.equalTo(saveButton.bottom).constant(Constants.verticalPadding)
            $0.leading.equalToSuperview().constant(Constants.horizontalPadding)
            $0.trailing.equalToSuperview().constant(-Constants.horizontalPadding)
            $0.bottom.equalToSuperview().constant(-Constants.verticalPadding)
        }

        // Name container
        nameLabelView.giniMakeConstraints {
            $0.top.equalTo(nameContainerView)
            $0.horizontal.equalTo(nameContainerView)
            $0.height.greaterThanOrEqualTo(Constants.itemContainerMaxHeight)
        }

        nameErrorView.giniMakeConstraints {
            $0.top.equalTo(nameLabelView.bottom).constant(Constants.errorPadding)
            $0.horizontal.equalTo(nameContainerView)
            $0.bottom.equalTo(nameContainerView)
        }

        // Price container
        priceLabelView.giniMakeConstraints {
            $0.top.equalTo(priceContainerView)
            $0.horizontal.equalTo(priceContainerView)
            $0.height.greaterThanOrEqualTo(Constants.itemContainerMaxHeight)
        }

        priceErrorView.giniMakeConstraints {
            $0.top.equalTo(priceLabelView.bottom).constant(Constants.errorPadding)
            $0.horizontal.equalTo(priceContainerView)
            $0.bottom.equalTo(priceContainerView)
        }

        // Quantity view
        quantityView.giniMakeConstraints {
            $0.height.greaterThanOrEqualTo(Constants.itemContainerMaxHeight)
        }
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
        currencyPicker.giniMakeConstraints {
            $0.bottom.equalTo(view.top).constant(-Constants.currencyPickerPadding)
            $0.trailing.equalTo(view)
            $0.width.equalTo(Constants.currencyPickerWidth)
        }

        UIView.animate(withDuration: Constants.animationDuration) {
            self.currencyPicker.alpha = 1
        }
    }
}

// MARK: - GiniInputAccessoryView delegate methods

extension EditLineItemView: GiniInputAccessoryViewDelegate {
    func inputAccessoryView(_ view: GiniInputAccessoryView, didSelectPrevious field: UIView) {
        field.becomeFirstResponder()
    }

    func inputAccessoryView(_ view: GiniInputAccessoryView, didSelectNext field: UIView) {
        field.becomeFirstResponder()
    }

    func inputAccessoryViewDidCancel(_ view: GiniInputAccessoryView) {
        endEditing(true)
    }
}

private extension EditLineItemView {
    struct Constants {
        static let verticalPadding: CGFloat = 16
        static let horizontalPadding: CGFloat = 16
        static let titlePadding: CGFloat = 4
        static let errorPadding: CGFloat = 2
        static let stackViewSpacing: CGFloat = 8
        static let currencyPickerPadding: CGFloat = 8
        static let currencyPickerWidth: CGFloat = 120
        static let maximumFontSize: CGFloat = 20
		static let itemContainerMaxHeight: CGFloat = 64
		static let animationDuration: CGFloat = 0.3
        static let headerButtonMinimumHeight: CGFloat = 50
    }

    struct Strings {
        static let cancelButtonTitleKey = "ginibank.digitalinvoice.cancelButtonTitle"
        static let cancelButtonTitle = NSLocalizedStringPreferredGiniBankFormat(cancelButtonTitleKey,
                                                                                comment: "Cancel")

        static let editTitleKey = "ginibank.digitalinvoice.edit.title"
        static let editTitle = NSLocalizedStringPreferredGiniBankFormat(editTitleKey,
                                                                        comment: "Edit")

        static let saveButtonTitleKey = "ginibank.digitalinvoice.lineitem.savebutton"
        static let saveButtonTitle = NSLocalizedStringPreferredGiniBankFormat(saveButtonTitleKey,
                                                                              comment: "Save")

        static let nameErrorTitleKey = "ginibank.digitalinvoice.edit.name.error"
        static let nameErrorTitle = NSLocalizedStringPreferredGiniBankFormat(nameErrorTitleKey,
                                                                             comment: "Name error title")

        static let priceErrorTitleKey = "ginibank.digitalinvoice.edit.price.error"
        static let priceErrorTitle = NSLocalizedStringPreferredGiniBankFormat(priceErrorTitleKey,
                                                                              comment: "Price error title")
    }
}
