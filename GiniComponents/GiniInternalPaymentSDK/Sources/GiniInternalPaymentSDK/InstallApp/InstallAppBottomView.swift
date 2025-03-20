//
//  InstallAppBottomView.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniUtilites

public final class InstallAppBottomView: BottomSheetViewController {

    var viewModel: InstallAppBottomViewModel

    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []

    private let contentView = EmptyView()
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
        return label
    }()
    
    private let bankView = EmptyView()
    
    private lazy var bankIconImageView: UIImageView = {
        let imageView = UIImageView(image: viewModel.bankImageIcon)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.roundCorners(corners: .allCorners, radius: Constants.bankIconCornerRadius)
        imageView.layer.borderWidth = Constants.bankIconBorderWidth
        imageView.layer.borderColor = viewModel.configuration.bankIconBorderColor.cgColor
        return imageView
    }()
    
    private let moreInformationView = EmptyView()
    
    private lazy var moreInformationStackView = EmptyStackView()
        .orientation(.horizontal)
        .spacing(Constants.viewPaddingConstraint)
        .distribution(.fillProportionally)

    private lazy var moreInformationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = viewModel.configuration.moreInformationTextColor
        label.font = viewModel.configuration.moreInformationFont
        label.numberOfLines = 0
        label.text = viewModel.moreInformationLabelText
        return label
    }()
    
    private lazy var moreInformationButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(viewModel.configuration.moreInformationIcon, for: .normal)
        button.tintColor = viewModel.configuration.moreInformationAccentColor
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private lazy var continueButton: PaymentPrimaryButton = {
        let button = PaymentPrimaryButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configure(with: viewModel.primaryButtonConfiguration)
        button.customConfigure(text: viewModel.strings.continueLabelText,
                               textColor: viewModel.paymentProviderColors?.text.toColor(),
                               backgroundColor: viewModel.paymentProviderColors?.background.toColor())
        return button
    }()
    
    private lazy var appStoreImageView: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(viewModel.configuration.appStoreIcon, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(tapOnAppStoreButton), for: .touchUpInside)
        return button
    }()
    
    private let buttonsView: UIView = EmptyView()
    
    private let bottomView = EmptyView()

    private lazy var poweredByGiniView: PoweredByGiniView = {
        PoweredByGiniView(viewModel: viewModel.poweredByGiniViewModel)
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupInitialLayout()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public init(viewModel: InstallAppBottomViewModel, bottomSheetConfiguration: BottomSheetConfiguration) {
        self.viewModel = viewModel
        super.init(configuration: bottomSheetConfiguration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        setupViewHierarchy()
        setupLayout()
        setupListeners()
        setButtonsState()
        setupViewVisibility()
    }

    private func setupViewHierarchy() {
        titleView.addSubview(titleLabel)
        contentStackView.addArrangedSubview(titleView)
        bankView.addSubview(bankIconImageView)
        contentStackView.addArrangedSubview(bankView)
        moreInformationView.addSubview(moreInformationStackView)
        contentStackView.addArrangedSubview(moreInformationView)
        buttonsView.addSubview(continueButton)
        buttonsView.addSubview(appStoreImageView)
        contentStackView.addArrangedSubview(buttonsView)
        bottomView.addSubview(poweredByGiniView)
        contentStackView.addArrangedSubview(bottomView)
        contentView.addSubview(contentStackView)
        self.setContent(content: contentView)
    }

    private func setupViewVisibility() {
        poweredByGiniView.isHidden = !viewModel.shouldShowBrandedView
    }

    private func setupLayout() {
        setupTitleViewConstraints()
        setupBankImageConstraints()
        setupMoreInformationConstraints()
        setupContinueButtonConstraints()
        setupAppStoreButtonConstraints()
        setupPoweredByGiniConstraints()
    }
    
    private func setupListeners() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }

    private func setupInitialLayout() {
        updateLayoutForCurrentOrientation()
    }

    private func updateLayoutForCurrentOrientation() {
        if UIDevice.isPortrait() {
            setupPortraitConstraints()
        } else {
            setupLandscapeConstraints()
        }
    }

    // Portrait Layout Constraints
    private func setupPortraitConstraints() {
        NSLayoutConstraint.deactivate(landscapeConstraints)
        updateMoreInformationStackView(for: .portrait)

        portraitConstraints = [
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            moreInformationStackView.topAnchor.constraint(equalTo: moreInformationView.topAnchor, constant: Constants.viewPaddingConstraint),
            poweredByGiniView.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -Constants.viewPaddingConstraint)
        ]
        NSLayoutConstraint.activate(portraitConstraints)
    }

    // Landscape Layout Constraints
    private func setupLandscapeConstraints() {
        NSLayoutConstraint.deactivate(portraitConstraints)
        updateMoreInformationStackView(for: .landscape)

        landscapeConstraints = [
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.landscapePadding),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.landscapePadding),
            moreInformationStackView.topAnchor.constraint(equalTo: moreInformationView.topAnchor, constant: Constants.moreInformationTopPaddingLandscape),
            poweredByGiniView.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor)
        ]
        NSLayoutConstraint.activate(landscapeConstraints)
    }

    // Enum to Represent Layout Types
    private enum LayoutType {
        case portrait
        case landscape
    }

    // Helper Method to Update More Information Stack View
    private func updateMoreInformationStackView(for layout: LayoutType) {
        moreInformationStackView.removeAllArrangedSubviews()

        switch layout {
        case .portrait:
            configureStackView(alignment: .leading, textAlignment: .left, addPaddingViews: false)
        case .landscape:
            configureStackView(alignment: .center, textAlignment: .center, addPaddingViews: true)
        }
    }

    private func configureStackView(alignment: UIStackView.Alignment, textAlignment: NSTextAlignment, addPaddingViews: Bool) {
        titleLabel.textAlignment = textAlignment
        moreInformationStackView.alignment = alignment
        moreInformationLabel.textAlignment = textAlignment

        if addPaddingViews {
            moreInformationStackView.addArrangedSubview(UIView())
        }

        moreInformationStackView.addArrangedSubview(moreInformationButton)
        moreInformationStackView.addArrangedSubview(moreInformationLabel)

        if addPaddingViews {
            moreInformationStackView.addArrangedSubview(UIView())
        }
    }

    @objc private func willEnterForeground() {
        setButtonsState()
    }
    
    private func setButtonsState() {
        appStoreImageView.isHidden = viewModel.isBankInstalled
        continueButton.isHidden = !viewModel.isBankInstalled
        poweredByGiniView.isHidden = viewModel.isBankInstalled
        moreInformationLabel.text = viewModel.moreInformationLabelText
        
        continueButton.didTapButton = { [weak self] in
            self?.tapOnContinueButton()
        }
    }

    private func setupTitleViewConstraints() {
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: Constants.viewPaddingConstraint),
            titleLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -Constants.viewPaddingConstraint),
            titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor, constant: Constants.viewPaddingConstraint),
            titleLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor, constant: -Constants.topBottomPaddingConstraint)
        ])
    }

    private func setupBankImageConstraints() {
        NSLayoutConstraint.activate([
            bankIconImageView.heightAnchor.constraint(equalToConstant: Constants.bankIconSize),
            bankIconImageView.widthAnchor.constraint(equalToConstant: Constants.bankIconSize),
            bankIconImageView.topAnchor.constraint(equalTo: bankView.topAnchor),
            bankIconImageView.bottomAnchor.constraint(equalTo: bankView.bottomAnchor),
            bankIconImageView.centerXAnchor.constraint(equalTo: bankView.centerXAnchor)
        ])
    }
    
    private func setupMoreInformationConstraints() {
        NSLayoutConstraint.activate([
            moreInformationStackView.leadingAnchor.constraint(equalTo: moreInformationView.leadingAnchor, constant: Constants.viewPaddingConstraint),
            moreInformationStackView.trailingAnchor.constraint(equalTo: moreInformationView.trailingAnchor, constant: -Constants.viewPaddingConstraint),
            moreInformationStackView.bottomAnchor.constraint(equalTo: moreInformationView.bottomAnchor, constant: Constants.moreInformationBottomAnchorConstraint),
            moreInformationButton.widthAnchor.constraint(equalToConstant: Constants.infoIconSize)
        ])
    }
    
    private func setupContinueButtonConstraints() {
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor, constant: Constants.viewPaddingConstraint),
            continueButton.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor, constant: -Constants.viewPaddingConstraint),
            continueButton.heightAnchor.constraint(equalToConstant: Constants.continueButtonViewHeight),
            continueButton.topAnchor.constraint(equalTo: buttonsView.topAnchor, constant: Constants.continueButtonTopAnchor),
            continueButton.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: -Constants.continueButtonBottomAnchor)
        ])
    }
    
    private func setupAppStoreButtonConstraints() {
        NSLayoutConstraint.activate([
            appStoreImageView.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor, constant: Constants.viewPaddingConstraint),
            appStoreImageView.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor, constant: -Constants.viewPaddingConstraint),
            appStoreImageView.heightAnchor.constraint(equalToConstant: Constants.appStoreImageViewHeight),
            appStoreImageView.topAnchor.constraint(equalTo: buttonsView.topAnchor, constant: Constants.continueButtonTopAnchor),
            appStoreImageView.centerXAnchor.constraint(equalTo: buttonsView.centerXAnchor),
            appStoreImageView.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: -Constants.appStoreBottomAnchor)
        ])
    }

    private func setupPoweredByGiniConstraints() {
        NSLayoutConstraint.activate([
            poweredByGiniView.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: Constants.bottomViewHeight)
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

extension InstallAppBottomView {
    enum Constants {
        static let viewPaddingConstraint = 16.0
        static let bankIconSize = 36.0
        static let bankIconCornerRadius = 6.0
        static let bankIconBorderWidth = 1.0
        static let continueButtonViewHeight = 56.0
        static let continueButtonTopAnchor = 16.0
        static let continueButtonBottomAnchor = 4.0
        static let appStoreBottomAnchor = 16.0
        static let appStoreImageViewHeight = 44.0
        static let topBottomPaddingConstraint = 10.0
        static let topAnchorPoweredByGiniConstraint = 5.0
        static let moreInformationBottomAnchorConstraint = 8.0
        static let infoIconSize = 24.0
        static let bottomViewHeight = 22.0
        static let landscapePadding = 126.0
        static let moreInformationTopPaddingLandscape = 32.0
    }
}
