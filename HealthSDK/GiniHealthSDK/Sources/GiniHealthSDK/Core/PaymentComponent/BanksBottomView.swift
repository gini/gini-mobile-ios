//
//  PaymentProvidersBottomView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

class BanksBottomView: UIView {

    var viewModel: BanksBottomViewModel! {
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
        label.text = viewModel.selectBankTitleText
        label.textColor = viewModel.selectBankLabelAccentColor
        label.font = viewModel.selectBankLabelFont
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private lazy var closeTitleIconImageView: UIImageView = {
        let imageView = UIImageView(image: viewModel.closeTitleIcon.withRenderingMode(.alwaysTemplate))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.frame = CGRect(x: 0, y: 0, width: Constants.closeIconSize, height: Constants.closeIconSize)
        imageView.tintColor = viewModel.closeIconAccentColor
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapOnCloseIcon)))
        return imageView
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = viewModel.descriptionText
        label.textColor = viewModel.descriptionLabelAccentColor
        label.font = viewModel.descriptionLabelFont
        label.numberOfLines = 0
        return label
    }()

    private lazy var paymentProvidersTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: BankSelectionTableViewCell.identifier,
                                 bundle: Bundle.resource),
                           forCellReuseIdentifier: BankSelectionTableViewCell.identifier)
        tableView.estimatedRowHeight = viewModel.rowHeight
        tableView.rowHeight = viewModel.rowHeight
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        return tableView
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
    }

    private func setupViewHierarchy() {
        self.addSubview(rectangleTopView)
        self.addSubview(titleView)
        titleView.addSubview(titleLabel)
        titleView.addSubview(closeTitleIconImageView)
        self.addSubview(descriptionLabel)
        self.addSubview(paymentProvidersTableView)
        self.addSubview(poweredByGiniView)
    }

    private func setupViewAttributes() {
        self.backgroundColor = viewModel.backgroundColor
        self.roundCorners(corners: [.topLeft, .topRight], radius: Constants.cornerRadiusView)
        
        let isFullScreen = viewModel.bottomViewHeight >= viewModel.maximumViewHeight
        paymentProvidersTableView.isScrollEnabled = isFullScreen
    }

    private func setupLayout() {
        setupTopRectangleConstraints()
        setupTitleViewConstraints()
        setupDescriptionConstraints()
        setupTableViewConstraints()
        setupPoweredByGiniConstraints()
    }
    
    private func setupListeners() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    @objc private func willEnterForeground() {
        viewModel.updatePaymentProvidersInstalledState()
        paymentProvidersTableView.reloadData()
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
            titleLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
            closeTitleIconImageView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
            closeTitleIconImageView.heightAnchor.constraint(equalToConstant: closeTitleIconImageView.frame.height),
            closeTitleIconImageView.widthAnchor.constraint(equalToConstant: closeTitleIconImageView.frame.width),
            titleView.trailingAnchor.constraint(equalTo: closeTitleIconImageView.trailingAnchor)
        ])
        let titleLabelIconViewSpacingConstraint = closeTitleIconImageView.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: Constants.titleViewTitleIconSpacing)
        titleLabelIconViewSpacingConstraint.priority = .required - 1
        titleLabelIconViewSpacingConstraint.isActive = true
    }

    private func setupDescriptionConstraints() {
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: titleView.bottomAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.viewPaddingConstraint),
            self.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor, constant: Constants.viewPaddingConstraint)
        ])
    }

    private func setupTableViewConstraints() {
        NSLayoutConstraint.activate([
            paymentProvidersTableView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: Constants.viewPaddingConstraint),
            paymentProvidersTableView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.viewPaddingConstraint),
            self.trailingAnchor.constraint(equalTo: paymentProvidersTableView.trailingAnchor, constant: Constants.viewPaddingConstraint),
            paymentProvidersTableView.heightAnchor.constraint(equalToConstant: viewModel.heightTableView)
        ])
    }

    private func setupPoweredByGiniConstraints() {
        let poweredByGiniBottomAnchorConstraint = poweredByGiniView.bottomAnchor.constraint(equalTo: poweredByGiniView.bottomAnchor, constant: Constants.viewPaddingConstraint)
        poweredByGiniBottomAnchorConstraint.priority = .required - 1
        NSLayoutConstraint.activate([
            poweredByGiniView.topAnchor.constraint(equalTo: paymentProvidersTableView.bottomAnchor, constant: Constants.viewPaddingConstraint),
            poweredByGiniView.heightAnchor.constraint(equalToConstant: poweredByGiniView.frame.height),
            poweredByGiniView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            poweredByGiniBottomAnchorConstraint
        ])
    }
    
    @objc
    private func tapOnCloseIcon() {
        viewModel.didTapOnClose()
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

extension BanksBottomView {
    enum Constants {
        static let cornerRadiusView = 12.0
        static let cornerRadiusTopRectangle = 2.0
        static let widthTopRectangle = 48
        static let heightTopRectangle = 4
        static let topAnchorTopRectangle = 16.0
        static let heightTitleView = 48.0
        static let viewPaddingConstraint = 16.0
        static let topAnchorTitleView = 32.0
        static let closeIconSize = 24.0
        static let titleViewTitleIconSpacing = 10.0
    }
}

extension BanksBottomView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.paymentProviders.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BankSelectionTableViewCell.identifier, 
                                                       for: indexPath) as? BankSelectionTableViewCell else {
            return UITableViewCell()
        }
        let invoiceTableViewCellModel = viewModel.paymentProvidersViewModel(paymentProvider: viewModel.paymentProviders[indexPath.row])
        cell.cellViewModel = invoiceTableViewCellModel
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        viewModel.rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel.paymentProviders[indexPath.row].isInstalled {
            viewModel.viewDelegate?.didSelectPaymentProvider(paymentProvider: viewModel.paymentProviders[indexPath.row].paymentProvider)
        } else {
            openPaymentProvidersAppStoreLink(urlString: viewModel.paymentProviders[indexPath.row].paymentProvider.appStoreUrlIOS)
        }
    }
}
