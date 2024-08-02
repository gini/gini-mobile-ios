//
//  PaymentComponentView.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniUtilites

final class PaymentComponentView: UIView {
    
    var viewModel: PaymentComponentViewModel! {
        didSet {
            setupView()
        }
    }
    
    private let contentStackView = EmptyStackView(orientation: .vertical)
    
    private let selectYourBankView = EmptyView()
    
    private lazy var selectYourBankLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = viewModel.selectYourBankLabelText
        label.textColor = viewModel.selectYourBankAccentColor
        label.font = viewModel.selectYourBankLabelFont
        label.numberOfLines = 0
        return label
    }()
    
    private let buttonsView = EmptyView()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = EmptyStackView(orientation: viewModel.showPaymentComponentInOneRow ? .horizontal : .vertical)
        stackView.spacing = Constants.buttonsSpacing
        return stackView
    }()
    
    private lazy var selectBankButton: PaymentSecondaryButton = {
        let button = PaymentSecondaryButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configure(with: viewModel.giniMerchantConfiguration.secondaryButtonConfiguration)
        return button
    }()
    
    private lazy var payInvoiceButton: PaymentPrimaryButton = {
        let button = PaymentPrimaryButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configure(with: viewModel.giniMerchantConfiguration.primaryButtonConfiguration)
        button.customConfigure(paymentProviderColors: viewModel.paymentProviderColors,
                               text: viewModel.ctaButtonText)
        return button
    }()
    
    private let bottomView = EmptyView()
    
    private let bottomStackView = EmptyStackView(orientation: .horizontal)
    
    private lazy var moreInformationView: MoreInformationView = {
        let view = MoreInformationView()
        let viewModel = MoreInformationViewModel()
        viewModel.delegate = self
        view.viewModel = viewModel
        return view
    }()

    private lazy var poweredByGiniView: PoweredByGiniView = {
        let view = PoweredByGiniView()
        view.viewModel = PoweredByGiniViewModel()
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = viewModel.backgroundColor
        
        selectYourBankView.addSubview(selectYourBankLabel)
        contentStackView.addArrangedSubview(selectYourBankView)
        
        buttonsStackView.addArrangedSubview(selectBankButton)
        buttonsStackView.addArrangedSubview(payInvoiceButton)
        buttonsView.addSubview(buttonsStackView)
        contentStackView.addArrangedSubview(buttonsView)
        
        bottomStackView.addArrangedSubview(moreInformationView)
        bottomStackView.addArrangedSubview(UIView())
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
    }
    
    private func updateButtonsViews() {
        selectBankButton.customConfigure(labelText: viewModel.selectBankButtonText,
                                         leftImageIcon: viewModel.bankImageIcon,
                                         rightImageIcon: viewModel.chevronDownIcon,
                                         rightImageTintColor: viewModel.chevronDownIconColor,
                                         shouldShowLabel: viewModel.showPaymentComponentInOneRow ? !viewModel.hasBankSelected : true)
        payInvoiceButton.isHidden = !viewModel.hasBankSelected
        selectBankButton.heightAnchor.constraint(equalToConstant: viewModel.showPaymentComponentInOneRow ? viewModel.minimumButtonsHeight : (viewModel.hasBankSelected ? viewModel.minimumButtonsHeight : Constants.defaultButtonHeihgt)).isActive = true
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
            selectYourBankLabel.bottomAnchor.constraint(equalTo: selectYourBankView.bottomAnchor)
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
            bottomStackView.heightAnchor.constraint(equalToConstant: Constants.bottomViewHeight)
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
    func didTapOnMoreInformation() {
        viewModel.tapOnMoreInformation()
    }
}

extension PaymentComponentView {
    private enum Constants {
        static let contentTopPadding = 8.0
        static let contentBottomPadding: CGFloat = 4
        static let buttonsSpacing = 8.0
        static let buttonsTopBottomSpacing = 4.0
        static let bottomViewHeight = 44.0
        static let defaultButtonHeihgt = 44.0
    }
}
