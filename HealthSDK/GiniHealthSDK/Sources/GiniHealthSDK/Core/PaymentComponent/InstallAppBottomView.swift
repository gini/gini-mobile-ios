//
//  InstallAppBottomView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

class InstallAppBottomView: UIView {

    var viewModel: InstallAppBottomViewModel! {
        didSet {
            setupView()
        }
    }

    private lazy var rectangleTopView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame = CGRect(x: 0, y: 0, width: Constants.widthTopRectangle, height: Constants.heightTopRectangle)
        view.roundCorners(corners: .allCorners, radius: Constants.cornerRadiusTopRectangle)
        view.backgroundColor = viewModel.rectangleColor
        return view
    }()

    private lazy var titleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame = CGRect(x: 0, y: 0, width: .greatestFiniteMagnitude, height: Constants.heightTitleView)
        view.backgroundColor = .clear
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = viewModel.titleText
        label.textColor = viewModel.titleLabelAccentColor
        label.font = viewModel.titleLabelFont
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var bankIconImageView: UIImageView = {
        let imageView = UIImageView(image: viewModel.bankImageIcon)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.frame = CGRect(x: 0, y: 0, width: Constants.bankIconSize, height: Constants.bankIconSize)
        imageView.roundCorners(corners: .allCorners, radius: Constants.bankIconCornerRadius)
        imageView.layer.borderWidth = Constants.bankIconBorderWidth
        imageView.layer.borderColor = viewModel.bankIconBorderColor.cgColor
        return imageView
    }()
    
    private lazy var moreInformationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = Constants.viewPaddingConstraint
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    // We need our label into a view for layout purposes. Stackviews require views in order to satisfy all dynamic constraints
    private lazy var moreInformationLabelView: UIView = {
        return UIView()
    }()
    
    private lazy var moreInformationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = viewModel.moreInformationLabelTextColor
        label.font = viewModel.moreInformationLabelFont
        label.numberOfLines = 0
        label.text = viewModel.moreInformationLabelText
        return label
    }()
    
    private lazy var moreInformationButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImageNamedPreferred(named: viewModel.moreInformationIconName)
        button.setImage(image, for: .normal)
        button.tintColor = viewModel.moreInformationAccentColor
        return button
    }()
    
    private lazy var continueButton: PaymentPrimaryButton = {
        let button = PaymentPrimaryButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.frame = CGRect(x: 0, y: 0, width: .greatestFiniteMagnitude, height: Constants.buttonViewHeight)
        button.configure(with: viewModel.giniHealthConfiguration.primaryButtonConfiguration)
        button.customConfigure(paymentProviderColors: viewModel.paymentProviderColors,
                               text: viewModel.continueLabelText)
        return button
    }()
    
    private lazy var appStoreImageView: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.frame = CGRect(x: 0, y: 0, width: .greatestFiniteMagnitude, height: Constants.appStoreImageViewHeight)
        let image = UIImageNamedPreferred(named: viewModel.appStoreImageIconName)
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(tapOnAppStoreButton), for: .touchUpInside)
        return button
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
        setupViewHierarchy()
        setupViewAttributes()
        setupLayout()
        setupListeners()
        setButtonsState()
    }

    private func setupViewHierarchy() {
        self.addSubview(rectangleTopView)
        self.addSubview(titleView)
        titleView.addSubview(titleLabel)
        self.addSubview(bankIconImageView)
        moreInformationLabelView.addSubview(moreInformationLabel)
        moreInformationStackView.addArrangedSubview(moreInformationButton)
        moreInformationStackView.addArrangedSubview(moreInformationLabelView)
        self.addSubview(moreInformationStackView)
        self.addSubview(continueButton)
        self.addSubview(poweredByGiniView)
        self.addSubview(appStoreImageView)
    }

    private func setupViewAttributes() {
        self.backgroundColor = viewModel.backgroundColor
        self.roundCorners(corners: [.topLeft, .topRight], radius: Constants.cornerRadiusView)
    }

    private func setupLayout() {
        setupTopRectangleConstraints()
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
    
    @objc private func willEnterForeground() {
        setButtonsState()
    }
    
    private func setButtonsState() {
        appStoreImageView.isHidden = viewModel.isBankInstalled
        continueButton.isHidden = !viewModel.isBankInstalled
        moreInformationLabel.text = viewModel.moreInformationLabelText
        
        continueButton.didTapButton = { [weak self] in
            self?.tapOnContinueButton()
        }
    }

    private func setupTopRectangleConstraints() {
        NSLayoutConstraint.activate([
            rectangleTopView.heightAnchor.constraint(equalToConstant: rectangleTopView.frame.height),
            rectangleTopView.widthAnchor.constraint(equalToConstant: rectangleTopView.frame.width),
            rectangleTopView.topAnchor.constraint(equalTo: self.topAnchor, constant: Constants.topAnchorTopRectangle),
            rectangleTopView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    }

    private func setupTitleViewConstraints() {
        NSLayoutConstraint.activate([
            titleView.heightAnchor.constraint(equalToConstant: titleView.frame.height),
            titleView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.viewPaddingConstraint),
            self.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: Constants.viewPaddingConstraint),
            titleView.topAnchor.constraint(equalTo: self.topAnchor, constant: Constants.topAnchorTitleView),
            titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor)
        ])
    }

    private func setupBankImageConstraints() {
        NSLayoutConstraint.activate([
            bankIconImageView.heightAnchor.constraint(equalToConstant: bankIconImageView.frame.height),
            bankIconImageView.widthAnchor.constraint(equalToConstant: bankIconImageView.frame.width),
            bankIconImageView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: Constants.topAnchorBankImage),
            bankIconImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    }
    
    private func setupMoreInformationConstraints() {
        NSLayoutConstraint.activate([
            moreInformationStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.viewPaddingConstraint),
            moreInformationStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.viewPaddingConstraint),
            moreInformationStackView.topAnchor.constraint(equalTo: bankIconImageView.bottomAnchor, constant: Constants.viewPaddingConstraint),
            moreInformationLabel.leadingAnchor.constraint(equalTo: moreInformationLabelView.leadingAnchor),
            moreInformationLabel.trailingAnchor.constraint(equalTo: moreInformationLabelView.trailingAnchor),
            moreInformationLabel.centerYAnchor.constraint(equalTo: moreInformationLabelView.centerYAnchor)
        ])
    }
    
    private func setupContinueButtonConstraints() {
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.viewPaddingConstraint),
            continueButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.viewPaddingConstraint),
            continueButton.heightAnchor.constraint(equalToConstant: continueButton.frame.height),
            continueButton.topAnchor.constraint(equalTo: moreInformationStackView.bottomAnchor, constant: Constants.continueButtonTopAnchor)
        ])
    }
    
    private func setupAppStoreButtonConstraints() {
        NSLayoutConstraint.activate([
            appStoreImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.viewPaddingConstraint),
            appStoreImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.viewPaddingConstraint),
            appStoreImageView.heightAnchor.constraint(equalToConstant: appStoreImageView.frame.height),
            appStoreImageView.topAnchor.constraint(equalTo: moreInformationStackView.bottomAnchor, constant: Constants.continueButtonTopAnchor),
            appStoreImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    }

    private func setupPoweredByGiniConstraints() {
        let poweredByGiniBottomAnchorConstraint = poweredByGiniView.bottomAnchor.constraint(equalTo: poweredByGiniView.bottomAnchor, constant: Constants.viewPaddingConstraint)
        poweredByGiniBottomAnchorConstraint.priority = .required - 1
        NSLayoutConstraint.activate([
            poweredByGiniView.topAnchor.constraint(equalTo: continueButton.bottomAnchor, constant: Constants.viewPaddingConstraint),
            poweredByGiniView.heightAnchor.constraint(equalToConstant: poweredByGiniView.frame.height),
            poweredByGiniView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.viewPaddingConstraint),
            poweredByGiniBottomAnchorConstraint
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
}

extension InstallAppBottomView {
    enum Constants {
        static let cornerRadiusView = 12.0
        static let cornerRadiusTopRectangle = 2.0
        static let widthTopRectangle = 48
        static let heightTopRectangle = 4
        static let topAnchorTopRectangle = 16.0
        static let heightTitleView = 48.0
        static let viewPaddingConstraint = 16.0
        static let topAnchorTitleView = 32.0
        static let bankIconSize = 36
        static let titleViewTitleIconSpacing = 10.0
        static let bankIconCornerRadius = 6.0
        static let bankIconBorderWidth = 1.0
        static let topAnchorBankImage = 10.0
        static let buttonViewHeight: CGFloat = 56
        static let continueButtonTopAnchor = 24.0
        static let appStoreImageViewHeight = 44.0
    }
}
