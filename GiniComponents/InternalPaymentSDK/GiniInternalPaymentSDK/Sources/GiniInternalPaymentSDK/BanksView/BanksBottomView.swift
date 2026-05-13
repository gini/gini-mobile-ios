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

    private let titleView = EmptyView()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = viewModel.strings.selectBankTitleText
        label.textColor = viewModel.configuration.selectBankAccentColor
        label.font = UIFontMetrics.default.scaledFont(for: viewModel.configuration.selectBankFont)
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
        label.font = UIFontMetrics.default.scaledFont(for: viewModel.configuration.descriptionFont)
        label.adjustsFontForContentSizeCategory = true
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
        false
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupInitialLayout()
        setupContentSizeCategoryObserver()
        updateAccessibilityLayout()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sizeTableHeaderView()
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
        heightConstraint.priority = .defaultHigh  // Lower priority so it can be broken if needed
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
        heightConstraint.priority = .defaultHigh  // Lower priority so it can be broken if needed
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
        configureBottomSheet()
        updateBottomSheetHeight(Constants.bottomSheetHeight(view.bounds.height))
        setupViewHierarchy()
        setupViewAttributes()
        setupLayout()
    }

    private func setupViewHierarchy() {
        titleView.addSubview(titleLabel)
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
        /// Scrolling is always enabled; Auto Layout constrains the visible height.
        /// A fixed cell-height calculation previously gated this, which under-estimated
        /// actual heights at large Dynamic Type sizes.
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
            bottomStackView.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor),
            bottomStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.bottomViewHeight)
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
            self.sizeTableHeaderView()
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

    private func setupContentSizeCategoryObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contentSizeCategoryDidChange),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
    }

    @objc private func contentSizeCategoryDidChange() {
        viewModel.calculateHeights()
        updateAccessibilityLayout()
        updateLayoutForCurrentOrientation(screenSize: view.bounds.size)
        paymentProvidersTableView.reloadData()
        sizeTableHeaderView()
        view.layoutIfNeeded()
    }

    /**
     Switches between two layout modes based on the active Dynamic Type size.

     At accessibility sizes (AX1–AX5), the title and description are moved into the table view's
     `tableHeaderView` so the entire content scrolls as a single surface.
     At standard sizes they remain in the stack view above the table.
     */
    private func updateAccessibilityLayout() {
        let isAccessibility = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        titleView.isHidden = isAccessibility
        descriptionView.isHidden = isAccessibility

        if isAccessibility {
            if paymentProvidersTableView.tableHeaderView == nil {
                paymentProvidersTableView.tableHeaderView = makeTableAccessibilityHeader()
            }
        } else {
            paymentProvidersTableView.tableHeaderView = nil
        }
    }

    /**
     Builds a header view containing title and description labels for use as `tableHeaderView`
     at accessibility font sizes.
     */
    private func makeTableAccessibilityHeader() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let titleLbl = UILabel()
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        titleLbl.text = viewModel.strings.selectBankTitleText
        titleLbl.textColor = viewModel.configuration.selectBankAccentColor
        titleLbl.font = UIFontMetrics.default.scaledFont(for: viewModel.configuration.selectBankFont)
        titleLbl.adjustsFontForContentSizeCategory = true
        titleLbl.numberOfLines = 0

        let descLbl = UILabel()
        descLbl.translatesAutoresizingMaskIntoConstraints = false
        descLbl.text = viewModel.strings.descriptionText
        descLbl.textColor = viewModel.configuration.descriptionAccentColor
        descLbl.font = UIFontMetrics.default.scaledFont(for: viewModel.configuration.descriptionFont)
        descLbl.adjustsFontForContentSizeCategory = true
        descLbl.numberOfLines = 0

        container.addSubview(titleLbl)
        container.addSubview(descLbl)

        NSLayoutConstraint.activate([
            titleLbl.topAnchor.constraint(equalTo: container.topAnchor,
                                          constant: Constants.descriptionTopPadding),
            titleLbl.leadingAnchor.constraint(equalTo: container.leadingAnchor,
                                              constant: Constants.viewPaddingConstraint),
            titleLbl.trailingAnchor.constraint(equalTo: container.trailingAnchor,
                                               constant: -Constants.viewPaddingConstraint),

            descLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor,
                                         constant: Constants.descriptionTopPadding),
            descLbl.leadingAnchor.constraint(equalTo: container.leadingAnchor,
                                             constant: Constants.viewPaddingConstraint),
            descLbl.trailingAnchor.constraint(equalTo: container.trailingAnchor,
                                              constant: -Constants.viewPaddingConstraint),
            descLbl.bottomAnchor.constraint(equalTo: container.bottomAnchor,
                                            constant: -Constants.viewPaddingConstraint)
        ])

        return container
    }

    /**
     Re-measures and applies the correct height to the table header view.

     `UITableView` does not automatically resize its `tableHeaderView` when using Auto Layout;
     this must be triggered manually after layout passes.
     */
    private func sizeTableHeaderView() {
        guard let headerView = paymentProvidersTableView.tableHeaderView,
              paymentProvidersTableView.bounds.width > 0 else { return }
        let targetSize = CGSize(width: paymentProvidersTableView.bounds.width,
                                height: UIView.layoutFittingCompressedSize.height)
        let height = headerView.systemLayoutSizeFitting(targetSize,
                                                        withHorizontalFittingPriority: .required,
                                                        verticalFittingPriority: .fittingSizeLevel).height
        var frame = headerView.frame
        if frame.size.height != height {
            frame.size.height = height
            headerView.frame = frame
            paymentProvidersTableView.tableHeaderView = headerView
        }
    }
}

extension BanksBottomView {
    enum Constants {
        static let descriptionTopPadding = 4.0
        static let viewPaddingConstraint = 16.0
        static let topAnchorTitleView = 32.0
        static let titleViewTitleIconSpacing = 10.0
        static let topAnchorPoweredByGiniConstraint = 5.0
        static let bottomViewHeight = 44.0
        static let landscapePaddingRatio = 0.15
        static let bottomSheetHeight: (CGFloat) -> CGFloat = { screenHeight in screenHeight * 0.9 }
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
