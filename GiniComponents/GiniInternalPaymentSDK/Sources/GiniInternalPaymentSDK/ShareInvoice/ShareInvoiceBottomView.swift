//
//  ShareInvoiceBottomView.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniUtilites

public final class ShareInvoiceBottomView: BottomSheetViewController {

    var viewModel: ShareInvoiceBottomViewModel
    
    private let contentStackView = EmptyStackView().orientation(.vertical)

    private let titleView = EmptyView()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = viewModel.titleText
        label.textColor = viewModel.configuration.titleAccentColor
        label.font = viewModel.configuration.titleFont
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .center
        return label
    }()
    
    private let qrCodeView = EmptyView()
    
    private lazy var qrImageView: UIImageView =  {
        let imageView = UIImageView(image: viewModel.qrCodeData.toImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.frame = CGRect(x: 0, y: 0, width: Constants.qrCodeImageSize, height: Constants.qrCodeImageSize)
        imageView.accessibilityTraits = .image
        imageView.isAccessibilityElement = true
        imageView.accessibilityLabel = viewModel.strings.accesibilityQRCodeImageText
        return imageView
    }()
    
    private let descriptionView = EmptyView()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = viewModel.descriptionLabelText
        label.textColor = viewModel.configuration.descriptionAccentColor
        label.font = viewModel.configuration.descriptionFont
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .center
        return label
    }()
    
    private let continueView = EmptyView()
    
    private lazy var continueButton: PaymentPrimaryButton = {
        let button = PaymentPrimaryButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configure(with: viewModel.primaryButtonConfiguration)
        button.customConfigure(text: viewModel.continueButtonText,
                               textColor: viewModel.paymentProviderColors?.text.toColor(),
                               backgroundColor: viewModel.paymentProviderColors?.background.toColor(),
                               rightImageData: viewModel.bankImageIcon)
        button.accessibilityLabel = viewModel.continueButtonText
        button.isAccessibilityElement = true
        button.accessibilityTraits = .button
        return button
    }()

    private let brandView = EmptyView()
    private let brandStackView = EmptyStackView().orientation(.horizontal).distribution(.fillEqually)
    
    private lazy var poweredByGiniView: PoweredByGiniView = {
        PoweredByGiniView(viewModel: viewModel.poweredByGiniViewModel)
    }()
    
    private let bottomView = EmptyView()
    private lazy var paymentInfoView: UIView = {
        let emptyView = EmptyView()
        emptyView.roundCorners(corners: .allCorners, radius: Constants.paymentInfoCornerRadius)
        emptyView.layer.borderColor = viewModel.configuration.paymentInfoBorderColor.cgColor
        emptyView.layer.borderWidth = Constants.paymentInfoBorderWidth
        emptyView.backgroundColor = .clear
        return emptyView
    }()
    
    private lazy var paymentInfoStackView = generatePaymentInfoViews()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    public init(viewModel: ShareInvoiceBottomViewModel, bottomSheetConfiguration: BottomSheetConfiguration) {
        self.viewModel = viewModel
        super.init(configuration: bottomSheetConfiguration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        setupViewHierarchy()
        setupLayout()
        setButtonsState()
    }

    private func setupViewHierarchy() {
        // Create and configure the UIScrollView
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        
        // Add contentStackView to the UIScrollView
        scrollView.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Apply constraints for contentStackView
        setupContentStackViewConstraints(in: scrollView)
        
        // Set up the content hierarchy
        titleView.addSubview(titleLabel)
        contentStackView.addArrangedSubview(titleView)
        
        qrCodeView.addSubview(qrImageView)
        contentStackView.addArrangedSubview(qrCodeView)
        
        brandStackView.addArrangedSubview(UIView())
        if viewModel.shouldShowBrandedView {
            brandStackView.addArrangedSubview(poweredByGiniView)
        }
        brandStackView.addArrangedSubview(UIView())
        brandView.addSubview(brandStackView)
        contentStackView.addArrangedSubview(brandView)
        
        continueView.addSubview(continueButton)
        contentStackView.addArrangedSubview(continueView)
        
        descriptionView.addSubview(descriptionLabel)
        contentStackView.addArrangedSubview(descriptionView)
        
        paymentInfoView.addSubview(paymentInfoStackView)
        bottomView.addSubview(paymentInfoView)
        contentStackView.addArrangedSubview(bottomView)
        
        // Calculate and update scrollView height dynamically
        DispatchQueue.main.async {
            self.updateScrollViewHeight(scrollView: scrollView)
        }
        // Add the UIScrollView to the main container
        self.setContent(content: scrollView)
    }
    
    private func setupContentStackViewConstraints(in scrollView: UIScrollView) {
        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    // Function to dynamically update scrollView height
    private func updateScrollViewHeight(scrollView: UIScrollView) {
        // Force layout to calculate the content size
        scrollView.layoutIfNeeded()
        let contentHeight = contentStackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        
        // Adjust the scrollView height
        let scrollViewHeight = contentHeight + (2 * Constants.viewPaddingConstraint)
        scrollView.heightAnchor.constraint(equalToConstant: scrollViewHeight).isActive = true
        
        // If needed, adjust bottom sheet constraints or animations
        self.view.layoutIfNeeded()
    }


    private func setupLayout() {
        setupTitleViewConstraints()
        setupQRCodeImageConstraints()
        setupDescriptionViewConstraints()
        setupContinueButtonConstraints()
        setupPoweredByGiniConstraints()
        setupPaymentInfoViewConstraints()
    }
    
    private func setButtonsState() {
        continueButton.didTapButton = { [weak self] in
            self?.tapOnContinueButton()
        }
    }

    private func setupTitleViewConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: Constants.viewPaddingConstraint),
            titleLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -Constants.viewPaddingConstraint),
            titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor, constant: Constants.topBottomPaddingConstraint),
            titleLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor, constant: -Constants.topBottomPaddingConstraint)
        ])
    }
    
    private func setupQRCodeImageConstraints() {
        NSLayoutConstraint.activate([
            qrImageView.centerXAnchor.constraint(equalTo: qrCodeView.centerXAnchor),
            qrImageView.widthAnchor.constraint(equalToConstant: Constants.qrCodeImageSize),
            qrImageView.heightAnchor.constraint(equalToConstant: Constants.qrCodeImageSize),
            qrImageView.topAnchor.constraint(equalTo: qrCodeView.topAnchor),
            qrImageView.bottomAnchor.constraint(equalTo: qrCodeView.bottomAnchor)
        ])
    }
    
    private func setupDescriptionViewConstraints() {
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: descriptionView.leadingAnchor, constant: Constants.viewPaddingConstraint),
            descriptionLabel.trailingAnchor.constraint(equalTo: descriptionView.trailingAnchor, constant: -Constants.viewPaddingConstraint),
            descriptionLabel.topAnchor.constraint(equalTo: descriptionView.topAnchor, constant: Constants.topBottomPaddingConstraint),
            descriptionLabel.bottomAnchor.constraint(equalTo: descriptionView.bottomAnchor, constant: -Constants.bottomDescriptionConstraint)
        ])
    }

    private func setupContinueButtonConstraints() {
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: continueView.leadingAnchor, constant: Constants.viewPaddingConstraint),
            continueButton.trailingAnchor.constraint(equalTo: continueView.trailingAnchor, constant: -Constants.viewPaddingConstraint),
            continueButton.heightAnchor.constraint(equalToConstant: Constants.continueButtonViewHeight),
            continueButton.topAnchor.constraint(equalTo: continueView.topAnchor, constant: Constants.topBottomPaddingConstraint),
            continueButton.bottomAnchor.constraint(equalTo: continueView.bottomAnchor)
        ])
    }

    private func setupPoweredByGiniConstraints() {
        NSLayoutConstraint.activate([
            brandStackView.leadingAnchor.constraint(equalTo: brandView.leadingAnchor, constant: Constants.viewPaddingConstraint),
            brandStackView.trailingAnchor.constraint(equalTo: brandView.trailingAnchor, constant: -Constants.viewPaddingConstraint),
            brandStackView.topAnchor.constraint(equalTo: brandView.topAnchor),
            brandStackView.bottomAnchor.constraint(equalTo: brandView.bottomAnchor),
            brandStackView.heightAnchor.constraint(equalToConstant: Constants.brandViewHeight)
        ])
    }
    
    private func setupPaymentInfoViewConstraints() {
        NSLayoutConstraint.activate([
            paymentInfoView.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: Constants.viewPaddingConstraint),
            paymentInfoView.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -Constants.viewPaddingConstraint),
            paymentInfoView.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor),
            paymentInfoView.topAnchor.constraint(equalTo: bottomView.topAnchor),
            paymentInfoView.heightAnchor.constraint(equalToConstant: Constants.bottomViewHeight),
            paymentInfoStackView.leadingAnchor.constraint(equalTo: paymentInfoView.leadingAnchor, constant: Constants.viewPaddingConstraint),
            paymentInfoStackView.trailingAnchor.constraint(equalTo: paymentInfoView.trailingAnchor, constant: -Constants.viewPaddingConstraint),
            paymentInfoStackView.topAnchor.constraint(equalTo: paymentInfoView.topAnchor, constant: Constants.viewPaddingConstraint),
            paymentInfoStackView.bottomAnchor.constraint(equalTo: paymentInfoView.bottomAnchor, constant: -Constants.viewPaddingConstraint)
        ])
    }
    
    @objc
    private func tapOnContinueButton() {
        viewModel.didTapOnContinue()
    }

    @objc
    private func tapOnAppStoreButton() {
        openPaymentProvidersAppStoreLink(urlString: viewModel.selectedPaymentProvider?.appStoreUrlIOS)
    }
    
    private func openPaymentProvidersAppStoreLink(urlString: String?) {
        guard let urlString = urlString else {
            print("AppStore link unavailable for this payment provider")
            return
        }
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    private func generatePaymentInfoViews() -> UIStackView {
        let paymentInfoStackView = createStackView(distribution: .fillEqually, spacing: Constants.viewPaddingConstraint, orientation: .vertical)
        [
            generateInfoStackView(title: viewModel.strings.recipientLabelText, subtitle: viewModel.paymentInfo?.recipient),
            generateInfoStackView(title: viewModel.strings.ibanLabelText, subtitle: viewModel.paymentInfo?.iban),
            generateAmountPurposeStackView()
        ].forEach { paymentInfoStackView.addArrangedSubview($0) }
        return paymentInfoStackView
    }

    private func generateInfoStackView(title: String, subtitle: String?) -> UIStackView {
        let stackView = createStackView(distribution: .fill, spacing: Constants.paymentInfoFieldsSpacing, orientation: .vertical)
        stackView.addArrangedSubview(createLabel(text: title, isTitle: true))
        stackView.addArrangedSubview(createLabel(text: subtitle ?? "", isTitle: false))
        return stackView
    }

    private func generateAmountPurposeStackView() -> UIStackView {
        let amountPurposeStackView = createStackView(distribution: .fillEqually, spacing: Constants.viewPaddingConstraint, orientation: .horizontal)
        
        let amountStackView = generateInfoStackView(title: viewModel.strings.amountLabelText, subtitle: viewModel.paymentInfo?.amount)
        let purposeStackView = generateInfoStackView(title: viewModel.strings.purposeLabelText, subtitle: viewModel.paymentInfo?.purpose)
        
        [amountStackView, purposeStackView].forEach { amountPurposeStackView.addArrangedSubview($0) }
        return amountPurposeStackView
    }

    private func createLabel(text: String, isTitle: Bool) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textAlignment = .left
        label.font = isTitle ? viewModel.configuration.titlePaymentInfoFont : viewModel.configuration.subtitlePaymentInfoFont
        label.textColor = isTitle ? viewModel.configuration.titlePaymentInfoTextColor : viewModel.configuration.subtitlePaymentInfoTextColor
        return label
    }

    private func createStackView(distribution: UIStackView.Distribution, spacing: CGFloat, orientation: NSLayoutConstraint.Axis) -> UIStackView {
        let stackView = EmptyStackView()
        stackView.distribution = distribution
        stackView.spacing = spacing
        stackView.axis = orientation
        return stackView
    }
}

extension ShareInvoiceBottomView {
    enum Constants {
        static let viewPaddingConstraint = 16.0
        static let topBottomPaddingConstraint = 10.0
        static let bottomDescriptionConstraint = 20.0
        static let continueButtonViewHeight = 56.0
        static let topAnchorAppsViewConstraint = 20.0
        static let trailingAppsViewConstraint = 40.0
        static let topAnchorTipViewConstraint = 5.0
        static let brandViewHeight = 44.0
        static let bottomViewHeight = 190.0
        static let qrCodeImageSize = 208.0
        static let paymentInfoBorderWidth = 1.0
        static let paymentInfoCornerRadius = 16.0
        static let paymentInfoFieldsSpacing = 4.0
    }
}
