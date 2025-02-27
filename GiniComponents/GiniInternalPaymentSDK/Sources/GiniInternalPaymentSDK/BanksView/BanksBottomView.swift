//
//  PaymentProvidersBottomView.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniUtilites

public final class BanksBottomView: BottomSheetViewController {

    var viewModel: BanksBottomViewModel
    
    private let contentStackView = EmptyStackView().orientation(.vertical)

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
        tableView.rowHeight = viewModel.rowHeight
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
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    public init(viewModel: BanksBottomViewModel, bottomSheetConfiguration: BottomSheetConfiguration) {
        self.viewModel = viewModel
        super.init(configuration: bottomSheetConfiguration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        setupViewHierarchy()
        setupViewAttributes()
        setupLayout()
    }

    private func setupViewHierarchy() {
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
        self.setContent(content: contentStackView)
    }

    private func setupViewAttributes() {
        let isFullScreen = viewModel.bottomViewHeight >= viewModel.maximumViewHeight
        paymentProvidersTableView.isScrollEnabled = isFullScreen
    }

    private func setupLayout() {
        setupTitleViewConstraints()
        setupDescriptionConstraints()
        setupTableViewConstraints()
        setupPoweredByGiniConstraints()
    }

    private func setupTitleViewConstraints() {
        NSLayoutConstraint.activate([
            titleView.heightAnchor.constraint(equalToConstant: Constants.heightTitleView),
            titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: Constants.viewPaddingConstraint),
            titleLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
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
            paymentProvidersTableView.bottomAnchor.constraint(equalTo: paymentProvidersView.bottomAnchor),
            paymentProvidersTableView.heightAnchor.constraint(equalToConstant: viewModel.heightTableView)
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
    }
    
}

extension BanksBottomView {
    enum Constants {
        static let heightTitleView = 19.0
        static let descriptionTopPadding = 4.0
        static let viewPaddingConstraint = 16.0
        static let topAnchorTitleView = 32.0
        static let closeIconSize = 24.0
        static let titleViewTitleIconSpacing = 10.0
        static let topAnchorPoweredByGiniConstraint = 5.0
        static let bottomViewHeight = 44.0
    }
}

extension BanksBottomView: MoreInformationViewProtocol {
    public func didTapOnMoreInformation() {
        viewModel.didTapOnMoreInformation()
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
    
    /// We indicate the height of a bank row
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        viewModel.rowHeight
    }
    
    /// BanksBottomView event when a bank is selected from the list
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.viewDelegate?.didSelectPaymentProvider(paymentProvider: viewModel.paymentProviders[indexPath.row].paymentProvider)
    }
}
