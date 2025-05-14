//
//  PaymentReviewContainerView.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniUtilites
import GiniHealthAPILibrary

/**
 An enumeration representing the types of text fields used in the payment review interface.
 Each case corresponds to a specific text field and is assigned a unique integer tag.
 */
public enum TextFieldType: Int {
    case recipientFieldTag = 1
    case ibanFieldTag
    case amountFieldTag
    case usageFieldTag
}

/// The container for oayment review textfields
public final class PaymentReviewContainerView: UIView {
    private let ibanValidator = IBANValidator()

    private lazy var recipientErrorLabel = buildErrorLabel()
    private lazy var usageErrorLabel = buildErrorLabel()
    private lazy var ibanErrorLabel = buildErrorLabel()
    private lazy var amountErrorLabel = buildErrorLabel()

    private let paymentInfoStackView = EmptyStackView().orientation(.vertical).distribution(.fill).spacing(Constants.stackViewSpacing)
    private let recipientStackView = EmptyStackView().orientation(.vertical).distribution(.fill)
    private let ibanAmountContainerStackView = EmptyStackView().orientation(.vertical).distribution(.fill)
    private let ibanAmountHorizontalStackView = EmptyStackView().orientation(.horizontal).distribution(.fill).spacing(Constants.stackViewSpacing)
    
    private let firstStackContainerView = EmptyStackView().orientation(.vertical).distribution(.fill)
    private let firstStackHorizontalStackView = EmptyStackView().orientation(.horizontal).distribution(.fillEqually).spacing(Constants.stackViewSpacing)
    private let firstErrorsHorizontalStackView = EmptyStackView().orientation(.horizontal).distribution(.fillEqually)
    
    private let secondStackContainerView = EmptyStackView().orientation(.vertical).distribution(.fill)
    private let secondStackHorizontalStackView = EmptyStackView().orientation(.horizontal).distribution(.fill).spacing(Constants.stackViewSpacing)
    private let secondErrorsHorizontalStackView = EmptyStackView().orientation(.horizontal).distribution(.fill)

    private let ibanAmountErrorsHorizontalStackView = EmptyStackView().orientation(.horizontal).distribution(.fill)
    private let recipientErrorStackView = EmptyStackView().orientation(.vertical).distribution(.fill)
    private let ibanErrorStackView = EmptyStackView().orientation(.vertical).distribution(.fill)
    private let amountErrorStackView = EmptyStackView().orientation(.vertical).distribution(.fill)
    private let usageStackView = EmptyStackView().orientation(.vertical).distribution(.fill)
    private let usageErrorStackView = EmptyStackView().orientation(.vertical).distribution(.fill)

    private lazy var recipientTextFieldView = buildTextFieldWithLabelView(tag: TextFieldType.recipientFieldTag.rawValue, isEditable: !viewModel.configuration.lockedFields)
    private lazy var ibanTextFieldView = buildTextFieldWithLabelView(tag: TextFieldType.ibanFieldTag.rawValue, isEditable: !viewModel.configuration.lockedFields)
    private lazy var amountTextFieldView = buildTextFieldWithLabelView(tag: TextFieldType.amountFieldTag.rawValue, isEditable: true, keyboardType: .numberPad)
    private lazy var usageTextFieldView = buildTextFieldWithLabelView(tag: TextFieldType.usageFieldTag.rawValue, isEditable: !viewModel.configuration.lockedFields)

    private let buttonsView = EmptyView()

    private lazy var selectBankButton: PaymentSecondaryButton = {
        let button = PaymentSecondaryButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configure(with: viewModel.secondaryButtonConfiguration)
        button.frame = CGRect(x: 0, y: 0, width: .greatestFiniteMagnitude, height: Constants.buttonViewHeight)
        return button
    }()

    private lazy var payInvoiceButton: PaymentPrimaryButton = {
        let button = PaymentPrimaryButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.frame = CGRect(x: 0, y: 0, width: .greatestFiniteMagnitude, height: Constants.buttonViewHeight)
        return button
    }()

    private let bottomView = EmptyView()
    private let buttonsStackView = EmptyStackView().orientation(.horizontal).spacing(Constants.buttonsSpacing)
    private let bottomStackView = EmptyStackView().orientation(.horizontal)

    private lazy var poweredByGiniView: PoweredByGiniView = {
        let view = PoweredByGiniView(viewModel: viewModel.poweredByGiniViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var amountToPay = Price(value: 0, currencyCode: "€")
    private var lastValidatedIBAN = ""

    private var paymentInputFields: [TextFieldWithLabelView] = []
    private var paymentInputFieldsErrorLabels: [UILabel] = []
    private var coupledErrorLabels: [UILabel] = []
    private var firstCoupledErrorsLabels: [UILabel] = []
    private var secondCoupleErrorsLabels: [UILabel] = []
    private let viewModel: PaymentReviewContainerViewModel
    /// A closure that is called when the pay button is clicked.
    public var onPayButtonClicked: (() -> Void)?
    /// A closure that is called when the banks selection button is clicked.
    public var onBankSelectionButtonClicked: (() -> Void)?

    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []

    public init(viewModel: PaymentReviewContainerViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
    }
    
    public func setupView(shouldUpdateUI: Bool = true) {
        let isPortrait = UIDevice.isPortrait()
        setupViewHierarchy(isPortrait: isPortrait)
        setupLayout(isPortrait: isPortrait)
        if shouldUpdateUI {
            configureUI()
        }
    }
    
    func updateViews(for paymentInfoState: PaymentInfoState) {
        switch paymentInfoState {
        case .expanded:
            toggleExpandedViews(isHidden: false)
        case .collapsed:
            toggleExpandedViews(isHidden: true)
            resignAllInputFields()
        }
    }

    private func toggleExpandedViews(isHidden: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.firstStackContainerView.isHidden = isHidden
            self.secondStackContainerView.isHidden = isHidden
        }
    }
    
    private func resignAllInputFields() {
        paymentInputFields.forEach( { _ = $0.resignFirstResponder() })
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViewHierarchy(isPortrait: Bool) {
        subviews.forEach { $0.removeFromSuperview() }

        paymentInputFields = [recipientTextFieldView, amountTextFieldView, ibanTextFieldView, usageTextFieldView]
        paymentInputFieldsErrorLabels = [recipientErrorLabel, amountErrorLabel, ibanErrorLabel, usageErrorLabel]
        if isPortrait {
            coupledErrorLabels = [amountErrorLabel, ibanErrorLabel]

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
        } else {
            firstCoupledErrorsLabels = [recipientErrorLabel, ibanErrorLabel]
            secondCoupleErrorsLabels = [amountErrorLabel, usageErrorLabel]

            firstStackHorizontalStackView.addArrangedSubview(recipientTextFieldView)
            firstStackHorizontalStackView.addArrangedSubview(ibanTextFieldView)

            recipientErrorStackView.addArrangedSubview(recipientErrorLabel)
            ibanErrorStackView.addArrangedSubview(ibanErrorLabel)
            firstErrorsHorizontalStackView.addArrangedSubview(recipientErrorStackView)
            firstErrorsHorizontalStackView.addArrangedSubview(ibanErrorStackView)

            secondStackHorizontalStackView.addArrangedSubview(amountTextFieldView)
            secondStackHorizontalStackView.addArrangedSubview(usageTextFieldView)

            amountErrorStackView.addArrangedSubview(amountErrorLabel)
            usageErrorStackView.addArrangedSubview(usageErrorLabel)
            secondErrorsHorizontalStackView.addArrangedSubview(amountErrorStackView)
            secondErrorsHorizontalStackView.addArrangedSubview(usageErrorStackView)

            firstStackContainerView.addArrangedSubview(firstStackHorizontalStackView)
            firstStackContainerView.addArrangedSubview(firstErrorsHorizontalStackView)

            secondStackContainerView.addArrangedSubview(secondStackHorizontalStackView)
            secondStackContainerView.addArrangedSubview(secondErrorsHorizontalStackView)
        }

        if viewModel.configuration.showBanksPicker {
            buttonsStackView.addArrangedSubview(selectBankButton)
        }
        
        buttonsStackView.addArrangedSubview(payInvoiceButton)
        buttonsView.addSubview(buttonsStackView)

        bottomStackView.addArrangedSubview(UIView())
        if viewModel.shouldShowBrandedView {
            bottomStackView.addArrangedSubview(poweredByGiniView)
        }
        bottomView.addSubview(bottomStackView)
        
        paymentInfoStackView.removeAllArrangedSubviews()
        if isPortrait {
            paymentInfoStackView.addArrangedSubview(recipientStackView)
            paymentInfoStackView.addArrangedSubview(ibanAmountContainerStackView)
            paymentInfoStackView.addArrangedSubview(usageStackView)
        } else {
            paymentInfoStackView.addArrangedSubview(firstStackContainerView)
            paymentInfoStackView.addArrangedSubview(secondStackContainerView)
        }
        paymentInfoStackView.addArrangedSubview(buttonsView)
        
        if viewModel.shouldShowBrandedView {
            addBrandedViewToViewHierarchy()
        }
        
        paymentInfoStackView.addArrangedSubview(UIView())

        self.addSubview(paymentInfoStackView)
    }
    
    private func addBrandedViewToViewHierarchy() {
        bottomStackView.addArrangedSubview(UIView())
        bottomStackView.addArrangedSubview(poweredByGiniView)
        bottomView.addSubview(bottomStackView)
        paymentInfoStackView.addArrangedSubview(bottomView)
    }

    // MARK: Layout & Constraints

    private func setupLayout(isPortrait: Bool) {
        setupContainerContraints()
        if isPortrait {
            setupRecipientStackViewConstraints()
            setupIbanAmountStackViewsConstraints()
            setupUsageStackViewConstraints()
        } else {
            setupFirstStackViewsConstraints()
            setupSecondStackViewsConstraints()
        }
        setupButtonConstraints()
        setupPoweredByGiniConstraints()
        updateLayoutForCurrentOrientation(isPortrait: isPortrait)
    }

    private func setupContainerContraints() {
        NSLayoutConstraint.activate([
            paymentInfoStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: viewModel.dispayMode == .bottomSheet ? 0 : Constants.topBottomPaymentInfoContainerPadding),
            paymentInfoStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: viewModel.dispayMode == .bottomSheet ? 0 : -Constants.topBottomPaymentInfoContainerPadding)
        ])
    }

    private func configureUI() {
        setupViewModel()
        configurePaymentInputFields()
        configurePayButtonInitialState()
        configureSelectBanksButton()
        hideErrorLabels()
        fillInInputFields()
        addDoneButtonForNumPad(amountTextFieldView)
    }

    private func updateLayoutForCurrentOrientation(isPortrait: Bool) {
        if isPortrait {
            setupPortraitConstraints()
        } else {
            setupLandscapeConstraints()
        }
    }

    private func setupPortraitConstraints() {
        setupConstraints(for: .vertical)
    }

    private func setupLandscapeConstraints() {
        setupConstraints(for: .horizontal)
    }

    private func setupConstraints(for orientation: NSLayoutConstraint.Axis) {
        NSLayoutConstraint.deactivate(landscapeConstraints + portraitConstraints)

        let isPortrait = orientation == .vertical
        let constraints = [
            paymentInfoStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: isPortrait ? Constants.leftRightPaymentInfoContainerPortraitPadding : Constants.leftRightPaymentInfoContainerLandscapePadding),
            paymentInfoStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: isPortrait ? -Constants.leftRightPaymentInfoContainerPortraitPadding : -Constants.leftRightPaymentInfoContainerLandscapePadding),
            bottomStackView.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: Constants.leftRightPaymentInfoContainerPortraitPadding),
            bottomStackView.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -Constants.leftRightPaymentInfoContainerPortraitPadding),
        ]

        if isPortrait {
            portraitConstraints = constraints
            NSLayoutConstraint.activate(portraitConstraints)
        } else {
            landscapeConstraints = constraints
            NSLayoutConstraint.activate(landscapeConstraints)
        }
    }


    private func setupRecipientStackViewConstraints() {
        NSLayoutConstraint.activate([
            recipientTextFieldView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.textFieldHeight),
            recipientErrorLabel.heightAnchor.constraint(equalToConstant: Constants.errorLabelHeight),
        ])
    }

    private func setupIbanAmountStackViewsConstraints() {
        let amountTextFieldWidthConstraint = amountTextFieldView.widthAnchor.constraint(greaterThanOrEqualToConstant: Constants.amountPortraitWidth)
        amountTextFieldWidthConstraint.priority = .required - 1
        let amountErrorLabelWidthConstraint = amountErrorLabel.widthAnchor.constraint(equalToConstant: Constants.amountPortraitWidth)
        amountErrorLabelWidthConstraint.priority = .required - 1
        NSLayoutConstraint.activate([
            ibanTextFieldView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.textFieldHeight),
            amountTextFieldView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.textFieldHeight),
            amountTextFieldWidthConstraint,
            ibanErrorLabel.heightAnchor.constraint(equalToConstant: Constants.errorLabelHeight),
            amountErrorLabel.heightAnchor.constraint(equalToConstant: Constants.errorLabelHeight),
            amountErrorLabelWidthConstraint
        ])
    }

    private func setupUsageStackViewConstraints() {
        NSLayoutConstraint.activate([
            usageTextFieldView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.textFieldHeight),
            usageErrorLabel.heightAnchor.constraint(equalToConstant: Constants.errorLabelHeight)
        ])
    }
    
    private func setupFirstStackViewsConstraints() {
        NSLayoutConstraint.activate([
            ibanTextFieldView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.textFieldHeight),
            amountTextFieldView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.textFieldHeight),
            ibanErrorLabel.heightAnchor.constraint(equalToConstant: Constants.errorLabelHeight),
            amountErrorLabel.heightAnchor.constraint(equalToConstant: Constants.errorLabelHeight),
        ])
    }
    
    private func setupSecondStackViewsConstraints() {
        NSLayoutConstraint.activate([
            amountTextFieldView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.textFieldHeight),
            usageTextFieldView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.textFieldHeight),
            amountTextFieldView.widthAnchor.constraint(greaterThanOrEqualToConstant: Constants.amountLandscapeWidth),
            usageErrorLabel.heightAnchor.constraint(equalToConstant: Constants.errorLabelHeight),
            amountErrorLabel.heightAnchor.constraint(equalToConstant: Constants.errorLabelHeight),
            amountErrorLabel.widthAnchor.constraint(equalToConstant: Constants.amountLandscapeWidth)
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
            bottomStackView.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: Constants.topAnchorPoweredByGiniConstraint),
            bottomStackView.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor),
            bottomStackView.heightAnchor.constraint(equalToConstant: Constants.bottomViewHeight)
        ])
    }

    // MARK: - Input fields configuration

    fileprivate func setupViewModel() {
        viewModel.onExtractionFetched = { [weak self] () in
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
        textFieldView.configure(configuration: viewModel.defaultStyleInputFieldConfiguration)
        textFieldView.customConfigure(labelTitle: inputFieldPlaceholderText(textFieldView))
        textFieldView.delegate = self
        textFieldView.layer.masksToBounds = true
    }

    fileprivate func applyErrorStyle(_ textFieldView: TextFieldWithLabelView) {
        UIView.animate(withDuration: Constants.animationDuration) {
            textFieldView.configure(configuration: self.viewModel.errorStyleInputFieldConfiguration)
            textFieldView.layer.masksToBounds = true
        }
    }

    fileprivate func applySelectionStyle(_ textFieldView: TextFieldWithLabelView) {
        UIView.animate(withDuration: Constants.animationDuration) {
            textFieldView.configure(configuration: self.viewModel.selectionStyleInputFieldConfiguration)
            textFieldView.layer.masksToBounds = true
        }
    }

    fileprivate func inputFieldPlaceholderText(_ textFieldView: TextFieldWithLabelView) -> NSAttributedString {
        let fullString = NSMutableAttributedString()
        if let fieldIdentifier = TextFieldType(rawValue: textFieldView.tag) {
            var text = ""
            switch fieldIdentifier {
            case .recipientFieldTag:
                text = viewModel.strings.recipientFieldPlaceholder
            case .ibanFieldTag:
                text = viewModel.strings.ibanFieldPlaceholder
            case .amountFieldTag:
                text = viewModel.strings.amountFieldPlaceholder
            case .usageFieldTag:
                text = viewModel.strings.usageFieldPlaceholder
            }
            fullString.append(NSAttributedString(string: text))

            if viewModel.configuration.lockedFields, fieldIdentifier != .amountFieldTag {
                appendLockIcon(fullString)
            }
        }
        return fullString
    }

    fileprivate func appendLockIcon(_ string: NSMutableAttributedString) {
        let lockIconAttachment = NSTextAttachment()
        let icon = viewModel.configuration.lockIcon
        lockIconAttachment.image = icon

        let height = Constants.lockIconHeight
        let ratio = icon.size.width / icon.size.height
        lockIconAttachment.bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: ratio * height, height: height)

        let lockString = NSAttributedString(attachment: lockIconAttachment)

        string.append(NSAttributedString(string: "  "))
        string.append(lockString)
    }

    fileprivate func validateTextField(_ textFieldViewTag: Int) {
        let textFieldView = textFieldViewWithTag(tag: textFieldViewTag)
        if let fieldIdentifier = TextFieldType(rawValue: textFieldViewTag) {
            switch fieldIdentifier {
            case .amountFieldTag:
                validateAmountTextField()
            case .ibanFieldTag, .recipientFieldTag, .usageFieldTag:
                if textFieldView.hasText && !textFieldView.isReallyEmpty {
                    applyDefaultStyle(textFieldView)
                    hideErrorLabel(textFieldTag: fieldIdentifier)
                } else {
                    applyErrorStyle(textFieldView)
                    showErrorLabel(textFieldTag: fieldIdentifier)
                }
            }
        }
    }

    fileprivate func validateAmountTextField() {
        if amountTextFieldView.hasText && !amountTextFieldView.isReallyEmpty {
            let decimalPart = amountToPay.value
            if decimalPart > 0 {
                applyDefaultStyle(amountTextFieldView)
                hideErrorLabel(textFieldTag: .amountFieldTag)
            } else {
                amountTextFieldView.text = ""
                applyErrorStyle(amountTextFieldView)
                showErrorLabel(textFieldTag: .amountFieldTag)
            }
        } else {
            applyErrorStyle(amountTextFieldView)
            showErrorLabel(textFieldTag: .amountFieldTag)
        }
    }

    fileprivate func textFieldViewWithTag(tag: Int) -> TextFieldWithLabelView {
        paymentInputFields.first(where: { $0.tag == tag }) ?? TextFieldWithLabelView()
    }

    fileprivate func validateIBANTextField(){
        if let ibanText = ibanTextFieldView.text {
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
        updateAmountIbanErrorState()
    }

    fileprivate func fillInInputFields() {
        if let extractions = viewModel.extractions {
            recipientTextFieldView.text = extractions.first(where: {$0.name == "payment_recipient"})?.value
            ibanTextFieldView.text = extractions.first(where: {$0.name == "iban"})?.value.uppercased()
            usageTextFieldView.text = extractions.first(where: {$0.name == "payment_purpose"})?.value
            if let amountString = extractions.first(where: {$0.name == "amount_to_pay"})?.value, let amountToPay = Price(extractionString: amountString) {
                self.amountToPay = amountToPay
                let amountToPayText = amountToPay.string
                amountTextFieldView.text = amountToPayText
            }
        } else if let paymentInfo = viewModel.paymentInfo {
            recipientTextFieldView.text = paymentInfo.recipient
            ibanTextFieldView.text = paymentInfo.iban
            usageTextFieldView.text = paymentInfo.purpose
            if let amountToPay = Price(extractionString: paymentInfo.amount) {
                self.amountToPay = amountToPay
                let amountToPayText = amountToPay.string
                amountTextFieldView.text = amountToPayText
            }
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
            errorMessage = viewModel.strings.recipientErrorMessage
        case .ibanFieldTag:
            errorLabel = ibanErrorLabel
            errorMessage = viewModel.strings.ibanErrorMessage
        case .amountFieldTag:
            errorLabel = amountErrorLabel
            errorMessage = viewModel.strings.amountErrorMessage
        case .usageFieldTag:
            errorLabel = usageErrorLabel
            errorMessage = viewModel.strings.purposeErrorMessage
        }
        if errorLabel.isHidden {
            errorLabel.isHidden = false
            errorLabel.text = errorMessage
        }
        updateAmountIbanErrorState()
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
        updateAmountIbanErrorState()
    }

    // MARK: - Pay button

    fileprivate func disablePayButtonIfNeeded() {
        payInvoiceButton.alpha = paymentInputFields.allSatisfy({ !$0.isReallyEmpty }) && amountToPay.value > 0 ? 1 : Constants.payInvoiceInactiveAlpha
    }

    fileprivate func showValidationErrorLabel(textFieldTag: TextFieldType) {
        var errorLabel = UILabel()
        var errorMessage = viewModel.strings.emptyCheckErrorMessage
        switch textFieldTag {
        case .recipientFieldTag:
            errorLabel = recipientErrorLabel
        case .ibanFieldTag:
            errorLabel = ibanErrorLabel
            errorMessage = viewModel.strings.ibanCheckErrorMessage
        case .amountFieldTag:
            errorLabel = amountErrorLabel
        case .usageFieldTag:
            errorLabel = usageErrorLabel
        }
        if errorLabel.isHidden {
            errorLabel.isHidden = false

            errorLabel.text = errorMessage
        }
        updateAmountIbanErrorState()
    }

    fileprivate func configureSelectBanksButton() {
        selectBankButton.customConfigure(labelText: "",
                                         leftImageIcon: viewModel.bankImageIcon,
                                         rightImageIcon: viewModel.configuration.chevronDownIcon,
                                         rightImageTintColor: viewModel.configuration.chevronDownIconColor,
                                         shouldShowLabel: false)
        selectBankButton.didTapButton = { [weak self] in
            self?.tapOnBankPicker()
        }
        selectBankButton.accessibilityLabel = viewModel.strings.selectBankAccessibilityText
        selectBankButton.isAccessibilityElement = true
        selectBankButton.accessibilityTraits = .button
    }

    @objc
    private func tapOnBankPicker() {
        onBankSelectionButtonClicked?()
    }

    fileprivate func configurePayButtonInitialState() {
        payInvoiceButton.configure(with: viewModel.primaryButtonConfiguration)
        payInvoiceButton.customConfigure(text: viewModel.strings.payInvoiceLabelText,
                                         textColor: viewModel.selectedPaymentProvider.colors.text.toColor(),
                                         backgroundColor: viewModel.selectedPaymentProvider.colors.background.toColor(),
                                         leftImageData: viewModel.configuration.showBanksPicker ? nil : viewModel.selectedPaymentProvider.iconData)
        disablePayButtonIfNeeded()
        payInvoiceButton.didTapButton = { [weak self] in
            self?.payButtonClicked()
        }
        payInvoiceButton.accessibilityLabel = viewModel.strings.payInvoiceLabelText
        payInvoiceButton.isAccessibilityElement = true
        payInvoiceButton.accessibilityTraits = .button
    }

    fileprivate func addDoneButtonForNumPad(_ textFieldView: TextFieldWithLabelView) {
        let toolbarDone = UIToolbar(frame:CGRect(x: 0, y: 0, width: self.frame.width, height: Constants.heightToolbar))
        toolbarDone.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let barBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.done,
                                              target: self,
                                              action: #selector(doneWithAmountInputButtonTapped))

        toolbarDone.items = [flexBarButton, barBtnDone]
        textFieldView.setInputAccesoryView(view: toolbarDone)
    }

    @objc fileprivate func doneWithAmountInputButtonTapped() {
        _ = amountTextFieldView.endEditing(true)
        _ = amountTextFieldView.resignFirstResponder()

        if amountTextFieldView.hasText && !amountTextFieldView.isReallyEmpty {
            updateAmoutToPayWithCurrencyFormat()
        }
    }

    private func updateAmountIbanErrorState() {
        ibanAmountErrorsHorizontalStackView.isHidden = coupledErrorLabels.allSatisfy { $0.isHidden }
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

    func textFieldText(textFieldType: TextFieldType) -> String? {
        switch textFieldType {
        case .recipientFieldTag:
            return recipientTextFieldView.text
        case .ibanFieldTag:
            return ibanTextFieldView.text
        case .amountFieldTag:
            return amountTextFieldView.text
        case .usageFieldTag:
            return usageTextFieldView.text
        }
    }

    func textFieldEdited() -> UITextField? {
        paymentInfoStackView.findFirstResponder()
    }
    
    private func buildErrorLabel() -> UILabel {
        let label = UILabel()
        label.font = viewModel.configuration.errorLabelFont
        label.enableScaling()
        label.textColor = viewModel.configuration.errorLabelTextColor
        label.numberOfLines = 0
        return label
    }

    private func buildTextFieldWithLabelView(tag: Int, isEditable: Bool, keyboardType: UIKeyboardType = .default) -> TextFieldWithLabelView {
        let textFieldView = TextFieldWithLabelView()
        textFieldView.tag = tag
        textFieldView.isUserInteractionEnabled = isEditable
        textFieldView.setKeyboardType(keyboardType: keyboardType)
        return textFieldView
    }
}

extension UIView {
    func findFirstResponder() -> UITextField? {
        if self is UITextField, self.isFirstResponder {
            return self as? UITextField
        }
        for subview in subviews {
            if let responder = subview.findFirstResponder() {
                return responder
            }
        }
        return nil
    }
}

// MARK: - Public

public extension PaymentReviewContainerView {
    func noErrorsFound() -> Bool {
        // check if no errors labels are shown
        if (paymentInputFieldsErrorLabels.allSatisfy { $0.isHidden }) {
            return true
        } else {
            return false
        }
    }

    func inputFieldsHaveNoErrors() -> Bool {
        paymentInputFieldsErrorLabels.allSatisfy { $0.isHidden }
    }

    func obtainPaymentInfo() -> PaymentInfo {
        let amountText = amountToPay.extractionString
        let paymentInfo = PaymentInfo(recipient: recipientTextFieldView.text ?? "",
                                      iban: ibanTextFieldView.text ?? "",
                                      bic: "", 
                                      amount: amountText,
                                      purpose: usageTextFieldView.text ?? "",
                                      paymentUniversalLink: viewModel.selectedPaymentProvider.universalLinkIOS,
                                      paymentProviderId: viewModel.selectedPaymentProvider.id)
        return paymentInfo
    }

    func isTextFieldEmpty(textFieldType: TextFieldType) -> Bool {
        switch textFieldType {
        case .recipientFieldTag:
            return recipientTextFieldView.isReallyEmpty
        case .ibanFieldTag:
            return ibanTextFieldView.isReallyEmpty
        case .amountFieldTag:
            return amountTextFieldView.isReallyEmpty
        case .usageFieldTag:
            return usageTextFieldView.isReallyEmpty
        }
    }

    func updateSelectedPaymentProvider(_ paymentProvider: PaymentProvider) {
        viewModel.selectedPaymentProvider = paymentProvider
        viewModel.bankImageIcon = paymentProvider.iconData.toImage
        configureSelectBanksButton()
        configurePayButtonInitialState()
    }
}

// MARK: - UITextFieldDelegate

extension PaymentReviewContainerView: UITextFieldDelegate {
    /**
     Dissmiss the keyboard when return key pressed
     */
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    /**
     Updates amoutToPay, formated string with a currency and removes "0.00" value
     */
    public func updateAmoutToPayWithCurrencyFormat() {
        if amountTextFieldView.hasText, let amountFieldText = amountTextFieldView.text {
            if let priceValue = amountFieldText.decimal() {
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

    public func textFieldDidBeginEditing(_ textField: UITextField) {
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

    public func textFieldDidEndEditing(_ textField: UITextField) {
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

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch TextFieldType(rawValue: textField.tag) {
        case .amountFieldTag:
            guard let text = textField.text,
                  let textRange = Range(range, in: text) else {
                return true
            }
            
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            adjustAmountValue(textField: textField, updatedText: updatedText)
            disablePayButtonIfNeeded()
            return false
        case .ibanFieldTag:
            handleIBANUppercase(textField: textField, range: range, replacementString: string)
            return false
        default:
            return true
        }
    }

    private func adjustAmountValue(textField: UITextField, updatedText: String) {
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
                    let countDelta = newAmount.count - (textField.text?.count ?? 0)
                    let offset = countDelta == 0 ? 1 : countDelta
                    textField.moveSelectedTextRange(from: selectedRange.start, to: offset)
                }
            }
        }
    }
    
    private func handleIBANUppercase(textField: UITextField, range: NSRange, replacementString string: String) {
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string).uppercased()
            textField.text = updatedText
        } else {
            textField.text = string.uppercased()
        }
    }

    public func textFieldDidChangeSelection(_ textField: UITextField) {
        disablePayButtonIfNeeded()
    }
}

extension PaymentReviewContainerView {
    enum Constants {
        static let buttonViewHeight = 56.0
        static let leftRightPaymentInfoContainerPortraitPadding = 8.0
        static let leftRightPaymentInfoContainerLandscapePadding = 56.0
        static let topBottomPaymentInfoContainerPadding = 16.0
        static let textFieldHeight = 56.0
        static let errorLabelHeight = 12.0
        static let amountPortraitWidth = 95.0
        static let amountLandscapeWidth = 120.0
        static let animationDuration: CGFloat = 0.3
        static let topAnchorPoweredByGiniConstraint = 5.0
        static let heightToolbar = 40.0
        static let stackViewSpacing = 10.0
        static let payInvoiceInactiveAlpha = 0.4
        static let bottomViewHeight = 20.0
        static let errorTopMargin = 9.0
        static let lockIconHeight = 11.0
        static let buttonsSpacing = 8.0
    }
}
