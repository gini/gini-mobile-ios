//
//  HelpMenuViewController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

/**
 The `HelpMenuViewControllerDelegate` protocol defines methods that allow you to handle table item selection actions.
 */

protocol HelpMenuViewControllerDelegate: AnyObject {
    func help(_ menuViewController: HelpMenuViewController, didSelect item: HelpMenuItem)
}

/**
 The `HelpMenuViewController` provides explanations on how to take better pictures, how to
 use the _Open with_ feature and which formats are supported by the Gini Capture SDK. 
 */

final class HelpMenuViewController: UIViewController, HelpBottomBarEnabledViewController {

    weak var delegate: HelpMenuViewControllerDelegate?
    private (set) var dataSource: HelpMenuDataSource
    private let giniConfiguration: GiniConfiguration
    private let tableRowHeight: CGFloat = 44
    var navigationBarBottomAdapter: HelpBottomNavigationBarAdapter?
    var bottomNavigationBar: UIView?
    private var bottomConstraint: NSLayoutConstraint?

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

    init(giniConfiguration: GiniConfiguration) {
        self.giniConfiguration = giniConfiguration
        self.dataSource = HelpMenuDataSource(configuration: giniConfiguration)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(giniConfiguration:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource.delegate = self
        setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        sendGiniAnalyticsEventScreenShown()
    }

    private func sendGiniAnalyticsEventScreenShown() {
        guard dataSource.helpItemsAnalyticsValues.isNotEmpty else { return }
        var eventProperties = [GiniAnalyticsProperty(key: .hasCustomItems,
                                                     value: giniConfiguration.customMenuItems.isNotEmpty)]

        eventProperties.append(GiniAnalyticsProperty(key: .helpItems,
                                                     value: dataSource.helpItemsAnalyticsValues))
        GiniAnalyticsManager.trackScreenShown(screenName: .help,
                                              properties: eventProperties)
    }

    private func setupView() {
        configureMainView()
        configureTableView()
        configureConstraints()
        edgesForExtendedLayout = []
    }

    private func configureTableView() {
        tableView.dataSource = self.dataSource
        tableView.delegate = self.dataSource
        tableView.backgroundColor = UIColor.clear
        tableView.showsVerticalScrollIndicator = false
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        tableView.register(
            UINib(
                nibName: "HelpMenuCell",
                bundle: giniCaptureBundleResource()),
            forCellReuseIdentifier: HelpMenuCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = tableRowHeight
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.separatorStyle = .none
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.reloadData()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }

    private func configureMainView() {
        view.backgroundColor = GiniColor(light: UIColor.GiniCapture.light2, dark: UIColor.GiniCapture.dark2).uiColor()
        view.addSubview(tableView)
        title = NSLocalizedStringPreferredFormat("ginicapture.help.menu.title", comment: "Help Import screen title")
        view.layoutSubviews()
        configureBottomNavigationBar(
            configuration: giniConfiguration,
            under: tableView)
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
                tableView.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: GiniMargins.margin),
                tableView.trailingAnchor.constraint(
                    equalTo: view.trailingAnchor,
                    constant: -GiniMargins.margin)
            ])
        }
        view.layoutSubviews()
    }

    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - HelpMenuDataSourceDelegate

extension HelpMenuViewController: HelpMenuDataSourceDelegate {
    func didSelectHelpItem(at index: Int) {
        let item = dataSource.items[index]
        GiniAnalyticsManager.track(event: .helpItemTapped,
                                   screenName: .help,
                                   properties: [GiniAnalyticsProperty(key: .itemTapped,
                                                                      value: item.title)])
        delegate?.help(self, didSelect: item)
    }
}
