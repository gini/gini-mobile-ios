//
//  PaymentComponentView.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniUtilites

public final class PaymentComponentView: UIView {
    let viewModel: PaymentComponentViewModel

    private let contentStackView = EmptyStackView().orientation(.vertical)
    private let selectYourBankView = EmptyView()
    
    private lazy var selectYourBankLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = viewModel.strings.selectYourBankLabelText
        label.textColor = viewModel.configuration.selectYourBankAccentColor
        label.font = viewModel.configuration.selectYourBankLabelFont
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        return label
    }()
    
    private let buttonsView = EmptyView()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = EmptyStackView().orientation(viewModel.showPaymentComponentInOneRow ? .horizontal : .vertical)
        stackView.spacing = Constants.buttonsSpacing
        return stackView
    }()
    
    private lazy var selectBankButton: PaymentSecondaryButton = {
        let button = PaymentSecondaryButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configure(with: viewModel.secondaryButtonConfiguration)
        return button
    }()
    
    private lazy var payInvoiceButton: PaymentPrimaryButton = {
        let button = PaymentPrimaryButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configure(with: viewModel.primaryButtonConfiguration)
        button.customConfigure(text: viewModel.strings.ctaLabelText,
                               textColor: viewModel.paymentProviderColors?.text.toColor(),
                               backgroundColor: viewModel.paymentProviderColors?.background.toColor())
        button.accessibilityLabel = viewModel.strings.ctaLabelText
        return button
    }()
    
    private let bottomView = EmptyView()
    
    private let bottomStackView: EmptyStackView = {
        EmptyStackView()
            .orientation(.horizontal)
            .spacing(Constants.bottomStackViewSpacing)
    }()
    
    private lazy var moreInformationView: MoreInformationView = {
        let viewModel = viewModel.moreInformationViewModel
        viewModel.delegate = self
        return MoreInformationView(viewModel: viewModel)
    }()

    private lazy var poweredByGiniView: PoweredByGiniView = {
        PoweredByGiniView(viewModel: viewModel.poweredByGiniViewModel)
    }()

    public init(viewModel: PaymentComponentViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear

        selectYourBankView.addSubview(selectYourBankLabel)
        contentStackView.addArrangedSubview(selectYourBankView)
        
        buttonsStackView.addArrangedSubview(selectBankButton)
        buttonsStackView.addArrangedSubview(payInvoiceButton)
        buttonsView.addSubview(buttonsStackView)
        contentStackView.addArrangedSubview(buttonsView)
        
        bottomStackView.addArrangedSubview(moreInformationView)
        
        if viewModel.shouldShowBrandedView {
            bottomStackView.addArrangedSubview(poweredByGiniView)
        }
        
        bottomView.addSubview(bottomStackView)
        contentStackView.addArrangedSubview(bottomView)
        
        self.addSubview(contentStackView)
        activateAllConstraints()
        updateAvailableViews()
        updateButtonsViews()
        setupGestures()
    }

    private func activateAllConstraints() {
        activateContentStackViewConstraints()
        activateSelectYourBankButtonConstraints()
        activateButtonsConstraints()
        activateBottomViewConstraints()
    }
    
    private func setupGestures() {
        payInvoiceButton.didTapButton = { [weak self] in
            self?.tapOnPayInvoiceView()
        }
        selectBankButton.didTapButton = { [weak self] in
            self?.tapOnBankPicker()
        }
    }
    
    private func updateAvailableViews() {
        guard viewModel.hideInfoForReturningUser else { return }
        let isPaymentComponentUsed = viewModel.isPaymentComponentUsed()
        selectYourBankView.isHidden = isPaymentComponentUsed
        moreInformationView.isHidden = isPaymentComponentUsed
        if moreInformationView.isHidden && !bottomStackView.contains(poweredByGiniView) {
            bottomView.isHidden = true
        }
    }
    
    private func updateButtonsViews() {
        selectBankButton.customConfigure(labelText: viewModel.selectBankButtonText,
                                         leftImageIcon: viewModel.bankImageIcon,
                                         rightImageIcon: viewModel.configuration.chevronDownIcon,
                                         rightImageTintColor: viewModel.configuration.chevronDownIconColor,
                                         shouldShowLabel: viewModel.showPaymentComponentInOneRow ? !viewModel.hasBankSelected : true)
        payInvoiceButton.isHidden = !viewModel.hasBankSelected
        selectBankButton.accessibilityLabel = viewModel.selectBankButtonText
        selectBankButton.heightAnchor.constraint(greaterThanOrEqualToConstant: heightConstantSelectBankButton).isActive = true
    }

    var heightConstantSelectBankButton: Double {
        viewModel.showPaymentComponentInOneRow ? viewModel.minimumButtonsHeight : (viewModel.hasBankSelected ? viewModel.minimumButtonsHeight : Constants.defaultButtonHeihgt)
    }

    private func activateContentStackViewConstraints() {
        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.contentTopPadding),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.contentBottomPadding)
        ])
    }

    private func activateSelectYourBankButtonConstraints() {
        NSLayoutConstraint.activate([
            selectYourBankLabel.leadingAnchor.constraint(equalTo: selectYourBankView.leadingAnchor),
            selectYourBankLabel.trailingAnchor.constraint(equalTo: selectYourBankView.trailingAnchor),
            selectYourBankLabel.topAnchor.constraint(equalTo: selectYourBankView.topAnchor),
            selectYourBankLabel.bottomAnchor.constraint(equalTo: selectYourBankView.bottomAnchor, constant: -Constants.selectYourBankLabelBottomPadding),
        ])
    }
    
    private func activateButtonsConstraints() {
        NSLayoutConstraint.activate([
            buttonsStackView.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor),
            buttonsStackView.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor),
            buttonsStackView.topAnchor.constraint(equalTo: buttonsView.topAnchor, constant: Constants.buttonsTopBottomSpacing),
            buttonsStackView.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: -Constants.buttonsTopBottomSpacing),
            payInvoiceButton.heightAnchor.constraint(equalToConstant: viewModel.minimumButtonsHeight)
        ])
    }
    
    private func activateBottomViewConstraints() {
        NSLayoutConstraint.activate([
            bottomStackView.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor),
            bottomStackView.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor),
            bottomStackView.topAnchor.constraint(equalTo: bottomView.topAnchor),
            bottomStackView.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor),
        ])
    }

    @objc
    private func tapOnBankPicker() {
        viewModel.tapOnBankPicker()
    }
    
    @objc
    private func tapOnPayInvoiceView() {
        viewModel.tapOnPayInvoiceView()
    }
}

extension PaymentComponentView: MoreInformationViewProtocol {
    public func didTapOnMoreInformation() {
        viewModel.tapOnMoreInformation()
    }
}

extension PaymentComponentView {
    private enum Constants {
        static let contentTopPadding = 16.0
        static let contentBottomPadding: CGFloat = 4
        static let selectYourBankLabelBottomPadding = 8.0
        static let buttonsSpacing = 8.0
        static let buttonsTopBottomSpacing = 4.0
        static let bottomStackViewSpacing = 16.0
        static let bottomViewHeight = 44.0
        static let defaultButtonHeihgt = 44.0
    }
}
