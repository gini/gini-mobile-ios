//
//  HelpImportViewController.swift
//  
//
//  Created by Krzysztof Kryniecki on 03/08/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit

class HelpImportViewController: UIViewController {
    enum HelpImportCellType {
        case selectInvoice
        case importToApp
    }
    
    private let margin: CGFloat = 0
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    private var dataSource: [HelpImportCellType] = [.selectInvoice, .importToApp]
    private var giniConfiguration: GiniConfiguration
    
    
    public init(giniConfiguration: GiniConfiguration) {
        self.giniConfiguration = giniConfiguration
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(giniConfiguration:) has not been implemented")
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
        self.title = "How to import"
        view.addSubview(tableView)
        view.backgroundColor = UIColor.from(giniColor: giniConfiguration.helpScreenBackgroundColor)
        edgesForExtendedLayout = []
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.clear
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "HelpImportCell", bundle:giniCaptureBundle()), forCellReuseIdentifier: HelpImportCell.reuseIdentifier)
        tableView.contentInsetAdjustmentBehavior = .never
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

extension HelpImportViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let itemType = dataSource[indexPath.row]
        switch itemType {
        case .importToApp:
            return 350
        case .selectInvoice:
            return 300
        }
    }
}

extension HelpImportViewController: UITableViewDataSource {
    
    private func configureCell(cell: HelpImportCell, indexPath: IndexPath) {
        let itemType = dataSource[indexPath.row]
        switch itemType {
        case .selectInvoice:
            cell.headerLabel.text = "1. Select an invoice"
            cell.descriptionLabel.text = "To do so, please select a PDF invoice from within your email app, PDF viewer or other app on your smarthpone. To redirect the file to GiniVision, use the “Share” function, represented as a square with the arrow pointing up."
            cell.importImageView.image = UIImageNamedPreferred(named: "helpImport1")
        case .importToApp:
            cell.headerLabel.text = "2. Import to app"
            cell.descriptionLabel.text = "Please select your Banking App from the list to start the analysis and transfer process."
            cell.importImageView.image = UIImageNamedPreferred(named: "helpImport2")
        }
        cell.backgroundColor = UIColor.clear
        cell.headerLabel.backgroundColor = UIColor.clear
        cell.descriptionLabel.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: HelpImportCell.reuseIdentifier) as? HelpImportCell {
            configureCell(cell: cell, indexPath: indexPath)
            return cell
        }
        fatalError()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
}
