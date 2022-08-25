//
//  ErrorViewController.swift
//  GiniCapture
//
//  Created by Krzysztof Kryniecki on 22/08/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit

final public class ErrorScreenViewController: UIViewController {
    public enum ErrorType {
        case noResults
        case other
        case custom(String)

        var description: String {
            switch self {
            case .noResults:
                return NSLocalizedStringPreferredFormat(
                    "ginicapture.error.header.no.results",
                    comment: "no results error header")
            case .other:
                return NSLocalizedStringPreferredFormat(
                    "ginicapture.error.header.no.results",
                    comment: "other error header")
            case .custom(let text):
                return text
            }
        }
    }

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    lazy var enterButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    lazy var retakeButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 14
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    lazy var buttonsView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [enterButton, retakeButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    lazy var errorHeader: ErrorHeader = {
        if let header = UINib(
            nibName: "ErrorHeader",
            bundle: giniCaptureBundle()
        ).instantiate(withOwner: nil, options: nil)[0]  as? ErrorHeader {
            header.translatesAutoresizingMaskIntoConstraints = false
        return header
        }
        fatalError("Error header not found")
    }()

    private (set) var dataSource: HelpDataSource
    private var giniConfiguration: GiniConfiguration
    private let tableRowHeight: CGFloat = 44
    private let sectionHeight: CGFloat = 70
    private let errorType: ErrorType
    private let viewModel: ErrorScreenViewModel

    public init(
        giniConfiguration: GiniConfiguration,
        errorType: ErrorType,
        viewModel: ErrorScreenViewModel
    ) {
        self.giniConfiguration = giniConfiguration
        self.errorType = errorType
        switch errorType {
        case .noResults:
            self.dataSource = HelpFormatsDataSource(configuration: giniConfiguration)
        case .other:
            let tipsDS = HelpTipsDataSource(configuration: giniConfiguration)
            tipsDS.showHeader = true
            self.dataSource = tipsDS
        case .custom(_):
            self.dataSource = HelpFormatsDataSource(configuration: giniConfiguration)
        }
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }

    private func setupView() {
        configureMainView()
        configureTableView()
        configureConstraints()
        configureButtons()
        edgesForExtendedLayout = []
    }

    private func configureMainView() {
        title = NSLocalizedStringPreferredFormat(
            "ginicapture.error.title",
            comment: "Error screen title")
        errorHeader.headerLabel.text = errorType.description
        errorHeader.headerLabel.textColor = UIColorPreferred(named: "label")
        view.backgroundColor = UIColorPreferred(named: "helpBackground")
        view.addSubview(errorHeader)
        view.addSubview(tableView)
        view.addSubview(buttonsView)
        errorHeader.backgroundColor = UIColorPreferred(named: "errorBackground")
    }

    private func configureTableView() {
        configureCells()
        tableView.delegate = self.dataSource
        tableView.dataSource = self.dataSource
        tableView.estimatedRowHeight = tableRowHeight
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()
        tableView.sectionHeaderHeight = sectionHeight
        tableView.allowsSelection = false
        tableView.backgroundColor = UIColor.clear
        tableView.alwaysBounceVertical = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 130 + GiniMargins.margin, right: 0)

        if #available(iOS 14.0, *) {
            var bgConfig = UIBackgroundConfiguration.listPlainCell()
            bgConfig.backgroundColor = UIColor.clear
            UITableViewHeaderFooterView.appearance().backgroundConfiguration = bgConfig
        }
    }

    private func configureCells() {
        switch errorType {
        case .noResults:
            tableView.register(
                UINib(
                    nibName: "HelpFormatCell",
                    bundle: giniCaptureBundle()),
                forCellReuseIdentifier: HelpFormatCell.reuseIdentifier)
        case .other:
            tableView.register(
                UINib(
                    nibName: "HelpTipCell",
                    bundle: giniCaptureBundle()),
                forCellReuseIdentifier: HelpTipCell.reuseIdentifier)
        case .custom(_):
            tableView.register(
                UINib(
                    nibName: "HelpTipCell",
                    bundle: giniCaptureBundle()),
                forCellReuseIdentifier: HelpTipCell.reuseIdentifier)
        }
        tableView.register(
            UINib(
                nibName: "HelpFormatSectionHeader",
                bundle: giniCaptureBundle()),
            forHeaderFooterViewReuseIdentifier: HelpFormatSectionHeader.reuseIdentifier)
    }

    private func configureButtons() {
        enterButton.setTitle(NSLocalizedStringPreferredFormat(
                "ginicapture.error.enterManually",
                comment: "Enter manually"),
                             for: .normal)
        let cornerRadius: CGFloat = 14
        enterButton.addBlurEffect(cornerRadius: cornerRadius)
        enterButton.titleLabel?.font = giniConfiguration.textStyleFonts[.bodyBold]
        enterButton.titleLabel?.adjustsFontForContentSizeCategory = true
        enterButton.setTitleColor(UIColorPreferred(named: "grayLabel"), for: .normal)
        enterButton.layer.cornerRadius = cornerRadius
        enterButton.layer.borderWidth = 1.0
        enterButton.layer.borderColor = UIColorPreferred(named: "grayLabel")?.cgColor ?? UIColor.white.cgColor
        enterButton.addTarget(viewModel, action: #selector(viewModel.didPressEnterManually), for: .touchUpInside)
        retakeButton.setTitle(NSLocalizedStringPreferredFormat(
            "ginicapture.error.retakeImages",
            comment: "Enter manually"),
                              for: .normal)
        retakeButton.titleLabel?.font = giniConfiguration.textStyleFonts[.bodyBold]
        retakeButton.titleLabel?.adjustsFontForContentSizeCategory = true
        retakeButton.setTitleColor(UIColorPreferred(named: "labelWhite"), for: .normal)
        retakeButton.layer.cornerRadius = cornerRadius
        retakeButton.backgroundColor = UIColorPreferred(named: "systemBlue")
        retakeButton.addTarget(viewModel, action: #selector(viewModel.didPressRetake), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: viewModel,
            action: #selector(viewModel.didPressCancell))
    }

    private func configureConstraints() {
        errorHeader.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        errorHeader.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        view.addConstraints([
            errorHeader.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            errorHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorHeader.heightAnchor.constraint(greaterThanOrEqualToConstant: 62),
            tableView.topAnchor.constraint(equalTo: errorHeader.bottomAnchor, constant: 13),
            tableView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -GiniMargins.margin),
            buttonsView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            buttonsView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            buttonsView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -GiniMargins.margin),
            buttonsView.heightAnchor.constraint(equalToConstant: 130)
        ])
        if UIDevice.current.userInterfaceIdiom == .pad {
            view.addConstraints([
                tableView.widthAnchor.constraint(equalToConstant: GiniMargins.fixediPadWidth),
                tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        } else {
            view.addConstraints([
                tableView.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: GiniMargins.horizontalMargin),
                tableView.trailingAnchor.constraint(
                    equalTo: view.trailingAnchor,
                    constant: -GiniMargins.horizontalMargin)
            ])
        }
        view.layoutSubviews()
    }
}
