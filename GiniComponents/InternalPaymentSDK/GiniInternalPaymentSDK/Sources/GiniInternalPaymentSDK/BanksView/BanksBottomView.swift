//
//  PaymentProvidersBottomView.swift
//  GiniInternalPaymentSDK
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

    private let titleView = EmptyView()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = viewModel.strings.selectBankTitleText
        label.textColor = viewModel.configuration.selectBankAccentColor
        // Font size is capped at accessibility sizes to prevent clipping. Remove when HEAL-414 migrates this screen to a fully scrollable layout.
        label.font = viewModel.configuration.selectBankFont.limitingFontSize(to: Constants.titleMaxFontSize)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionView = EmptyView()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = viewModel.strings.descriptionText
        label.textColor = viewModel.configuration.descriptionAccentColor
        // Font size is capped at accessibility sizes to prevent clipping. Remove when HEAL-414 migrates this screen to a fully scrollable layout.
        label.font = viewModel.configuration.descriptionFont.limitingFontSize(to: Constants.descriptionMaxFontSize)
        label.adjustsFontForContentSizeCategory = true
        label.setContentCompressionResistancePriority(.required, for: .vertical)
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
        tableView.estimatedRowHeight = UITableView.automaticDimension
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
        false
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupInitialLayout()
        setupContentSizeCategoryObserver()
    }

    public init(viewModel: BanksBottomViewModel, bottomSheetConfiguration: BottomSheetConfiguration) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = bottomSheetConfiguration.backgroundColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIContentSizeCategory.didChangeNotification,
                                                  object: nil)
    }

    private func setupInitialLayout() {
        updateLayoutForCurrentOrientation(screenSize: UIScreen.main.bounds.size)
    }

    // Portrait Layout Constraints
    private func setupPortraitConstraints() {
        deactivateAllConstraints()
        let heightConstraint = paymentProvidersTableView.heightAnchor.constraint(greaterThanOrEqualToConstant: viewModel.heightTableView)
        heightConstraint.priority = .defaultHigh
        portraitConstraints = [
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            heightConstraint
        ]
        NSLayoutConstraint.activate(portraitConstraints)
    }

    // Landscape Layout Constraints
    private func setupLandscapeConstraints(screenWidth: CGFloat) {
        deactivateAllConstraints()
        let landscapePadding: CGFloat = (Constants.landscapePaddingRatio * screenWidth)
        let heightConstraint = paymentProvidersTableView.heightAnchor.constraint(greaterThanOrEqualToConstant: viewModel.heightTableView)
        heightConstraint.priority = .defaultHigh
        landscapeConstraints = [
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: landscapePadding),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -landscapePadding),
            heightConstraint
        ]
        NSLayoutConstraint.activate(landscapeConstraints)
    }
    
    private func deactivateAllConstraints() {
        NSLayoutConstraint.deactivate(portraitConstraints + landscapeConstraints)
    }

    private func setupView() {
        // Use .large() detent so the sheet fills the screen and automatically
        configureBottomSheet(shouldIncludeLargeDetent: true)
        setupViewHierarchy()
        setupViewAttributes()
        setupLayout()
        updateBottomStackOrientation()
    }

    private func setupViewHierarchy() {
        titleView.addSubview(titleLabel)
        contentStackView.addArrangedSubview(titleView)
        descriptionView.addSubview(descriptionLabel)
        contentStackView.addArrangedSubview(descriptionView)
        paymentProvidersView.addSubview(paymentProvidersTableView)
        contentStackView.addArrangedSubview(paymentProvidersView)
        bottomStackView.addArrangedSubview(moreInformationView)
        if viewModel.shouldShowBrandedView {
            bottomStackView.addArrangedSubview(poweredByGiniView)
        }
        bottomView.addSubview(bottomStackView)
        contentStackView.addArrangedSubview(bottomView)
        contentView.addSubview(contentStackView)
        view.addSubview(contentView)

        // Title, description, and bottom bar hug their content tightly.
        // The bank list (paymentProvidersView) absorbs all remaining vertical space.
        titleView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        descriptionView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        bottomView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        paymentProvidersView.setContentHuggingPriority(.defaultLow, for: .vertical)
    }

    private func setupViewAttributes() {
        // Scrolling is always enabled; Auto Layout constrains the visible height.
        // A fixed cell-height calculation previously gated this, which under-estimated
        // actual heights at large Dynamic Type sizes.
        paymentProvidersTableView.isScrollEnabled = true
    }

    private func setupLayout() {
        setupContentViewConstraints()
        setupContentStackViewConstraints()
        setupTitleViewConstraints()
        setupDescriptionConstraints()
        setupTableViewConstraints()
        setupPoweredByGiniConstraints()
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
            titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor,
                                                constant: Constants.viewPaddingConstraint),
            titleLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor,
                                                 constant: -Constants.viewPaddingConstraint),
            titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor, constant: Constants.descriptionTopPadding),
            titleLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor, constant: -Constants.descriptionTopPadding),
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
            bottomStackView.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor)
        ])
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
        let isPortrait = UIDevice.isPortrait()
        let isAccessibilitySize = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        // In landscape with an accessibility font size 200%, the description label is hidden
        // to prevent it consuming the limited vertical space above the bank list.
        descriptionView.isHidden = !isPortrait && isAccessibilitySize
        if isPortrait {
            setupPortraitConstraints()
        } else {
            setupLandscapeConstraints(screenWidth: screenSize.width)
        }
    }

    private func setupContentSizeCategoryObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contentSizeCategoryDidChange),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
    }

    @objc private func contentSizeCategoryDidChange() {
        viewModel.calculateHeights()
        updateLayoutForCurrentOrientation(screenSize: view.bounds.size)
        paymentProvidersTableView.reloadData()
        updateBottomStackOrientation()
        view.layoutIfNeeded()
    }

    private func updateBottomStackOrientation() {
        /// Axis change only applies when the branded logo is present; with a single item the axis has no effect.
        guard viewModel.shouldShowBrandedView else { return }
        let isAccessibilitySize = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        bottomStackView.axis = isAccessibilitySize ? .vertical : .horizontal
        poweredByGiniView.configureForVerticalLayout(isAccessibilitySize)
    }
}

extension BanksBottomView {
    enum Constants {
        static let descriptionTopPadding = 4.0
        static let viewPaddingConstraint = 16.0
        static let topAnchorTitleView = 32.0
        static let titleViewTitleIconSpacing = 10.0
        static let topAnchorPoweredByGiniConstraint = 5.0
        static let landscapePaddingRatio = 0.15
        static let titleMaxFontSize = 22.0
        static let descriptionMaxFontSize = 20.0
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
        dismiss(animated: true) {
            NotificationCenter.default.post(name: GiniOverlayWindowPresenter.NotificationName.dismissOverlay,
                                            object: nil)
        }
    }
}
