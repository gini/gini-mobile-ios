//
//  NoResultScreenViewController.swift
//  GiniCapture
//
//  Created by Krzysztof Kryniecki on 22/08/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit

final class NoResultScreenViewController: UIViewController {
    enum NoResultType {
        case image
        case pdf
        case qrCode
        case custom(String)

        var description: String {
            switch self {
            case .pdf:
                return NSLocalizedStringPreferredFormat("ginicapture.noresult.header",
                                                        comment: "no results header")
            case .image:
                return NSLocalizedStringPreferredFormat("ginicapture.noresult.header",
                                                        comment: "no results header")
            case .qrCode:
                return NSLocalizedStringPreferredFormat("ginicapture.noresult.header.qrcode",
                                                        comment: "no results header for qr codes")
            case .custom(let text):
                return text
            }
        }
    }

    lazy var tableView: UITableView = {
        var tableView: UITableView
        if #available(iOS 13.0, *) {
            tableView = UITableView(frame: .zero, style: .insetGrouped)
        } else {
            tableView = UITableView(frame: .zero, style: .grouped)
        }

        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    lazy var buttonsView: ButtonsView = {
        let view = ButtonsView(
            firstTitle: NSLocalizedStringPreferredFormat(
                "ginicapture.noresult.enterManually",
                comment: "Enter manually button title"),
            secondTitle: NSLocalizedStringPreferredFormat(
                "ginicapture.noresult.retakeImages",
                comment: "Retake images button title"))
        view.translatesAutoresizingMaskIntoConstraints = false

        view.enterButton.isHidden = viewModel.isEnterManuallyHidden()
        view.retakeButton.isHidden = viewModel.isRetakePressedHidden()

        return view
    }()

    lazy var header: IconHeader = {
        if let header = IconHeader().loadNib() as? IconHeader {
            header.headerLabel.adjustsFontForContentSizeCategory = true
            header.headerLabel.adjustsFontSizeToFitWidth = true
            header.translatesAutoresizingMaskIntoConstraints = false
        return header
        }
        fatalError("No result header not found")
    }()
    private (set) var dataSource: HelpDataSource
    private var giniConfiguration: GiniConfiguration
    private let type: NoResultType
    private let viewModel: BottomButtonsViewModel
    private var buttonsHeightConstraint: NSLayoutConstraint?
    private var numberOfButtons: Int {
        return [
            viewModel.isEnterManuallyHidden(),
            viewModel.isRetakePressedHidden()
        ].filter({
            !$0
        }).count
    }

    public init(giniConfiguration: GiniConfiguration,
                type: NoResultType,
                viewModel: BottomButtonsViewModel) {
        self.giniConfiguration = giniConfiguration
        self.type = type
        switch type {
        case .image:
            let tipsDS = HelpTipsDataSource()
            tipsDS.showHeader = true
            self.dataSource = tipsDS
        case .pdf:
            self.dataSource = HelpFormatsDataSource()
        case .qrCode:
            self.dataSource = HelpFormatsDataSource(isQRCodeContent: true)
        case .custom(_):
            self.dataSource = HelpFormatsDataSource()
        }
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()

        let eventProperties = [GiniAnalyticsProperty(key: .documentType,
                                                     value: GiniAnalyticsMapper.documentTypeAnalytics(from: type))]
        GiniAnalyticsManager.trackScreenShown(screenName: .noResults,
                                              properties: eventProperties)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if numberOfButtons > 0 {
            tableView.contentInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: buttonsView.bounds.size.height + CGFloat(numberOfButtons) * GiniMargins.margin,
                right: 0)
        } else {
            tableView.contentInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: GiniMargins.margin,
                right: 0)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        tableView.contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: buttonsView.bounds.size.height + GiniMargins.margin,
            right: 0)
    }

    private func setupView() {
        configureMainView()
        configureTableView()
        configureConstraints()
        configureButtons()
        configureCustomTopNavigationBar()
        edgesForExtendedLayout = []
    }

    private func configureMainView() {
        title = NSLocalizedStringPreferredFormat("ginicapture.noresult.title",
                                                 comment: "No result screen title")
        header.iconImageView.accessibilityLabel = NSLocalizedStringPreferredFormat("ginicapture.noresult.title",
                                                                                   comment: "No result screen title")
        header.headerLabel.text = type.description
        header.headerLabel.font = giniConfiguration.textStyleFonts[.subheadline]
        header.headerLabel.textColor = GiniColor(light: UIColor.GiniCapture.dark1,
                                                 dark: UIColor.GiniCapture.light1).uiColor()
        view.backgroundColor = GiniColor(light: UIColor.GiniCapture.light2,
                                         dark: UIColor.GiniCapture.dark2).uiColor()
        view.addSubview(header)
        view.addSubview(tableView)
        view.addSubview(buttonsView)
        header.backgroundColor = GiniColor(light: UIColor.GiniCapture.error4,
                                           dark: UIColor.GiniCapture.error1).uiColor()
    }

    private func configureCustomTopNavigationBar() {
        let cancelButton = GiniBarButton(ofType: .cancel)
        cancelButton.addAction(self, #selector(didPressCancel))

        if giniConfiguration.bottomNavigationBarEnabled {
            navigationItem.rightBarButtonItem = cancelButton.barButton
            navigationItem.setHidesBackButton(true, animated: true)
        } else {
            navigationItem.leftBarButtonItem = cancelButton.barButton
        }
    }

    private func getButtonsMinHeight(numberOfButtons: Int) -> CGFloat {
        if numberOfButtons == 1 {
            return Constants.singleButtonHeight
        } else {
            return Constants.twoButtonsHeight
        }
    }

    private func configureTableView() {
        registerCells()
        tableView.delegate = self.dataSource
        tableView.dataSource = self.dataSource
        tableView.estimatedRowHeight = Constants.tableRowHeight
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()
        tableView.sectionHeaderHeight = Constants.sectionHeight
        tableView.allowsSelection = false
        tableView.backgroundColor = UIColor.clear
        tableView.alwaysBounceVertical = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
    }

    private func registerCells() {
        switch type {
        case .pdf, .qrCode:
            tableView.register(
                UINib(
                    nibName: "HelpFormatCell",
                    bundle: giniCaptureBundleResource()),
                forCellReuseIdentifier: HelpFormatCell.reuseIdentifier)
        case .image, .custom(_):
            tableView.register(
                UINib(
                    nibName: "HelpTipCell",
                    bundle: giniCaptureBundleResource()),
                forCellReuseIdentifier: HelpTipCell.reuseIdentifier)
        }
        tableView.register(
            UINib(
                nibName: "HelpFormatSectionHeader",
                bundle: giniCaptureBundleResource()),
            forHeaderFooterViewReuseIdentifier: HelpFormatSectionHeader.reuseIdentifier)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            self?.tableView.reloadData()
            self?.view.layoutSubviews()
        }
    }

    private func configureButtons() {
        buttonsView.enterButton.addTarget(self,
                                          action: #selector(didPressEnterManually),
                                          for: .touchUpInside)
        buttonsView.retakeButton.addTarget(self,
                                           action: #selector(didPressRetake),
                                           for: .touchUpInside)
    }

    @objc func didPressEnterManually() {
        GiniAnalyticsManager.track(event: .enterManuallyTapped, screenName: .noResults)
        viewModel.didPressEnterManually()
    }

    @objc func didPressRetake() {
        GiniAnalyticsManager.track(event: .retakeImagesTapped, screenName: .noResults)
        viewModel.didPressRetake()
    }

    @objc func didPressCancel() {
        GiniAnalyticsManager.track(event: .closeTapped, screenName: .noResults)
        viewModel.didPressCancel()
    }

    private func configureHeaderContraints() {
        header.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        header.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        if UIDevice.current.isIpad {
            NSLayoutConstraint.activate([
                header.headerStack.widthAnchor.constraint(equalTo: view.widthAnchor,
                                                          multiplier: Constants.iPadWidthMultiplier),
                header.headerStack.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                header.headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                            constant: Constants.sidePadding),
                header.headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                             constant: -Constants.sidePadding)
            ])
        }
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.contentHeight),
            header.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor,
                                           multiplier: Constants.contentHeightMultiplier)
        ])
    }

    private func configureConstraints() {
        configureHeaderContraints()
        configureButtonsViewConstraints()
        configureTableViewConstraints()
        view.layoutSubviews()
    }

    private func configureButtonsViewConstraints() {
        let buttonsConstraint =  buttonsView.heightAnchor.constraint(
            greaterThanOrEqualToConstant: getButtonsMinHeight(numberOfButtons: numberOfButtons)
        )
        buttonsHeightConstraint = buttonsConstraint
        NSLayoutConstraint.activate([
            buttonsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                constant: -GiniMargins.margin),
            buttonsConstraint
        ])
        if UIDevice.current.isIpad {
            NSLayoutConstraint.activate([
                buttonsView.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: GiniMargins.margin),
                buttonsView.trailingAnchor.constraint(
                    equalTo: view.trailingAnchor,
                    constant: -GiniMargins.margin)
            ])
        } else {
            NSLayoutConstraint.activate([
                buttonsView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
                buttonsView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor)
            ])
        }
    }

    private func configureTableViewConstraints() {
        tableView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        if UIDevice.current.isIpad {
            NSLayoutConstraint.activate([
                tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                tableView.widthAnchor.constraint(equalTo: view.widthAnchor,
                                                 multiplier: Constants.iPadWidthMultiplier)
            ])
        } else {
            NSLayoutConstraint.activate([
                tableView.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: GiniMargins.margin),
                tableView.trailingAnchor.constraint(
                    equalTo: view.trailingAnchor,
                    constant: -GiniMargins.margin)
            ])
        }
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: header.bottomAnchor,
                                           constant: Constants.contentTopMargin),
            tableView.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor,
                                              constant: Constants.contentBottomMargin)
        ])
    }

    private enum Constants {
        static let singleButtonHeight: CGFloat = 50
        static let twoButtonsHeight: CGFloat = 112
        static let tableRowHeight: CGFloat = 44
        static let sectionHeight: CGFloat = 70
        static let sidePadding: CGFloat = 24
        static let contentTopMargin: CGFloat = 13
        static let contentBottomMargin: CGFloat = 16
        static let contentHeight: CGFloat = 62
        static let contentHeightMultiplier: CGFloat = 0.3
        static let iPadWidthMultiplier: CGFloat = 0.7
    }
}
