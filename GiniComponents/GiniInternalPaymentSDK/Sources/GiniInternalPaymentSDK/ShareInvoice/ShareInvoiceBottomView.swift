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
        imageView.contentMode = .scaleAspectFit
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
    private let brandStackView = EmptyStackView().orientation(.horizontal).distribution(.fill)
    
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
    
    private lazy var paymentInfoStackView = UIStackView()

    private let topStackView = EmptyStackView().orientation(.vertical).distribution(.fill)
    private let bottomStackView = EmptyStackView().orientation(.vertical)
    private let splitStacKView = EmptyStackView().distribution(.fill)
    
    // Add a property to store the height constraint
    private var scrollViewHeightConstraint: NSLayoutConstraint?

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
        
        qrCodeView.addSubview(qrImageView)

        brandStackView.addArrangedSubview(UIView())
        brandStackView.addArrangedSubview(poweredByGiniView)
        brandStackView.addArrangedSubview(UIView())
        brandView.addSubview(brandStackView)

        continueView.addSubview(continueButton)
        
        descriptionView.addSubview(descriptionLabel)
        bottomView.addSubview(paymentInfoView)

        topStackView.addArrangedSubview(qrCodeView)
        topStackView.addArrangedSubview(brandView)
        topStackView.addArrangedSubview(EmptyView())

        bottomStackView.addArrangedSubview(continueView)
        bottomStackView.addArrangedSubview(descriptionView)
        bottomStackView.addArrangedSubview(bottomView)
    
        setupSplitStackViewHierarchy()
        // Add the UIScrollView to the main container
        self.setContent(content: scrollView)
    }
    
    fileprivate func setupSplitStackViewHierarchy() {
        splitStacKView.removeAllArrangedSubviews()
        contentStackView.removeAllArrangedSubviews()
        
        splitStacKView.addArrangedSubview(topStackView)
        splitStacKView.addArrangedSubview(bottomStackView)
        contentStackView.addArrangedSubview(titleView)
        contentStackView.addArrangedSubview(splitStacKView)
        
        // Calculate and update scrollView height dynamically
        DispatchQueue.main.async {
            self.updateScrollViewHeight(scrollView: self.scrollView)
        }
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

    private func setupConstraints(for orientation: NSLayoutConstraint.Axis) {
        // Deactivate previous constraints
        NSLayoutConstraint.deactivate(orientation == .vertical ? landscapeConstraints : portraitConstraints)

        // Update the split stack view and payment info stack view
        setupSplitStackViewHierarchy()
        splitStacKView.orientation(orientation).spacing(orientation == .vertical ? 0 : Constants.viewPaddingConstraint)
        
        paymentInfoStackView = generatePaymentInfoViews(orientation: orientation)
        updatePaymentInfoView()
        
        let isPortrait = orientation == .vertical
        
        let qrCodeSize = isPortrait ? Constants.qrCodeImageSizePortrait : Constants.qrCodeImageSizeLandscape
        let bottomViewHeight = isPortrait ? Constants.bottomViewPortraitHeight : Constants.bottomViewLandscapeHeight
        let contentPadding = isPortrait ? 0 : Constants.landscapePadding
        
        let constraints = [
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: contentPadding),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -contentPadding),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -2 * contentPadding),
            qrImageView.widthAnchor.constraint(equalToConstant: qrCodeSize),
            qrImageView.heightAnchor.constraint(equalToConstant: qrCodeSize),
            descriptionLabel.leadingAnchor.constraint(equalTo: descriptionView.leadingAnchor, constant: isPortrait ? Constants.viewPaddingConstraint : 0),
            descriptionLabel.trailingAnchor.constraint(equalTo: descriptionView.trailingAnchor, constant: isPortrait ? -Constants.viewPaddingConstraint : 0),
            paymentInfoStackView.leadingAnchor.constraint(equalTo: paymentInfoView.leadingAnchor, constant: Constants.viewPaddingConstraint),
            paymentInfoStackView.trailingAnchor.constraint(equalTo: paymentInfoView.trailingAnchor, constant: -Constants.viewPaddingConstraint),
            paymentInfoStackView.topAnchor.constraint(equalTo: paymentInfoView.topAnchor, constant: Constants.viewPaddingConstraint),
            paymentInfoStackView.bottomAnchor.constraint(equalTo: paymentInfoView.bottomAnchor, constant: -Constants.viewPaddingConstraint),
            paymentInfoView.heightAnchor.constraint(equalToConstant: bottomViewHeight)
        ]

        if isPortrait {
            portraitConstraints = constraints
            NSLayoutConstraint.activate(portraitConstraints)
        } else {
            landscapeConstraints = constraints
            NSLayoutConstraint.activate(landscapeConstraints)
        }
    }
    
    private func updatePaymentInfoView() {
        paymentInfoView.subviews.forEach { $0.removeFromSuperview() }
        paymentInfoView.addSubview(paymentInfoStackView)
    }
    
    private func setupPortraitConstraints() {
        setupConstraints(for: .vertical)
    }
    
    private func setupLandscapeConstraints() {
        setupConstraints(for: .horizontal)
    }

    // Function to dynamically update scrollView height
    private func updateScrollViewHeight(scrollView: UIScrollView) {
        // Force layout to calculate the content size
        scrollView.layoutIfNeeded()
        let contentHeight = contentStackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        
        // Deactivate the existing height constraint if it exists
        if let existingConstraint = scrollViewHeightConstraint {
            existingConstraint.isActive = false
        }
        // Adjust the scrollView height
        let scrollViewHeight = contentHeight + (2 * Constants.viewPaddingConstraint)
        scrollViewHeightConstraint = scrollView.heightAnchor.constraint(equalToConstant: scrollViewHeight)
        scrollViewHeightConstraint?.isActive = true
        
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
            brandStackView.leadingAnchor.constraint(equalTo: brandView.leadingAnchor),
            brandStackView.trailingAnchor.constraint(equalTo: brandView.trailingAnchor),
            brandStackView.topAnchor.constraint(equalTo: brandView.topAnchor),
            brandStackView.bottomAnchor.constraint(equalTo: brandView.bottomAnchor),
            poweredByGiniView.heightAnchor.constraint(equalToConstant: Constants.brandViewHeight),
            poweredByGiniView.centerXAnchor.constraint(equalTo: qrImageView.centerXAnchor),
            brandView.widthAnchor.constraint(equalTo: qrImageView.widthAnchor)
        ])
    }
    
    private func setupPaymentInfoViewConstraints() {
        NSLayoutConstraint.activate([
            paymentInfoView.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: Constants.viewPaddingConstraint),
            paymentInfoView.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -Constants.viewPaddingConstraint),
            paymentInfoView.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor),
            paymentInfoView.topAnchor.constraint(equalTo: bottomView.topAnchor),
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
    
    private func generatePaymentInfoViews(orientation: NSLayoutConstraint.Axis) -> UIStackView {
        let paymentInfoStackView = createStackView(distribution: .fill, spacing: Constants.viewPaddingConstraint, orientation: .vertical)
        [
            generateRecipientIbanStackView(orientation: orientation),
            generateAmountPurposeStackView()
        ].forEach { paymentInfoStackView.addArrangedSubview($0) }
        return paymentInfoStackView
    }
    
    private func generateRecipientIbanStackView(orientation: NSLayoutConstraint.Axis) -> UIStackView {
        let recipientIBANStackView = createStackView(distribution: .fillEqually, spacing: Constants.viewPaddingConstraint, orientation: orientation)
        
        let recipientStackView = generateInfoStackView(title: viewModel.strings.recipientLabelText, subtitle: viewModel.paymentInfo?.recipient)
        let ibanStackView = generateInfoStackView(title: viewModel.strings.ibanLabelText, subtitle: viewModel.paymentInfo?.iban)
        
        [recipientStackView, ibanStackView].forEach { recipientIBANStackView.addArrangedSubview($0) }
        return recipientIBANStackView
    }

    private func generateInfoStackView(title: String, subtitle: String?) -> UIStackView {
        let stackView = createStackView(distribution: .fillEqually, spacing: Constants.paymentInfoFieldsSpacing, orientation: .vertical)
        stackView.addArrangedSubview(createLabel(text: title, isTitle: true))
        stackView.addArrangedSubview(createLabel(text: subtitle ?? "", isTitle: false))
        NSLayoutConstraint.activate([
            stackView.heightAnchor.constraint(equalToConstant: 42) // Set the height constraint
        ])
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
        static let bottomViewPortraitHeight = 190.0
        static let bottomViewLandscapeHeight = 132.0
        static let qrCodeImageSizePortrait = 208.0
        static let qrCodeImageSizeLandscape = 158.0
        static let paymentInfoBorderWidth = 1.0
        static let paymentInfoCornerRadius = 16.0
        static let paymentInfoFieldsSpacing = 4.0
        static let landscapePadding = 126.0
    }
}
