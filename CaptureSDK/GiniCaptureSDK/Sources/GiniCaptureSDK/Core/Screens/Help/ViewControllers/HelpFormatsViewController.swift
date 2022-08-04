//
//  HelpFormatsViewController.swift
//  
//
//  Created by Krzysztof Kryniecki on 03/08/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit

class HelpFormatsViewController: UIViewController {
    private let margin: CGFloat = 16
    let tableRowHeight: CGFloat = 44
    let sectionHeight: CGFloat = 70
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    private (set) var dataSource: HelpFormatsDataSource
    private var giniConfiguration: GiniConfiguration
    
    
    public init(giniConfiguration: GiniConfiguration) {
        self.giniConfiguration = giniConfiguration
        self.dataSource = HelpFormatsDataSource(configuration: giniConfiguration)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        configureMainView()
        configureTableView()
        configureConstraints()
        edgesForExtendedLayout = []
    }
    
    private func configureMainView() {
        title = .localized(resource: HelpStrings.supportedFormatsTitle)
        view.backgroundColor = UIColor.from(giniColor: giniConfiguration.helpScreenBackgroundColor)
        view.addSubview(tableView)
        title = .localized(resource: HelpStrings.formatsTitle)
        view.layoutSubviews()
    }
    
    private func configureTableView() {
        tableView.register(UINib(nibName: "HelpFormatCell", bundle:giniCaptureBundle()), forCellReuseIdentifier: HelpFormatCell.reuseIdentifier)
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
    
    private func configureConstraints() {
        view.addConstraints([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: margin),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }    
}

