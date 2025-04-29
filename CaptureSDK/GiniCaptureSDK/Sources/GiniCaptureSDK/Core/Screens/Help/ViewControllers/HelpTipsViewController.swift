//
//  HelpTipsViewController.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 10/6/17.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import Foundation
import UIKit

/**
 The `HelpTipsViewController` provides a custom no results screen which shows some capture
 suggestions when there is no results when analysing an image.
 */

final class HelpTipsViewController: UIViewController, HelpBottomBarEnabledViewController {
    var bottomNavigationBar: UIView?
    var navigationBarBottomAdapter: HelpBottomNavigationBarAdapter?
    var bottomNavigationBarHeightConstraint: NSLayoutConstraint?

    private lazy var tableView: UITableView = {
        var tableView: UITableView
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    private(set) var dataSource: HelpTipsDataSource
    private var giniConfiguration: GiniConfiguration
    private let tableRowHeight: CGFloat = 76

    init(giniConfiguration: GiniConfiguration) {
        self.giniConfiguration = giniConfiguration
        self.dataSource = HelpTipsDataSource()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(title:subHeaderText:topViewText:topViewIcon:bottomButtonText:bottomButtonIcon:)" +
            "has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateBottomBarHeightBasedOnOrientation()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: GiniMargins.margin, right: 0)
        tableView.reloadData()
    }

    private func setupView() {
        configureMainView()
        configureTableView()
        configureConstraints()
    }

    func configureMainView() {
        view.addSubview(tableView)
        view.backgroundColor = GiniColor(light: UIColor.GiniCapture.light2, dark: UIColor.GiniCapture.dark2).uiColor()
        edgesForExtendedLayout = []
        tableView.bounces = false
        configureBottomNavigationBar(
            configuration: giniConfiguration,
            under: tableView)
    }

    private func configureTableView() {
        tableView.dataSource = self.dataSource
        tableView.delegate = self.dataSource
        tableView.backgroundColor = UIColor.clear
        tableView.tableFooterView = UIView()
        tableView.register(
            UINib(
                nibName: "HelpTipCell",
                bundle: giniCaptureBundle()),
            forCellReuseIdentifier: HelpTipCell.reuseIdentifier)
        tableView.register(
            UINib(
                nibName: "HelpFormatSectionHeader",
                bundle: giniCaptureBundle()),
            forHeaderFooterViewReuseIdentifier: HelpFormatSectionHeader.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = tableRowHeight
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            self?.tableView.reloadData()
            self?.view.layoutSubviews()
        }
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
}
