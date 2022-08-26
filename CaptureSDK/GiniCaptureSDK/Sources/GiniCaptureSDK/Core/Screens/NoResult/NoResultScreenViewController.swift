//
//  NoResultScreenViewController.swift
//  GiniCapture
//
//  Created by Krzysztof Kryniecki on 22/08/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit

final public class NoResultScreenViewController: UIViewController {
    public enum NoResultType {
        case image
        case pdf
        case custom(String)

        var description: String {
            switch self {
            case .pdf:
                return NSLocalizedStringPreferredFormat(
                    "ginicapture.noresult.header.other",
                    comment: "no results header")
            case .image:
                return NSLocalizedStringPreferredFormat(
                    "ginicapture.noresult.header.no.results",
                    comment: "other no result header")
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

    lazy var header: NoResultHeader = {
        
        if let header = NoResultHeader().loadNib() as? NoResultHeader {
            header.translatesAutoresizingMaskIntoConstraints = false
        return header
        }
        fatalError("No result header not found")
    }()

    private (set) var dataSource: HelpDataSource
    private var giniConfiguration: GiniConfiguration
    private let tableRowHeight: CGFloat = 44
    private let sectionHeight: CGFloat = 70
    private let type: NoResultType
    private let viewModel: NoResultScreenViewModel

    public init(
        giniConfiguration: GiniConfiguration,
        type: NoResultType,
        viewModel: NoResultScreenViewModel
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
            "ginicapture.noresult.title",
            comment: "No result screen title")
        header.headerLabel.text = type.description
        header.headerLabel.font = giniConfiguration.textStyleFonts[.subheadline]
        header.headerLabel.textColor = UIColorPreferred(named: "label")
        view.backgroundColor = UIColorPreferred(named: "helpBackground")
        view.addSubview(header)
        view.addSubview(tableView)
        view.addSubview(buttonsView)
        header.backgroundColor = UIColorPreferred(named: "errorBackground")
    }

    private func configureTableView() {
        registerCells()
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

    private func registerCells() {
        switch type {
        case .pdf:
            tableView.register(
                UINib(
                    nibName: "HelpFormatCell",
                    bundle: giniCaptureBundle()),
                forCellReuseIdentifier: HelpFormatCell.reuseIdentifier)
        case .image, .custom(_):
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
                "ginicapture.noresult.enterManually",
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
            "ginicapture.noresult.retakeImages",
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
        header.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        header.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(greaterThanOrEqualToConstant: 62),
            tableView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 13),
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
            NSLayoutConstraint.activate([
                tableView.widthAnchor.constraint(equalToConstant: GiniMargins.fixediPadWidth),
                tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
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
