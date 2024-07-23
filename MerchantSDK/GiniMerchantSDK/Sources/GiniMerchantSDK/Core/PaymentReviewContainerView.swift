//
//  PaymentReviewContainerView.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniUtilites

enum TextFieldType: Int {
    case recipientFieldTag = 1
    case ibanFieldTag
    case amountFieldTag
    case usageFieldTag
}

class PaymentReviewContainerView: UIView {
    private let ibanValidator = IBANValidator()

    private lazy var recipientErrorLabel = buildErrorLabel()
    private lazy var usageErrorLabel = buildErrorLabel()
    private lazy var ibanErrorLabel = buildErrorLabel()
    private lazy var amountErrorLabel = buildErrorLabel()

    private let paymentInfoStackView = EmptyStackView(orientation: .vertical, distribution: .fill, spacing: Constants.stackViewSpacing)
    private let recipientStackView = EmptyStackView(orientation: .vertical, distribution: .fill)
    private let ibanAmountContainerStackView = EmptyStackView(orientation: .vertical, distribution: .fill)
    private let ibanAmountHorizontalStackView =  EmptyStackView(orientation: .horizontal, distribution: .fill, spacing: Constants.stackViewSpacing)

    private let ibanAmountErrorsHorizontalStackView = EmptyStackView(orientation: .horizontal, distribution: .fill)
    private let ibanErrorStackView = EmptyStackView(orientation: .vertical, distribution: .fill)
    private let amountErrorStackView = EmptyStackView(orientation: .vertical, distribution: .fill)
    private let usageStackView = EmptyStackView(orientation: .vertical, distribution: .fill)

    private lazy var recipientTextFieldView = buildTextFieldWithLabelView(tag: TextFieldType.recipientFieldTag.rawValue, isEditable: false)
    private lazy var ibanTextFieldView = buildTextFieldWithLabelView(tag: TextFieldType.ibanFieldTag.rawValue, isEditable: false)
    private lazy var amountTextFieldView = buildTextFieldWithLabelView(tag: TextFieldType.amountFieldTag.rawValue, isEditable: model.isAmountFieldEditable)
    private lazy var usageTextFieldView = buildTextFieldWithLabelView(tag: TextFieldType.usageFieldTag.rawValue, isEditable: false)

    private let buttonsView = EmptyView()

    private lazy var payInvoiceButton: PaymentPrimaryButton = {
        let button = PaymentPrimaryButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.frame = CGRect(x: 0, y: 0, width: .greatestFiniteMagnitude, height: Constants.buttonViewHeight)
        return button
    }()

    private let bottomView = EmptyView()
    private let buttonsStackView = EmptyStackView(orientation: .horizontal)
    private let bottomStackView = EmptyStackView(orientation: .horizontal)

    private lazy var poweredByGiniView: PoweredByGiniView = {
        let view = PoweredByGiniView()
        view.viewModel = PoweredByGiniViewModel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var amountToPay = Price(value: 0, currencyCode: "€")
    private var lastValidatedIBAN = ""

    private var paymentInputFields: [TextFieldWithLabelView] = []
    private var paymentInputFieldsErrorLabels: [UILabel] = []
    private let model: PaymentReviewContainerViewModel
    var onPayButtonClicked: (() -> Void)?
    
    init(viewModel: PaymentReviewContainerViewModel) {
        self.model = viewModel
        super.init(frame: .zero)
        setupViewHierarchy()
        setupLayout()
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViewHierarchy() {
        paymentInputFields = [recipientTextFieldView, amountTextFieldView, ibanTextFieldView, usageTextFieldView]
        paymentInputFieldsErrorLabels = [recipientErrorLabel, amountErrorLabel, ibanErrorLabel, usageErrorLabel]

        recipientStackView.addArrangedSubview(recipientTextFieldView)
        recipientStackView.addArrangedSubview(recipientErrorLabel)

        ibanAmountHorizontalStackView.addArrangedSubview(ibanTextFieldView)
        ibanAmountHorizontalStackView.addArrangedSubview(amountTextFieldView)

        ibanErrorStackView.addArrangedSubview(ibanErrorLabel)
        amountErrorStackView.addArrangedSubview(amountErrorLabel)
        ibanAmountErrorsHorizontalStackView.addArrangedSubview(ibanErrorStackView)
        ibanAmountErrorsHorizontalStackView.addArrangedSubview(amountErrorStackView)

        ibanAmountContainerStackView.addArrangedSubview(ibanAmountHorizontalStackView)
        ibanAmountContainerStackView.addArrangedSubview(ibanAmountErrorsHorizontalStackView)

        usageStackView.addArrangedSubview(usageTextFieldView)
        usageStackView.addArrangedSubview(usageErrorLabel)

        buttonsStackView.addArrangedSubview(payInvoiceButton)
        buttonsView.addSubview(buttonsStackView)

        bottomStackView.addArrangedSubview(UIView())
        bottomStackView.addArrangedSubview(poweredByGiniView)
        bottomView.addSubview(bottomStackView)

        paymentInfoStackView.addArrangedSubview(recipientStackView)

        paymentInfoStackView.addArrangedSubview(ibanAmountContainerStackView)

        paymentInfoStackView.addArrangedSubview(usageStackView)
        paymentInfoStackView.addArrangedSubview(buttonsView)
        paymentInfoStackView.addArrangedSubview(bottomView)
        paymentInfoStackView.addArrangedSubview(UIView())

        self.addSubview(paymentInfoStackView)
    }

    // MARK: Layout & Constraints

    private func setupLayout() {
        setupContainerContraints()
        setupRecipientStackViewConstraints()
        setupIbanAmountStackViewsConstraints()
        setupUsageStackViewConstraints()
        setupButtonConstraints()
        setupPoweredByGiniConstraints()
    }

    private func setupContainerContraints() {
        NSLayoutConstraint.activate([
            paymentInfoStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.leftRightPaymentInfoContainerPadding),
            paymentInfoStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.leftRightPaymentInfoContainerPadding),
            paymentInfoStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: Constants.topBottomPaymentInfoContainerPadding),
            paymentInfoStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -Constants.topBottomPaymentInfoContainerPadding)
        ])
    }

    private func configureUI() {
        setupViewModel()
        configurePaymentInputFields()
        configurePayButtonInitialState()
        hideErrorLabels()
        fillInInputFields()
        addDoneButtonForNumPad(amountTextFieldView)
    }

    private func setupRecipientStackViewConstraints() {
        NSLayoutConstraint.activate([
            recipientTextFieldView.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
            recipientErrorLabel.heightAnchor.constraint(equalToConstant: Constants.errorLabelHeight),
        ])
    }

    private func setupIbanAmountStackViewsConstraints() {
        let amountTextFieldWidthConstraint = amountTextFieldView.widthAnchor.constraint(greaterThanOrEqualToConstant: Constants.amountWidth)
        amountTextFieldWidthConstraint.priority = .required - 1
        let amountErrorLabelWidthConstraint = amountErrorLabel.widthAnchor.constraint(equalToConstant: Constants.amountWidth)
        amountErrorLabelWidthConstraint.priority = .required - 1
        NSLayoutConstraint.activate([
            ibanTextFieldView.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
            amountTextFieldView.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
            amountTextFieldWidthConstraint,
            ibanErrorLabel.heightAnchor.constraint(equalToConstant: Constants.errorLabelHeight),
            amountErrorLabel.heightAnchor.constraint(equalToConstant: Constants.errorLabelHeight),
            amountErrorLabelWidthConstraint
        ])
    }

    private func setupUsageStackViewConstraints() {
        NSLayoutConstraint.activate([
            usageTextFieldView.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
            usageErrorLabel.heightAnchor.constraint(equalToConstant: Constants.errorLabelHeight)
        ])
    }

    private func setupButtonConstraints() {
        NSLayoutConstraint.activate([
            buttonsStackView.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor),
            buttonsStackView.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor),
            buttonsStackView.topAnchor.constraint(equalTo: buttonsView.topAnchor),
            buttonsStackView.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor),
            buttonsStackView.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight)
        ])
    }

    private func setupPoweredByGiniConstraints() {
        NSLayoutConstraint.activate([
            bottomStackView.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: Constants.leftRightPaymentInfoContainerPadding),
            bottomStackView.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -Constants.leftRightPaymentInfoContainerPadding),
            bottomStackView.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: Constants.topAnchorPoweredByGiniConstraint),
            bottomStackView.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor)
        ])
    }

    // MARK: - Input fields configuration

    fileprivate func setupViewModel() {
        model.onExtractionFetched = { [weak self] () in
            DispatchQueue.main.async {
                self?.fillInInputFields()
            }
        }
    }

    fileprivate func configurePaymentInputFields() {
        for field in paymentInputFields {
            applyDefaultStyle(field)
        }
    }

    fileprivate func applyDefaultStyle(_ textFieldView: TextFieldWithLabelView) {
        textFieldView.configure(configuration: Constants.defaultStyleInputFieldConfiguration)
        textFieldView.customConfigure(labelTitle: inputFieldPlaceholderText(textFieldView))
        textFieldView.textField.delegate = self
        textFieldView.textField.tag = textFieldView.tag
        textFieldView.layer.masksToBounds = true
    }

    fileprivate func applyErrorStyle(_ textFieldView: TextFieldWithLabelView) {
        UIView.animate(withDuration: Constants.animationDuration) {
            textFieldView.configure(configuration: Constants.errorStyleInputFieldConfiguration)
            textFieldView.layer.masksToBounds = true
        }
    }

    fileprivate func applySelectionStyle(_ textFieldView: TextFieldWithLabelView) {
        UIView.animate(withDuration: Constants.animationDuration) {
            textFieldView.configure(configuration: Constants.selectionStyleInputFieldConfiguration)
            textFieldView.layer.masksToBounds = true
        }
    }

    fileprivate func inputFieldPlaceholderText(_ textFieldView: TextFieldWithLabelView) -> String {
        if let fieldIdentifier = TextFieldType(rawValue: textFieldView.tag) {
            switch fieldIdentifier {
            case .recipientFieldTag:
                return Constants.recipientFieldPlaceholder
            case .ibanFieldTag:
                return Constants.ibanFieldPlaceholder
            case .amountFieldTag:
                return Constants.amountFieldPlaceholder
            case .usageFieldTag:
                return Constants.usageFieldPlaceholder
            }
        }
        return ""
    }

    fileprivate func validateTextField(_ textFieldViewTag: Int) {
        let textFieldView = textFieldViewWithTag(tag: textFieldViewTag)
        if let fieldIdentifier = TextFieldType(rawValue: textFieldViewTag) {
            switch fieldIdentifier {
            case .amountFieldTag:
                if amountTextFieldView.textField.hasText && !amountTextFieldView.textField.isReallyEmpty  {
                    let decimalPart = amountToPay.value
                    if decimalPart > 0 {
                        applyDefaultStyle(textFieldView)
                        hideErrorLabel(textFieldTag: fieldIdentifier)
                    } else {
                        amountTextFieldView.text = ""
                        applyErrorStyle(textFieldView)
                        showErrorLabel(textFieldTag: fieldIdentifier)
                    }
                } else {
                    applyErrorStyle(textFieldView)
                    showErrorLabel(textFieldTag: fieldIdentifier)
                }
            case .ibanFieldTag, .recipientFieldTag, .usageFieldTag:
                if textFieldView.textField.hasText && !textFieldView.textField.isReallyEmpty {
                    applyDefaultStyle(textFieldView)
                    hideErrorLabel(textFieldTag: fieldIdentifier)
                } else {
                    applyErrorStyle(textFieldView)
                    showErrorLabel(textFieldTag: fieldIdentifier)
                }
            }
        }
    }

    fileprivate func textFieldViewWithTag(tag: Int) -> TextFieldWithLabelView {
        paymentInputFields.first(where: { $0.tag == tag }) ?? TextFieldWithLabelView()
    }

    fileprivate func validateIBANTextField(){
        if let ibanText = ibanTextFieldView.textField.text, ibanTextFieldView.textField.hasText {
            if ibanValidator.isValid(iban: ibanText) {
                applyDefaultStyle(ibanTextFieldView)
                hideErrorLabel(textFieldTag: .ibanFieldTag)
            } else {
                applyErrorStyle(ibanTextFieldView)
                showValidationErrorLabel(textFieldTag: .ibanFieldTag)
            }
        } else {
            applyErrorStyle(ibanTextFieldView)
            showErrorLabel(textFieldTag: .ibanFieldTag)
        }
    }

    fileprivate func showIBANValidationErrorIfNeeded(){
        if ibanValidator.isValid(iban: lastValidatedIBAN) {
            applyDefaultStyle(ibanTextFieldView)
            hideErrorLabel(textFieldTag: .ibanFieldTag)
        } else {
            applyErrorStyle(ibanTextFieldView)
            showValidationErrorLabel(textFieldTag: .ibanFieldTag)
        }
    }

    fileprivate func validateAllInputFields() {
        for textField in paymentInputFields {
            validateTextField(textField.tag)
        }
    }

    fileprivate func hideErrorLabels() {
        for errorLabel in paymentInputFieldsErrorLabels {
            errorLabel.isHidden = true
        }
    }

    fileprivate func fillInInputFields() {
        recipientTextFieldView.text = model.extractions.first(where: {$0.name == "payment_recipient"})?.value
        ibanTextFieldView.text = model.extractions.first(where: {$0.name == "iban"})?.value
        usageTextFieldView.text = model.extractions.first(where: {$0.name == "payment_purpose"})?.value
        if let amountString = model.extractions.first(where: {$0.name == "amount_to_pay"})?.value, let amountToPay = Price(extractionString: amountString) {
            self.amountToPay = amountToPay
            let amountToPayText = amountToPay.string
            amountTextFieldView.text = amountToPayText
        }
        validateAllInputFields()
        disablePayButtonIfNeeded()
    }

    fileprivate func showErrorLabel(textFieldTag: TextFieldType) {
        var errorLabel = UILabel()
        var errorMessage = ""
        switch textFieldTag {
        case .recipientFieldTag:
            errorLabel = recipientErrorLabel
            errorMessage = Constants.recipientErrorMessage
        case .ibanFieldTag:
            errorLabel = ibanErrorLabel
            errorMessage = Constants.ibanErrorMessage
        case .amountFieldTag:
            errorLabel = amountErrorLabel
            errorMessage = Constants.amountErrorMessage
        case .usageFieldTag:
            errorLabel = usageErrorLabel
            errorMessage = Constants.purposeErrorMessage
        }
        if errorLabel.isHidden {
            errorLabel.isHidden = false
            errorLabel.text = errorMessage
        }
    }

    fileprivate func hideErrorLabel(textFieldTag: TextFieldType) {
        var errorLabel = UILabel()
        switch textFieldTag {
        case .recipientFieldTag:
            errorLabel = recipientErrorLabel
        case .ibanFieldTag:
            errorLabel = ibanErrorLabel
        case .amountFieldTag:
            errorLabel = amountErrorLabel
        case .usageFieldTag:
            errorLabel = usageErrorLabel
        }
        if !errorLabel.isHidden {
            errorLabel.isHidden = true
        }
        disablePayButtonIfNeeded()
    }

    // MARK: - Pay button

    fileprivate func disablePayButtonIfNeeded() {
        payInvoiceButton.superview?.alpha = paymentInputFields.allSatisfy({ !$0.textField.isReallyEmpty }) && amountToPay.value > 0 ? 1 : Constants.payInvoiceInactiveAlpha
    }

    fileprivate func showValidationErrorLabel(textFieldTag: TextFieldType) {
        var errorLabel = UILabel()
        var errorMessage = Constants.emptyCheckErrorMessage
        switch textFieldTag {
        case .recipientFieldTag:
            errorLabel = recipientErrorLabel
        case .ibanFieldTag:
            errorLabel = ibanErrorLabel
            errorMessage = Constants.ibanCheckErrorMessage
        case .amountFieldTag:
            errorLabel = amountErrorLabel
        case .usageFieldTag:
            errorLabel = usageErrorLabel
        }
        if errorLabel.isHidden {
            errorLabel.isHidden = false

            errorLabel.text = errorMessage
        }
    }

    fileprivate func configurePayButtonInitialState() {
        payInvoiceButton.configure(with: Constants.primaryButtonConfiguration)
        payInvoiceButton.customConfigure(paymentProviderColors: model.selectedPaymentProvider.colors,
                                         text: model.payInvoiceLabelText,
                                         leftImageData: model.selectedPaymentProvider.iconData)
        disablePayButtonIfNeeded()
        payInvoiceButton.didTapButton = { [weak self] in
            self?.payButtonClicked()
        }
    }

    fileprivate func addDoneButtonForNumPad(_ textFieldView: TextFieldWithLabelView) {
        let toolbarDone = UIToolbar(frame:CGRect(x: 0, y: 0, width: self.frame.width, height: Constants.heightToolbar))
        toolbarDone.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let barBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.done,
                                              target: self,
                                              action: #selector(doneWithAmountInputButtonTapped))

        toolbarDone.items = [flexBarButton, barBtnDone]
        textFieldView.textField.inputAccessoryView = toolbarDone
    }

    @objc fileprivate func doneWithAmountInputButtonTapped() {
        amountTextFieldView.textField.endEditing(true)
        amountTextFieldView.textField.resignFirstResponder()

        if amountTextFieldView.textField.hasText && !amountTextFieldView.textField.isReallyEmpty {
            updateAmoutToPayWithCurrencyFormat()
        }
    }

    // MARK: - Pay Button Action
    fileprivate func payButtonClicked() {
        self.endEditing(true)
        validateAllInputFields()
        validateIBANTextField()
        if let iban = ibanTextFieldView.text {
            lastValidatedIBAN = iban
        }

        if noErrorsFound() {
            onPayButtonClicked?()
        }
    }

    // MARK: - Helping functions

    func noErrorsFound() -> Bool {
        // check if no errors labels are shown
        if (paymentInputFieldsErrorLabels.allSatisfy { $0.isHidden }) {
            return true
        } else {
            return false
        }
    }

    func isTextFieldEmpty(texFieldType: TextFieldType) -> Bool {
        switch texFieldType {
        case .recipientFieldTag:
            return recipientTextFieldView.textField.isReallyEmpty
        case .ibanFieldTag:
            return ibanTextFieldView.textField.isReallyEmpty
        case .amountFieldTag:
            return amountTextFieldView.textField.isReallyEmpty
        case .usageFieldTag:
            return usageTextFieldView.textField.isReallyEmpty
        }
    }

    func obtainPaymentInfo() -> PaymentInfo {
        let amountText = amountToPay.extractionString
        let paymentInfo = PaymentInfo(recipient: recipientTextFieldView.text ?? "",
                                      iban: ibanTextFieldView.text ?? "",
                                      bic: "", amount: amountText,
                                      purpose: usageTextFieldView.text ?? "",
                                      paymentUniversalLink: model.selectedPaymentProvider.universalLinkIOS,
                                      paymentProviderId: model.selectedPaymentProvider.id)
        return paymentInfo
    }

    func textFieldText(texFieldType: TextFieldType) -> String? {
        switch texFieldType {
        case .recipientFieldTag:
            return recipientTextFieldView.textField.text
        case .ibanFieldTag:
            return ibanTextFieldView.textField.text
        case .amountFieldTag:
            return amountTextFieldView.textField.text
        case .usageFieldTag:
            return usageTextFieldView.textField.text
        }
    }

    private func buildErrorLabel() -> UILabel {
        let label = UILabel()
        label.font = Constants.errorLabelFont
        label.textColor = Constants.errorLabelTextColor
        return label
    }

    private func buildTextFieldWithLabelView(tag: Int, isEditable: Bool) -> TextFieldWithLabelView {
        let textFieldView = TextFieldWithLabelView()
        textFieldView.tag = tag
        textFieldView.isUserInteractionEnabled = isEditable
        return textFieldView
    }

}

// MARK: - UITextFieldDelegate

extension PaymentReviewContainerView: UITextFieldDelegate {
    /**
     Dissmiss the keyboard when return key pressed
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    /**
     Updates amoutToPay, formated string with a currency and removes "0.00" value
     */
    func updateAmoutToPayWithCurrencyFormat() {
        if amountTextFieldView.textField.hasText, let amountFieldText = amountTextFieldView.text {
            if let priceValue = decimal(from: amountFieldText ) {
                amountToPay.value = priceValue
                if priceValue > 0 {
                    let amountToPayText = amountToPay.string
                    amountTextFieldView.text = amountToPayText
                } else {
                    amountTextFieldView.text = ""
                }
            }
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        applySelectionStyle(textFieldViewWithTag(tag: textField.tag))

        // remove currency symbol and whitespaces for edit mode
        if let fieldIdentifier = TextFieldType(rawValue: textField.tag) {
            hideErrorLabel(textFieldTag: fieldIdentifier)

            if fieldIdentifier == .amountFieldTag {
                let amountToPayText = amountToPay.stringWithoutSymbol
                amountTextFieldView.text = amountToPayText
            }
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        // add currency format when edit is finished
        if TextFieldType(rawValue: textField.tag) == .amountFieldTag {
            updateAmoutToPayWithCurrencyFormat()
        }
        validateTextField(textField.tag)
        if TextFieldType(rawValue: textField.tag) == .ibanFieldTag {
            if textField.text == lastValidatedIBAN {
                showIBANValidationErrorIfNeeded()
            }
        }
        disablePayButtonIfNeeded()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if TextFieldType(rawValue: textField.tag) == .amountFieldTag,
           let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)

            // Limit length to 7 digits
            let onlyDigits = String(updatedText
                                        .trimmingCharacters(in: .whitespaces)
                                        .filter { c in c != "," && c != "."}
                                        .prefix(7))

            if let decimal = Decimal(string: onlyDigits) {
                let decimalWithFraction = decimal / 100

                if let newAmount = Price.stringWithoutSymbol(from: decimalWithFraction)?.trimmingCharacters(in: .whitespaces) {
                    // Save the selected text range to restore the cursor position after replacing the text
                    let selectedRange = textField.selectedTextRange

                    textField.text = newAmount
                    amountToPay.value = decimalWithFraction

                    // Move the cursor position after the inserted character
                    if let selectedRange = selectedRange {
                        let countDelta = newAmount.count - text.count
                        let offset = countDelta == 0 ? 1 : countDelta
                        textField.moveSelectedTextRange(from: selectedRange.start, to: offset)
                    }
                }
            }
            disablePayButtonIfNeeded()
            return false
           }
        return true
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        disablePayButtonIfNeeded()
    }
}

extension PaymentReviewContainerView {
    enum Constants {
        static let buttonViewHeight = 56.0
        static let leftRightPaymentInfoContainerPadding = 8.0
        static let topBottomPaymentInfoContainerPadding = 16.0
        static let textFieldHeight = 56.0
        static let errorLabelHeight = 12.0
        static let amountWidth = 95.0
        static let animationDuration: CGFloat = 0.3
        static let topAnchorPoweredByGiniConstraint = 5.0
        static let heightToolbar = 40.0
        static let stackViewSpacing = 10.0
        static let payInvoiceInactiveAlpha = 0.4

        static let errorLabelTextColor = GiniColor.feedback1.uiColor()

        static let emptyCheckErrorMessage = NSLocalizedStringPreferredFormat("gini.merchant.errors.failed.default.textfield.validation.check", comment: "the field failed non empty check")
        static let ibanCheckErrorMessage = NSLocalizedStringPreferredFormat("gini.merchant.errors.failed.iban.validation.check", comment: "iban failed validation check")
        static let recipientFieldPlaceholder = NSLocalizedStringPreferredFormat("gini.merchant.reviewscreen.recipient.placeholder", comment: "placeholder text for recipient input field")
        static let ibanFieldPlaceholder = NSLocalizedStringPreferredFormat("gini.merchant.reviewscreen.iban.placeholder", comment: "placeholder text for iban input field")
        static let amountFieldPlaceholder = NSLocalizedStringPreferredFormat("gini.merchant.reviewscreen.amount.placeholder", comment: "placeholder text for amount input field")
        static let usageFieldPlaceholder = NSLocalizedStringPreferredFormat("gini.merchant.reviewscreen.usage.placeholder", comment: "placeholder text for usage input field")
        static let recipientErrorMessage = NSLocalizedStringPreferredFormat("gini.merchant.errors.failed.recipient.non.empty.check", comment: "recipient failed non empty check")
        static let ibanErrorMessage = NSLocalizedStringPreferredFormat("gini.merchant.errors.failed.iban.non.empty.check", comment: "iban failed non empty check")
        static let amountErrorMessage = NSLocalizedStringPreferredFormat("gini.merchant.errors.failed.amount.non.empty.check", comment: "amount failed non empty check")
        static let purposeErrorMessage = NSLocalizedStringPreferredFormat("gini.merchant.errors.failed.purpose.non.empty.check", comment: "purpose failed non empty check")

        static let errorLabelFont = GiniMerchantConfiguration.shared.font(for: .captions2)

        static let primaryButtonConfiguration = GiniMerchantConfiguration.shared.primaryButtonConfiguration
        static let defaultStyleInputFieldConfiguration = GiniMerchantConfiguration.shared.defaultStyleInputFieldConfiguration
        static let errorStyleInputFieldConfiguration = GiniMerchantConfiguration.shared.errorStyleInputFieldConfiguration
        static let selectionStyleInputFieldConfiguration = GiniMerchantConfiguration.shared.selectionStyleInputFieldConfiguration
    }
}
