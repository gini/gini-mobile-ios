//
//  HelpFormatsViewController.swift
//  
//
//  Created by Krzysztof Kryniecki on 03/08/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit

final class HelpFormatsViewController: UIViewController, HelpBottomBarEnabledViewController {

    var bottomNavigationBar: UIView?
    var navigationBarBottomAdapter: HelpBottomNavigationBarAdapter?
    var bottomNavigationBarHeightConstraint: NSLayoutConstraint?

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
    private(set) var dataSource: HelpFormatsDataSource
    private var giniConfiguration: GiniConfiguration
    private let tableRowHeight: CGFloat = 44
    private let sectionHeight: CGFloat = 70
    private lazy var tableViewLeadingConstraint = tableView.leadingAnchor.constraint(
        equalTo: view.leadingAnchor,
        constant: GiniMargins.margin)
    private lazy var tableViewTrailingConstraint = tableView.trailingAnchor.constraint(
        equalTo: view.trailingAnchor,
        constant: -GiniMargins.margin)

    init(giniConfiguration: GiniConfiguration) {
        self.giniConfiguration = giniConfiguration
        self.dataSource = HelpFormatsDataSource()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateBottomBarHeightBasedOnOrientation()
        if UIDevice.current.isIphone {
            let isLandscape = currentInterfaceOrientation.isLandscape
            let margin = isLandscape ? GiniMargins.horizontalMargin : GiniMargins.margin
            tableViewLeadingConstraint.constant = margin
            tableViewTrailingConstraint.constant = -margin
        }
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: GiniMargins.margin, right: 0)
        tableView.reloadData()
    }

    private func setupView() {
        configureMainView()
        configureTableView()
        configureConstraints()
        edgesForExtendedLayout = []
    }

    private func configureMainView() {
        title = NSLocalizedStringPreferredFormat(
            "ginicapture.help.supportedFormats.title",
            comment: "Supported formats screen title")
        view.backgroundColor = GiniColor(light: UIColor.GiniCapture.light2, dark: UIColor.GiniCapture.dark2).uiColor()
        view.addSubview(tableView)
        configureBottomNavigationBar(
            configuration: giniConfiguration,
            under: tableView)
    }

    private func configureTableView() {
        tableView.register(
            UINib(
                nibName: "HelpFormatCell",
                bundle: giniCaptureBundle()),
            forCellReuseIdentifier: HelpFormatCell.reuseIdentifier)
        tableView.register(
            UINib(
                nibName: "HelpFormatSectionHeader",
                bundle: giniCaptureBundle()),
            forHeaderFooterViewReuseIdentifier: HelpFormatSectionHeader.reuseIdentifier)
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
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.separatorStyle = .none
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        tableView.reloadData()
    }

    private func configureConstraints() {
        if giniConfiguration.bottomNavigationBarEnabled == false {
            NSLayoutConstraint.activate([tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
        }

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: GiniMargins.margin)
        ])
        if UIDevice.current.isIpad {
            NSLayoutConstraint.activate([
                tableView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: GiniMargins.iPadAspectScale),
                tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                tableViewLeadingConstraint,
                tableViewTrailingConstraint
            ])
        }
        view.layoutSubviews()
    }
}
