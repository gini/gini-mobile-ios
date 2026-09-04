//
//  ShareInvoiceBottomView.swift
//  GiniInternalPaymentSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Combine
import UIKit
import GiniUtilites

public final class ShareInvoiceBottomView: GiniBottomSheetViewController {

    var viewModel: ShareInvoiceBottomViewModel

    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []
    private var accessibilityFocusWorkItem: DispatchWorkItem?

    private lazy var scrollView: EmptyScrollView = {
        let scrollView = EmptyScrollView()
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
        label.adjustsFontForContentSizeCategory = true
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
        imageView.accessibilityTraits = .image
        imageView.isAccessibilityElement = true
        imageView.accessibilityLabel = viewModel.strings.accessibilityQRCodeImageText
        return imageView
    }()
    
    private let descriptionView = EmptyView()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = viewModel.descriptionLabelText
        label.textColor = viewModel.configuration.descriptionAccentColor
        label.font = viewModel.configuration.descriptionFont
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .left
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
    private var cancellables = Set<AnyCancellable>()
    
    private var dynamicInfoLabels: [UILabel] = []
    
    // Add a property to store the height constraint
    private var scrollViewHeightConstraint: NSLayoutConstraint?
    
    public var shouldShowDragIndicator: Bool {
        true
    }
    
    public var shouldShowInFullScreenInLandscapeMode: Bool {
        false
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupInitialLayout()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        notifyLayoutChanged()
        setupAccessibility()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Cancel any pending focus work so a quick dismiss cannot re-trap VoiceOver
        // after this flag is cleared.
        accessibilityFocusWorkItem?.cancel()
        view.accessibilityViewIsModal = false
    }
    
    public init(viewModel: ShareInvoiceBottomViewModel, bottomSheetConfiguration: BottomSheetConfiguration) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = bottomSheetConfiguration.backgroundColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func notifyLayoutChanged() {
        accessibilityFocusWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self, view.window != nil, !isBeingDismissed else { return }
            UIAccessibility.post(notification: .screenChanged, argument: titleLabel)
        }
        accessibilityFocusWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: work)
    }
    
    private func setupView() {
        configureBottomSheet()
        setupViewHierarchy()
        setupLayout()
        setButtonsState()
        setupViewVisibility()
        setupAccessibility()
    }
    
    private func setupAccessibility() {
        view.accessibilityViewIsModal = true
        // Elements are assigned to scrollView (not view) so that UIKit recognises the
        // UIScrollView as the accessibility container. This causes VoiceOver to automatically
        // call scrollRectToVisible when navigating to an off-screen element in landscape,
        // where the sheet height is reduced and content overflows below the visible area.
        // Setting view.accessibilityElements = [scrollView] keeps the modal trap intact
        // while routing all traversal through the scroll view.
        scrollView.accessibilityElements = [
            titleLabel,
            qrImageView
        ] + (viewModel.shouldShowBrandedView ? [poweredByGiniView] : []) + [
            continueButton,
            descriptionLabel
        ] + dynamicInfoLabels
        view.accessibilityElements = [scrollView]
    }

    private func setupViewHierarchy() {
        // Add contentStackView through EmptyScrollView's content view so that the
        // internal contentView drives contentLayoutGuide.height and vertical scrolling works.
        scrollView.addContentSubview(contentStackView)
        bindToSizeUpdates()
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Apply constraints for contentStackView
        setupContentStackViewConstraints(in: scrollView)

        // Set up the content hierarchy
        titleView.addSubview(titleLabel)
        
        qrCodeView.addSubview(qrImageView)

        brandStackView.addArrangedSubview(poweredByGiniView)
        brandView.addSubview(brandStackView)

        continueView.addSubview(continueButton)
        
        descriptionView.addSubview(descriptionLabel)
        bottomView.addSubview(paymentInfoView)

        topStackView.addArrangedSubview(qrCodeView)
        topStackView.addArrangedSubview(brandView)

        bottomStackView.addArrangedSubview(continueView)
        bottomStackView.addArrangedSubview(descriptionView)
        bottomStackView.addArrangedSubview(bottomView)
    
        setupSplitStackViewHierarchy()
        // Add the UIScrollView to the main container
        setContent(content: scrollView)
    }
    
    private func setContent(content: UIView) {
        view.addSubview(content)
        
        NSLayoutConstraint.activate([
            content.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            content.topAnchor.constraint(equalTo: view.topAnchor),
            content.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupViewVisibility() {
        poweredByGiniView.isHidden = !viewModel.shouldShowBrandedView
    }

    fileprivate func setupSplitStackViewHierarchy() {
        splitStacKView.removeAllArrangedSubviews()
        contentStackView.removeAllArrangedSubviews()
        
        splitStacKView.addArrangedSubview(topStackView)
        splitStacKView.addArrangedSubview(bottomStackView)
        contentStackView.addArrangedSubview(titleView)
        contentStackView.addArrangedSubview(splitStacKView)
    }
    
    private func setupContentStackViewConstraints(in scrollView: UIScrollView) {
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor,
                                                  constant: Constants.viewPaddingConstraint),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }

    private func setupInitialLayout() {
        updateLayoutForCurrentOrientation()
    }
    
    public func updateViews(for targetSize: CGSize? = nil) {
        updateLayoutForCurrentOrientation(for: targetSize)
        view.layoutIfNeeded()
    }

    private func updateLayoutForCurrentOrientation(for targetSize: CGSize? = nil) {
        let usePortrait: Bool
        if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
            usePortrait = true
        } else if let size = targetSize {
            usePortrait = size.width <= size.height
        } else {
            usePortrait = UIDevice.isPortrait()
        }

        if usePortrait {
            setupPortraitConstraints()
        } else {
            setupLandscapeConstraints()
        }
        setupAccessibility()
    }

    private func setupConstraints(for orientation: NSLayoutConstraint.Axis) {
        // Deactivate previous constraints
        NSLayoutConstraint.deactivate(landscapeConstraints + portraitConstraints)

        // Update the split stack view and payment info stack view
        setupSplitStackViewHierarchy()
        splitStacKView.orientation(orientation).spacing(orientation == .vertical ? 0 : Constants.viewPaddingConstraint)
        splitStacKView.alignment = orientation == .horizontal ? .top : .fill

        paymentInfoStackView = generatePaymentInfoViews()
        updatePaymentInfoView()

        let isPortrait = orientation == .vertical

        let qrCodeSize = isPortrait ? Constants.qrCodeImageSizePortrait : Constants.qrCodeImageSizeLandscape
        let sharedConstraints = [
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor,
                                                      constant: Constants.contentPadding),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor,
                                                       constant: -Constants.contentPadding),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor,
                                                    constant: -2 * Constants.contentPadding),
            qrImageView.widthAnchor.constraint(equalToConstant: qrCodeSize),
            qrImageView.heightAnchor.constraint(equalToConstant: qrCodeSize),
            paymentInfoStackView.leadingAnchor.constraint(equalTo: paymentInfoView.leadingAnchor,
                                                          constant: Constants.viewPaddingConstraint),
            paymentInfoStackView.trailingAnchor.constraint(equalTo: paymentInfoView.trailingAnchor,
                                                           constant: -Constants.viewPaddingConstraint),
            paymentInfoStackView.topAnchor.constraint(equalTo: paymentInfoView.topAnchor,
                                                      constant: Constants.viewPaddingConstraint),
            paymentInfoStackView.bottomAnchor.constraint(equalTo: paymentInfoView.bottomAnchor,
                                                         constant: -Constants.viewPaddingConstraint)
        ]

        if isPortrait {
            portraitConstraints = sharedConstraints
            NSLayoutConstraint.activate(portraitConstraints)
        } else {
            landscapeConstraints = sharedConstraints + [
                topStackView.widthAnchor.constraint(equalToConstant: qrCodeSize)
            ]
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
            qrImageView.topAnchor.constraint(equalTo: qrCodeView.topAnchor),
            qrImageView.bottomAnchor.constraint(equalTo: qrCodeView.bottomAnchor)
        ])
    }
    
    private func setupDescriptionViewConstraints() {
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: descriptionView.topAnchor, constant: Constants.topBottomPaddingConstraint),
            descriptionLabel.leadingAnchor.constraint(equalTo: descriptionView.leadingAnchor, constant: Constants.viewPaddingConstraint),
            descriptionLabel.trailingAnchor.constraint(equalTo: descriptionView.trailingAnchor, constant: -Constants.viewPaddingConstraint),
            descriptionLabel.bottomAnchor.constraint(equalTo: descriptionView.bottomAnchor, constant: -Constants.topBottomPaddingConstraint),
        ])
    }

    private func setupContinueButtonConstraints() {
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: continueView.leadingAnchor, constant: Constants.viewPaddingConstraint),
            continueButton.trailingAnchor.constraint(equalTo: continueView.trailingAnchor, constant: -Constants.viewPaddingConstraint),
            continueButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.continueButtonViewHeight),
            continueButton.topAnchor.constraint(equalTo: continueView.topAnchor, constant: Constants.topBottomPaddingConstraint),
            continueButton.bottomAnchor.constraint(equalTo: continueView.bottomAnchor)
        ])
    }

    private func setupPoweredByGiniConstraints() {
        NSLayoutConstraint.activate([
            brandStackView.centerXAnchor.constraint(equalTo: qrImageView.centerXAnchor),
            brandStackView.topAnchor.constraint(equalTo: brandView.topAnchor),
            brandStackView.bottomAnchor.constraint(equalTo: brandView.bottomAnchor),
            poweredByGiniView.heightAnchor.constraint(equalToConstant: Constants.brandViewHeight)
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
    
    private func generatePaymentInfoViews() -> UIStackView {
        dynamicInfoLabels.removeAll()
        let stackView = createStackView(distribution: .fill, spacing: Constants.viewPaddingConstraint, orientation: .vertical)
        [
            generateRecipientIbanStackView(),
            generateAmountPurposeStackView()
        ].forEach { stackView.addArrangedSubview($0) }
        return stackView
    }
    
    private func generateRecipientIbanStackView() -> UIStackView {
        // Always stack vertically: the IBAN is too long to share a row without breaking mid-number.
        let recipientIBANStackView = createStackView(distribution: .fill, spacing: Constants.viewPaddingConstraint, orientation: .vertical)
        
        let recipientStackView = generateInfoStackView(title: viewModel.strings.recipientLabelText, subtitle: viewModel.paymentInfo?.recipient)
        let ibanStackView = generateInfoStackView(title: viewModel.strings.ibanLabelText, subtitle: viewModel.paymentInfo?.iban)
        
        [recipientStackView, ibanStackView].forEach { recipientIBANStackView.addArrangedSubview($0) }
        return recipientIBANStackView
    }

    private func generateInfoStackView(title: String, subtitle: String?) -> UIStackView {
        let stackView = createStackView(distribution: .fill, spacing: Constants.paymentInfoFieldsSpacing, orientation: .vertical)
        let placeholderLabel = createLabel(text: title, isTitle: true)
        let valueLabel = createLabel(text: subtitle ?? "", isTitle: false)

        placeholderLabel.isAccessibilityElement = false
        if let subtitle = subtitle, !subtitle.isEmpty {
            valueLabel.accessibilityLabel = "\(title), \(subtitle)"
        } else {
            valueLabel.accessibilityLabel = title
        }

        stackView.addArrangedSubview(placeholderLabel)
        stackView.addArrangedSubview(valueLabel)
        
        dynamicInfoLabels.append(placeholderLabel)
        dynamicInfoLabels.append(valueLabel)

        return stackView
    }

    private func generateAmountPurposeStackView() -> UIStackView {
        let isAccessibility = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        let axis: NSLayoutConstraint.Axis = isAccessibility ? .vertical : .horizontal
        let amountPurposeStackView = createStackView(distribution: .fill, spacing: Constants.viewPaddingConstraint, orientation: axis)
        var stackViews: [UIStackView] = []
        
        if let amountToPayString = viewModel.paymentInfo?.amount, let amountToPay = Price(extractionString: amountToPayString) {
            stackViews.append(generateInfoStackView(title: viewModel.strings.amountLabelText, subtitle: amountToPay.string))
        }
        
        stackViews.append(generateInfoStackView(title: viewModel.strings.purposeLabelText, subtitle: viewModel.paymentInfo?.purpose))
        
        stackViews.forEach { amountPurposeStackView.addArrangedSubview($0) }
        return amountPurposeStackView
    }

    private func createLabel(text: String, isTitle: Bool) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textAlignment = .left
        let baseFont = isTitle ? viewModel.configuration.titlePaymentInfoFont : viewModel.configuration.subtitlePaymentInfoFont
        label.font = baseFont
        label.adjustsFontForContentSizeCategory = true
        label.textColor = isTitle ? viewModel.configuration.titlePaymentInfoTextColor : viewModel.configuration.subtitlePaymentInfoTextColor
        label.numberOfLines = 0
        return label
    }

    private func createStackView(distribution: UIStackView.Distribution, spacing: CGFloat, orientation: NSLayoutConstraint.Axis) -> UIStackView {
        let stackView = EmptyStackView()
        stackView.distribution = distribution
        stackView.spacing = spacing
        stackView.axis = orientation
        return stackView
    }
    
    private func bindToSizeUpdates() {
        scrollView.$size
            .receive(on: DispatchQueue.main)
            .sink { [weak self] size in
                self?.updateBottomSheetHeight(size.height)
            }.store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIContentSizeCategory.didChangeNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateViews() }
            .store(in: &cancellables)
    }

    // Handle orientation change
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        // Perform layout updates with animation, passing the known target size so
        // that constraint selection uses the incoming dimensions rather than the
        // device orientation, which can lag behind during the transition.
        coordinator.animate(alongsideTransition: { [weak self] context in
            self?.updateViews(for: size)
        }, completion: { [weak self] _ in
            self?.notifyLayoutChanged()
        })
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
        static let landscapePaddingRatio = 0.15
        static let contentPadding: CGFloat = 0
    }
}
