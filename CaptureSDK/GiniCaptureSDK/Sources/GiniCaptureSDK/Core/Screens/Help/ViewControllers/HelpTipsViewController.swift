//
//  ImageAnalysisNoResultsViewController.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 10/6/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation
import UIKit

/**
 The `HelpTipsViewController` provides a custom no results screen which shows some capture
 suggestions when there is no results when analysing an image.
 */

public final class HelpTipsViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    private (set) var dataSource: HelpTipsDataSource
    private var giniConfiguration: GiniConfiguration
    private let tableRowHeight: CGFloat = 76

    public init(giniConfiguration: GiniConfiguration) {
        self.giniConfiguration = giniConfiguration
        self.dataSource = HelpTipsDataSource(configuration: giniConfiguration)
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(title:subHeaderText:topViewText:topViewIcon:bottomButtonText:bottomButtonIcon:)" +
            "has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        configureMainView()
        configureTableView()
        configureConstraints()
    }

    public func configureMainView() {
        view.addSubview(tableView)
        view.backgroundColor = UIColor.Gini.helpBackground
        edgesForExtendedLayout = []
        tableView.bounces = false
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
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = tableRowHeight
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        tableView.reloadData()
    }
    
    private func configureConstraints() {
        view.addConstraints([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: GiniMargins.margin),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: GiniMargins.horizontalMargin),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -GiniMargins.horizontalMargin),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
