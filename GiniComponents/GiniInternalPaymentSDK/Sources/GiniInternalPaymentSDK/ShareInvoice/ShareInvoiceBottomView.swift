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

    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        return scrollView
    }()
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
    
    private lazy var qrImageView: UIImageView = {
        let imageView = UIImageView(image: viewModel.qrCodeData.toImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
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
        return button
    }()

    private let brandView = EmptyView()
//    private let brandStackView = EmptyStackView().orientation(.horizontal).distribution(.fillEqually)
    
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

    private let topStackView = EmptyStackView().orientation(.vertical)
    private let bottomStackView = EmptyStackView().orientation(.vertical)
    private let splitStacKView = EmptyStackView()

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupInitialLayout()
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
        // Add contentStackView to the UIScrollView
        scrollView.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Apply constraints for contentStackView
        setupContentStackViewConstraints(in: scrollView)

        // Set up the content hierarchy
        titleView.addSubview(titleLabel)
        contentStackView.addArrangedSubview(titleView)
        
        qrCodeView.addSubview(qrImageView)

//        brandStackView.addArrangedSubview(poweredByGiniView)
        brandView.addSubview(poweredByGiniView)

        continueView.addSubview(continueButton)
        
        descriptionView.addSubview(descriptionLabel)
        
        paymentInfoView.addSubview(paymentInfoStackView)
        bottomView.addSubview(paymentInfoView)

        topStackView.addArrangedSubview(qrCodeView)
        topStackView.addArrangedSubview(brandView)

        bottomStackView.addArrangedSubview(continueView)
        bottomStackView.addArrangedSubview(descriptionView)
//        bottomStackView.addArrangedSubview(bottomView)

        splitStacKView.addArrangedSubview(topStackView)
        splitStacKView.addArrangedSubview(bottomStackView)
        contentStackView.addArrangedSubview(splitStacKView)

        // Calculate and update scrollView height dynamically
        DispatchQueue.main.async {
            self.updateScrollViewHeight(scrollView: self.scrollView)
        }
        // Add the UIScrollView to the main container
        self.setContent(content: scrollView)
    }
    
    private func setupContentStackViewConstraints(in scrollView: UIScrollView) {
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }

    private func setupInitialLayout() {
        updateLayoutForCurrentOrientation()
    }

    private func updateLayoutForCurrentOrientation() {
        let deviceOrientation = UIDevice.current.orientation
        switch deviceOrientation {
        case .portrait:
            setupPortraitConstraints()
        case .landscapeLeft, .landscapeRight:
            setupLandscapeConstraints()
        default:
            break
        }
    }

    // Portrait Layout Constraints
    private func setupPortraitConstraints() {
        NSLayoutConstraint.deactivate(landscapeConstraints)

        splitStacKView.orientation(.vertical).spacing(0)
        portraitConstraints = [
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            qrImageView.widthAnchor.constraint(equalToConstant: Constants.qrCodeImageSizePortrait),
            qrImageView.heightAnchor.constraint(equalToConstant: Constants.qrCodeImageSizePortrait),
            descriptionLabel.leadingAnchor.constraint(equalTo: descriptionView.leadingAnchor, constant: Constants.viewPaddingConstraint),
            descriptionLabel.trailingAnchor.constraint(equalTo: descriptionView.trailingAnchor, constant: -Constants.viewPaddingConstraint),
//            brandStackView.leadingAnchor.constraint(equalTo: brandView.leadingAnchor, constant: Constants.viewPaddingConstraint),
//            brandStackView.trailingAnchor.constraint(equalTo: brandView.trailingAnchor, constant: -Constants.viewPaddingConstraint),
        ]
        NSLayoutConstraint.activate(portraitConstraints)
    }

    // Landscape Layout Constraints
    private func setupLandscapeConstraints() {
        NSLayoutConstraint.deactivate(portraitConstraints)

        splitStacKView.orientation(.horizontal).spacing(Constants.viewPaddingConstraint)

        landscapeConstraints = [
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Constants.landscapePadding),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: Constants.landscapePadding),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -(2*Constants.landscapePadding)),
            qrImageView.widthAnchor.constraint(equalToConstant: Constants.qrCodeImageSizeLandscape),
            qrImageView.heightAnchor.constraint(equalToConstant: Constants.qrCodeImageSizeLandscape),
            descriptionLabel.leadingAnchor.constraint(equalTo: descriptionView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: descriptionView.trailingAnchor),
//            brandStackView.leadingAnchor.constraint(equalTo: brandView.leadingAnchor),
//            brandStackView.trailingAnchor.constraint(equalTo: brandView.trailingAnchor),
        ]
        NSLayoutConstraint.activate(landscapeConstraints)
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
            titleLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor, constant: -Constants.topBottomPaddingConstraint),
            descriptionLabel.bottomAnchor.constraint(equalTo: descriptionView.bottomAnchor, constant: -Constants.bottomDescriptionConstraintPortrait)
        ])
    }
    
    private func setupQRCodeImageConstraints() {
        NSLayoutConstraint.activate([
            qrImageView.centerXAnchor.constraint(equalTo: qrCodeView.centerXAnchor),
            qrImageView.topAnchor.constraint(equalTo: qrCodeView.topAnchor),
            qrImageView.bottomAnchor.constraint(equalTo: qrCodeView.bottomAnchor)
        ])
    }
    
    private func setupDescriptionViewConstraints() {
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: descriptionView.topAnchor, constant: Constants.topBottomPaddingConstraint),
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
            poweredByGiniView.topAnchor.constraint(equalTo: brandView.topAnchor),
            poweredByGiniView.bottomAnchor.constraint(equalTo: brandView.bottomAnchor),
            poweredByGiniView.heightAnchor.constraint(equalToConstant: Constants.brandViewHeight),
            poweredByGiniView.centerXAnchor.constraint(equalTo: brandView.centerXAnchor)
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

    // Handle orientation change
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateLayoutForCurrentOrientation()

        // Perform layout updates with animation
        coordinator.animate(alongsideTransition: { context in
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

extension ShareInvoiceBottomView {
    enum Constants {
        static let viewPaddingConstraint = 16.0
        static let topBottomPaddingConstraint = 10.0
        static let bottomDescriptionConstraintPortrait = 20.0
        static let bottomDescriptionConstraintLandscape = 8.0
        static let continueButtonViewHeight = 56.0
        static let topAnchorAppsViewConstraint = 20.0
        static let trailingAppsViewConstraint = 40.0
        static let topAnchorTipViewConstraint = 5.0
        static let brandViewHeight = 44.0
        static let bottomViewHeight = 190.0
        static let qrCodeImageSizePortrait = 208.0
        static let qrCodeImageSizeLandscape = 158.0
        static let paymentInfoBorderWidth = 1.0
        static let paymentInfoCornerRadius = 16.0
        static let paymentInfoFieldsSpacing = 4.0
        static let landscapePadding = 126.0
    }
}
