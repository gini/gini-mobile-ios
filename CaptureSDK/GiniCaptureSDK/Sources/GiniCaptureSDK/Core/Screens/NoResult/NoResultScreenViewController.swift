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
        case custom(String)

        var description: String {
            switch self {
            case .pdf:
                return NSLocalizedStringPreferredFormat(
                    "ginicapture.noresult.header",
                    comment: "no results header")
            case .image:
                return NSLocalizedStringPreferredFormat(
                    "ginicapture.noresult.header",
                    comment: "no results header")
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

    private lazy var errorHeaderContentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
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

    public init(
        giniConfiguration: GiniConfiguration,
        type: NoResultType,
        viewModel: BottomButtonsViewModel
    ) {
        self.giniConfiguration = giniConfiguration
        self.type = type
        switch type {
        case .image:
            let tipsDS = HelpTipsDataSource(configuration: giniConfiguration)
            tipsDS.showHeader = true
            self.dataSource = tipsDS
        case .pdf:
            self.dataSource = HelpFormatsDataSource(configuration: giniConfiguration)
        case .custom(_):
            self.dataSource = HelpFormatsDataSource(configuration: giniConfiguration)
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
        title = NSLocalizedStringPreferredFormat(
            "ginicapture.noresult.title",
            comment: "No result screen title")
        header.iconImageView.accessibilityLabel = NSLocalizedStringPreferredFormat(
            "ginicapture.noresult.title",
            comment: "No result screen title")
        header.headerLabel.text = type.description
        header.headerLabel.font = giniConfiguration.textStyleFonts[.subheadline]
        header.headerLabel.textColor = GiniColor(
            light: UIColor.GiniCapture.dark1,
            dark: UIColor.GiniCapture.light1
        ).uiColor()
        view.backgroundColor = GiniColor(light: UIColor.GiniCapture.light2, dark: UIColor.GiniCapture.dark2).uiColor()
        view.addSubview(errorHeaderContentView)
        errorHeaderContentView.addSubview(header)
        view.addSubview(tableView)
        view.addSubview(buttonsView)
        errorHeaderContentView.backgroundColor = GiniColor(light: .GiniCapture.error4,
                                                           dark: .GiniCapture.error1).uiColor()
        header.backgroundColor = .clear
    }

    private func configureCustomTopNavigationBar() {
        let cancelButton = GiniBarButton(ofType: .cancel)
        cancelButton.addAction(viewModel, #selector(viewModel.didPressCancell))

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

        if #available(iOS 14.0, *) {
            var bgConfig = UIBackgroundConfiguration.listPlainCell()
            bgConfig.backgroundColor = UIColor.clear
            UITableViewHeaderFooterView.appearance().backgroundConfiguration = bgConfig
        }
    }

    private func registerCells() {
        switch type {
        case .pdf:
            tableView.register(UINib(nibName: "HelpFormatCell", bundle: giniCaptureBundle()),
                               forCellReuseIdentifier: HelpFormatCell.reuseIdentifier)
        case .image, .custom(_):
            tableView.register(UINib(nibName: "HelpTipCell", bundle: giniCaptureBundle()),
                               forCellReuseIdentifier: HelpTipCell.reuseIdentifier)
        }
        tableView.register(UINib(nibName: "HelpFormatSectionHeader", bundle: giniCaptureBundle()),
                           forHeaderFooterViewReuseIdentifier: HelpFormatSectionHeader.reuseIdentifier)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        tableView.reloadData()
        view.layoutSubviews()
    }

    private func configureButtons() {
        buttonsView.enterButton.addTarget(viewModel,
                                          action: #selector(viewModel.didPressEnterManually),
                                          for: .touchUpInside)
        buttonsView.retakeButton.addTarget(viewModel,
                                           action: #selector(viewModel.didPressRetake),
                                           for: .touchUpInside)
    }

    private func configureConstraints() {
        header.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        header.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        tableView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        let buttonsConstraint =  buttonsView.heightAnchor.constraint(
            greaterThanOrEqualToConstant: getButtonsMinHeight(numberOfButtons: numberOfButtons)
        )
        buttonsHeightConstraint = buttonsConstraint
        NSLayoutConstraint.activate([
            tableView.heightAnchor.constraint(greaterThanOrEqualToConstant: view.bounds.size.height * 0.6),
            tableView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: Constants.tableViewPadding),
            tableView.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: Constants.tableViewPadding),

            errorHeaderContentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            errorHeaderContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorHeaderContentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorHeaderContentView.bottomAnchor.constraint(equalTo: header.bottomAnchor),

            header.topAnchor.constraint(equalTo: errorHeaderContentView.topAnchor),
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            header.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.errorHeaderHeight),

            buttonsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                constant: -GiniMargins.margin),
            buttonsConstraint
        ])
        configureHorizontalConstraints()
        view.layoutSubviews()
    }

    private func configureHorizontalConstraints() {
        if UIDevice.current.isIpad {
            NSLayoutConstraint.activate([
                tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                tableView.widthAnchor.constraint(equalTo: view.widthAnchor,
                                                 multiplier: Constants.tabletWidthMultiplier),

                header.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor),

                buttonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: GiniMargins.margin),
                buttonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -GiniMargins.margin)
            ])
        } else {
            NSLayoutConstraint.activate([
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: GiniMargins.margin),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -GiniMargins.margin),

                header.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.errorPadding),

                buttonsView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
                buttonsView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor)
            ])
        }
    }
}

private extension NoResultScreenViewController {
    enum Constants {
        static let singleButtonHeight: CGFloat = 50
        static let twoButtonsHeight: CGFloat = 112
        static let tableRowHeight: CGFloat = 44
        static let sectionHeight: CGFloat = 70
        static let errorPadding: CGFloat = 24
        static let errorHeaderHeight: CGFloat = 62
        static let tableViewPadding: CGFloat = 16
        static let tabletWidthMultiplier: CGFloat = 0.6
    }
}
