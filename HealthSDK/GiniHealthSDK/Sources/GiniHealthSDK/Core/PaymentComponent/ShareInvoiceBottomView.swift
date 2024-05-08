//
//  ShareInvoiceBottomView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

class ShareInvoiceBottomView: BottomSheetViewController {

    var viewModel: ShareInvoiceBottomViewModel
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    }()

    private lazy var titleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
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
    
    private lazy var descriptionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = viewModel.descriptionLabelText
        label.textColor = viewModel.descriptionAccentColor
        label.font = viewModel.descriptionLabelFont
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var appsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = viewModel.appsBackgroundColor
        return view
    }()
    
    private lazy var appsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = Constants.appsViewSpacing
        return stackView
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
    
    private lazy var tipView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var tipStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = Constants.viewPaddingConstraint
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    private lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = viewModel.tipAccentColor
        label.font = viewModel.tipLabelFont
        label.numberOfLines = 0
        label.text = viewModel.tipLabelText
        
        let tipActionableAttributtedString = NSMutableAttributedString(string: viewModel.tipLabelText)
        let tipPartString = (viewModel.tipLabelText as NSString).range(of: viewModel.tipActionablePartText)
        tipActionableAttributtedString.addAttribute(.foregroundColor,
                                                                value: viewModel.tipAccentColor,
                                                                range: tipPartString)
        tipActionableAttributtedString.addAttribute(NSAttributedString.Key.underlineStyle,
                                                                value: NSUnderlineStyle.single.rawValue,
                                                                range: tipPartString)
        tipActionableAttributtedString.addAttribute(NSAttributedString.Key.font,
                                                                value: viewModel.tipLabelLinkFont,
                                                                range: tipPartString)
        let tapOnMoreInformation = UITapGestureRecognizer(target: self,
                                                          action: #selector(tapOnLabelAction(gesture:)))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tapOnMoreInformation)
        label.attributedText = tipActionableAttributtedString
        return label
    }()
    
    private lazy var tipButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImageNamedPreferred(named: viewModel.tipIconName)
        button.setImage(image, for: .normal)
        button.tintColor = viewModel.tipAccentColor
        button.isUserInteractionEnabled = false
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    private lazy var continueView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var continueButton: PaymentPrimaryButton = {
        let button = PaymentPrimaryButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configure(with: viewModel.giniHealthConfiguration.primaryButtonConfiguration)
        button.customConfigure(paymentProviderColors: viewModel.paymentProviderColors,
                               text: viewModel.continueLabelText)
        return button
    }()

    private lazy var bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var bottomStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        return stackView
    }()
    
    private lazy var poweredByGiniView: PoweredByGiniView = {
        let view = PoweredByGiniView()
        view.viewModel = PoweredByGiniViewModel()
        return view
    }()
    
    override var minHeight: CGFloat {
        get {
            return 0
        }
        set {
            super.minHeight = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    init(viewModel: ShareInvoiceBottomViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
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
        titleView.addSubview(titleLabel)
        contentStackView.addArrangedSubview(titleView)
        descriptionView.addSubview(descriptionLabel)
        contentStackView.addArrangedSubview(descriptionView)
        generateAppViews().forEach { appView in
            appsStackView.addArrangedSubview(appView)
        }
        appsView.addSubview(appsStackView)
        contentStackView.addArrangedSubview(appsView)
        tipStackView.addArrangedSubview(tipButton)
        tipStackView.addArrangedSubview(tipLabel)
        tipView.addSubview(tipStackView)
        contentStackView.addArrangedSubview(tipView)
        continueView.addSubview(continueButton)
        contentStackView.addArrangedSubview(continueView)
        bottomStackView.addArrangedSubview(UIView())
        bottomStackView.addArrangedSubview(poweredByGiniView)
        bottomView.addSubview(bottomStackView)
        contentStackView.addArrangedSubview(bottomView)
        self.setContent(content: contentStackView)
    }

    private func setupLayout() {
        setupTitleViewConstraints()
        setupDescriptionViewConstraints()
        setupAppsView()
        setupTipViewConstraints()
        setupContinueButtonConstraints()
        setupPoweredByGiniConstraints()
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
    
    private func setupDescriptionViewConstraints() {
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: descriptionView.leadingAnchor, constant: Constants.viewPaddingConstraint),
            descriptionLabel.trailingAnchor.constraint(equalTo: descriptionView.trailingAnchor, constant: -Constants.viewPaddingConstraint),
            descriptionLabel.topAnchor.constraint(equalTo: descriptionView.topAnchor, constant: Constants.topBottomPaddingConstraint),
            descriptionLabel.bottomAnchor.constraint(equalTo: descriptionView.bottomAnchor, constant: -Constants.bottomDescriptionConstraint)
        ])
    }
    
    private func setupAppsView() {
        NSLayoutConstraint.activate([
            appsView.heightAnchor.constraint(equalToConstant: Constants.appsViewHeight),
            appsStackView.leadingAnchor.constraint(equalTo: appsView.leadingAnchor, constant: Constants.viewPaddingConstraint),
            appsStackView.topAnchor.constraint(equalTo: appsView.topAnchor, constant: Constants.topAnchorAppsViewConstraint),
            appsStackView.bottomAnchor.constraint(equalTo: appsView.bottomAnchor, constant: -Constants.viewPaddingConstraint),
            appsStackView.trailingAnchor.constraint(equalTo: appsView.trailingAnchor, constant: Constants.trailingAppsViewConstraint)
        ])
    }
    
    private func setupTipViewConstraints() {
        NSLayoutConstraint.activate([
            tipStackView.leadingAnchor.constraint(equalTo: tipView.leadingAnchor, constant: Constants.viewPaddingConstraint),
            tipStackView.trailingAnchor.constraint(equalTo: tipView.trailingAnchor, constant: -Constants.viewPaddingConstraint),
            tipStackView.topAnchor.constraint(equalTo: tipView.topAnchor, constant: Constants.topAnchorTipViewConstraint),
            tipStackView.bottomAnchor.constraint(equalTo: tipView.bottomAnchor, constant: -Constants.topBottomPaddingConstraint),
            tipButton.widthAnchor.constraint(equalToConstant: Constants.tipIconSize)
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
            bottomStackView.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: Constants.viewPaddingConstraint),
            bottomStackView.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -Constants.viewPaddingConstraint),
            bottomStackView.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: Constants.topAnchorPoweredByGiniConstraint),
            bottomStackView.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor)
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
    
    @objc
    private func tapOnLabelAction(gesture: UITapGestureRecognizer) {
        if gesture.didTapAttributedTextInLabel(label: tipLabel,
                                               targetText: viewModel.tipActionablePartText) {

            tapOnAppStoreButton()
        }
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
    
    private func generateAppViews() -> [SingleAppView] {
        var viewsToReturn: [SingleAppView] = []
        viewModel.appsMocked.forEach { singleApp in
            let view = SingleAppView()
            view.configure(image: singleApp.image, title: singleApp.title)
            viewsToReturn.append(view)
        }
        return viewsToReturn
    }
}

extension ShareInvoiceBottomView {
    enum Constants {
        static let viewPaddingConstraint = 16.0
        static let topBottomPaddingConstraint = 10.0
        static let bottomDescriptionConstraint = 20.0
        static let bankIconSize = 36
        static let bankIconCornerRadius = 6.0
        static let bankIconBorderWidth = 1.0
        static let continueButtonViewHeight = 56.0
        static let appsViewSpacing: CGFloat = 4.0
        static let appsViewHeight: CGFloat = 112.0
        static let topAnchorAppsViewConstraint = 20.0
        static let trailingAppsViewConstraint = 50.0
        static let topAnchorTipViewConstraint = 5.0
        static let topAnchorPoweredByGiniConstraint = 5.0
        static let tipIconSize = 24.0
    }
}

class SingleAppView: UIView {
    // Subviews
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = GiniColor(lightModeColor: .white,
                                              darkModeColor: UIColor.GiniHealthColors.light3).uiColor()
        imageView.contentMode = .scaleAspectFit
        imageView.roundCorners(corners: .allCorners, radius: Constants.imageViewCornerRardius)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark3,
                                    darkModeColor: UIColor.GiniHealthColors.light3).uiColor()
        label.font = GiniHealthConfiguration.shared.textStyleFonts[.caption2] ?? UIFont.systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    // Setup views and constraints
    private func setupViews() {
        addSubview(imageView)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.heightAnchor.constraint(equalToConstant: Constants.imageViewHeight),
            imageView.widthAnchor.constraint(equalToConstant: Constants.imageViewHeight),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.topAnchorTitleLabelConstraint),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // Function to configure view
    func configure(image: UIImage?, title: String?) {
        imageView.image = image
        titleLabel.text = title
    }
}

extension SingleAppView {
    enum Constants {
        static let imageViewHeight = 36.0
        static let topAnchorTitleLabelConstraint = 8.0
        static let imageViewCornerRardius = 6.0
    }
}
