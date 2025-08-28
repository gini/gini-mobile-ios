//
//  PaymentProvidersBottomView.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniUtilites

public final class BanksBottomView: GiniBottomSheetViewController {

    var viewModel: BanksBottomViewModel

    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []

    private let contentView = EmptyView()
    private let contentStackView = EmptyStackView().orientation(.vertical)
    
    private lazy var closeButtonContainerView: EmptyView = {
        let view = EmptyView()
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(viewModel.configuration.closeTitleIcon.withRenderingMode(.alwaysTemplate),
                        for: .normal)
        button.addTarget(self, action: #selector(tapOnCloseIcon), for: .touchUpInside)
        button.tintColor = viewModel.configuration.closeIconAccentColor
        button.accessibilityLabel = viewModel.strings.closeButtonAccessibilityLabel
        return button
    }()

    private lazy var titleView: UIView = {
        let view = EmptyView()
        view.frame = CGRect(x: 0, y: 0, width: .greatestFiniteMagnitude, height: Constants.heightTitleView)
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = viewModel.strings.selectBankTitleText
        label.textColor = viewModel.configuration.selectBankAccentColor
        label.font = viewModel.configuration.selectBankFont
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private lazy var closeTitleIconImageView: UIImageView = {
        let imageView = UIImageView(image: viewModel.configuration.closeTitleIcon.withRenderingMode(.alwaysTemplate))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = viewModel.configuration.closeIconAccentColor
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapOnCloseIcon)))
        imageView.isHidden = true
        return imageView
    }()
    
    private let descriptionView = EmptyView()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = viewModel.strings.descriptionText
        label.textColor = viewModel.configuration.descriptionAccentColor
        label.font = viewModel.configuration.descriptionFont
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        return label
    }()
    
    private let paymentProvidersView = EmptyView()

    private lazy var paymentProvidersTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellType: BankSelectionTableViewCell.self)
        tableView.estimatedRowHeight = viewModel.rowHeight
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    private let bottomView = EmptyView()
    
    private let bottomStackView = EmptyStackView().orientation(.horizontal)
    
    private lazy var moreInformationView: MoreInformationView = {
        let viewModel = viewModel.moreInformationViewModel
        viewModel.delegate = self
        return MoreInformationView(viewModel: viewModel)
    }()

    private lazy var poweredByGiniView: PoweredByGiniView = {
        PoweredByGiniView(viewModel: viewModel.poweredByGiniViewModel)
    }()
    
    public var shouldShowDragIndicator: Bool {
        true
    }
    
    public var shouldShowInFullScreenInLandscapeMode: Bool {
        true
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Detect the initial orientation and set up the appropriate constraints
        setupInitialLayout()
    }

    public init(viewModel: BanksBottomViewModel, bottomSheetConfiguration: BottomSheetConfiguration) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = bottomSheetConfiguration.backgroundColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupInitialLayout() {
        updateLayoutForCurrentOrientation(screenSize: UIScreen.main.bounds.size)
    }

    // Portrait Layout Constraints
    private func setupPortraitConstraints() {
        closeButtonContainerView.isHidden = true
        deactivateAllConstraints()
        portraitConstraints = [
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            paymentProvidersTableView.heightAnchor.constraint(greaterThanOrEqualToConstant: viewModel.heightTableView)
        ]
        NSLayoutConstraint.activate(portraitConstraints)
    }

    // Landscape Layout Constraints
    private func setupLandscapeConstraints(screenWidth: CGFloat) {
        closeButtonContainerView.isHidden = false
        deactivateAllConstraints()
        let landscapePadding: CGFloat = (Constants.landscapePaddingRatio * screenWidth)
        landscapeConstraints = [
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: landscapePadding),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -landscapePadding),
            paymentProvidersTableView.heightAnchor.constraint(greaterThanOrEqualToConstant: viewModel.heightTableView)
        ]
        NSLayoutConstraint.activate(landscapeConstraints)
    }
    
    private func deactivateAllConstraints() {
        NSLayoutConstraint.deactivate(portraitConstraints + landscapeConstraints)
    }

    private func setupView() {
        configureBottomSheet(shouldIncludeLargeDetent: true)
        setupViewHierarchy()
        setupViewAttributes()
        setupLayout()
    }

    private func setupViewHierarchy() {
        addCloseButton()
        titleView.addSubview(titleLabel)
        titleView.addSubview(closeTitleIconImageView)
        contentStackView.addArrangedSubview(titleView)
        descriptionView.addSubview(descriptionLabel)
        contentStackView.addArrangedSubview(descriptionView)
        paymentProvidersView.addSubview(paymentProvidersTableView)
        contentStackView.addArrangedSubview(paymentProvidersView)
        bottomStackView.addArrangedSubview(moreInformationView)
        bottomStackView.addArrangedSubview(UIView())
        if viewModel.shouldShowBrandedView {
            bottomStackView.addArrangedSubview(poweredByGiniView)
        }
        bottomView.addSubview(bottomStackView)
        contentStackView.addArrangedSubview(bottomView)
        contentView.addSubview(contentStackView)
        view.addSubview(contentView)
    }

    private func setupViewAttributes() {
        let isFullScreen = viewModel.bottomViewHeight >= viewModel.maximumViewHeight
        paymentProvidersTableView.isScrollEnabled = isFullScreen
    }

    private func setupLayout() {
        setupContentViewConstraints()
        setupContentStackViewConstraints()
        setupTitleViewConstraints()
        setupDescriptionConstraints()
        setupTableViewConstraints()
        setupPoweredByGiniConstraints()
    }
    
    private func addCloseButton() {
        closeButtonContainerView.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: Constants.closeIconSize),
            closeButton.heightAnchor.constraint(equalToConstant: Constants.closeIconSize),
            closeButton.topAnchor.constraint(equalTo: closeButtonContainerView.topAnchor),
            closeButton.bottomAnchor.constraint(equalTo: closeButtonContainerView.bottomAnchor),
            closeButton.trailingAnchor.constraint(equalTo: closeButtonContainerView.trailingAnchor,
                                                 constant: -Constants.viewPaddingConstraint),
        ])
        
        contentStackView.addArrangedSubview(closeButtonContainerView)
    }
    
    private func setupContentViewConstraints() {
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                constant: -Constants.viewPaddingConstraint),
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                             constant: Constants.viewPaddingConstraint)
        ])
    }

    private func setupContentStackViewConstraints() {
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    private func setupTitleViewConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: Constants.viewPaddingConstraint),
            titleLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
            titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor, constant: Constants.descriptionTopPadding),
            titleLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor, constant: -Constants.descriptionTopPadding),
            closeTitleIconImageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeTitleIconImageView.heightAnchor.constraint(equalToConstant: Constants.closeIconSize),
            closeTitleIconImageView.widthAnchor.constraint(equalToConstant: Constants.closeIconSize),
            closeTitleIconImageView.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -Constants.viewPaddingConstraint),
            closeTitleIconImageView.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: Constants.titleViewTitleIconSpacing)
        ])
    }

    private func setupDescriptionConstraints() {
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: descriptionView.topAnchor, constant: Constants.descriptionTopPadding),
            descriptionLabel.leadingAnchor.constraint(equalTo: descriptionView.leadingAnchor, constant: Constants.viewPaddingConstraint),
            descriptionLabel.trailingAnchor.constraint(equalTo: descriptionView.trailingAnchor, constant: -Constants.viewPaddingConstraint),
            descriptionLabel.bottomAnchor.constraint(equalTo: descriptionView.bottomAnchor, constant: -Constants.viewPaddingConstraint)
        ])
    }

    private func setupTableViewConstraints() {
        NSLayoutConstraint.activate([
            paymentProvidersTableView.topAnchor.constraint(equalTo: paymentProvidersView.topAnchor),
            paymentProvidersTableView.leadingAnchor.constraint(equalTo: paymentProvidersView.leadingAnchor, constant: Constants.viewPaddingConstraint),
            paymentProvidersTableView.trailingAnchor.constraint(equalTo: paymentProvidersView.trailingAnchor, constant: -Constants.viewPaddingConstraint),
            paymentProvidersTableView.bottomAnchor.constraint(equalTo: paymentProvidersView.bottomAnchor)
        ])
    }

    private func setupPoweredByGiniConstraints() {
        NSLayoutConstraint.activate([
            bottomStackView.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: Constants.viewPaddingConstraint),
            bottomStackView.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -Constants.viewPaddingConstraint),
            bottomStackView.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: Constants.topAnchorPoweredByGiniConstraint),
            bottomStackView.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor),
            bottomStackView.heightAnchor.constraint(equalToConstant: Constants.bottomViewHeight)
        ])
    }
    
    @objc
    private func tapOnCloseIcon() {
        viewModel.didTapOnClose()
        dismiss(animated: true)
    }

    // Handle orientation change
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        // Perform layout updates with animation
        coordinator.animate(alongsideTransition: { context in
            self.viewModel.calculateHeights()
            self.updateLayoutForCurrentOrientation(screenSize: size)
            self.setupTableViewConstraints()
            self.setupPoweredByGiniConstraints()
            self.setupViewAttributes()
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    private func updateLayoutForCurrentOrientation(screenSize: CGSize) {
        if UIDevice.isPortrait() {
            setupPortraitConstraints()
        } else {
            setupLandscapeConstraints(screenWidth: screenSize.width)
        }
    }
}

extension BanksBottomView {
    enum Constants {
        static let heightTitleView = 49.0
        static let descriptionTopPadding = 4.0
        static let viewPaddingConstraint = 16.0
        static let topAnchorTitleView = 32.0
        static let closeIconSize = 24.0
        static let titleViewTitleIconSpacing = 10.0
        static let topAnchorPoweredByGiniConstraint = 5.0
        static let bottomViewHeight = 44.0
        static let landscapePaddingRatio = 0.15
    }
}

extension BanksBottomView: MoreInformationViewProtocol {
    public func didTapOnMoreInformation() {
        let paymentInfoViewController = PaymentInfoViewController(viewModel: viewModel.paymentInfoViewModel)
        let navigationController = UINavigationController(rootViewController: paymentInfoViewController)
        
        present(navigationController, animated: true)
    }
}

extension BanksBottomView: UITableViewDataSource, UITableViewDelegate {
    /// We indicate the number of rows we show in bank selection view
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.paymentProviders.count
    }

    /// We create the bank selection cell
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BankSelectionTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        let invoiceTableViewCellModel = viewModel.paymentProvidersViewModel(paymentProvider: viewModel.paymentProviders[indexPath.row])
        cell.cellViewModel = invoiceTableViewCellModel
        return cell
    }
    
    /// BanksBottomView event when a bank is selected from the list
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.viewDelegate?.didSelectPaymentProvider(paymentProvider: viewModel.paymentProviders[indexPath.row].paymentProvider)
        dismiss(animated: true)
    }
}
