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
        self.title = NSLocalizedStringPreferredFormat(
            "ginicapture.help.import.title",
            comment: "Help Import screen title")
        view.addSubview(tableView)
        view.backgroundColor = UIColorPreferred(named: "helpBackground")
        edgesForExtendedLayout = []
    }

    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.backgroundColor = UIColor.clear
        tableView.tableFooterView = UIView()
        tableView.register(
            UINib(
                nibName: "HelpImportCell",
                bundle: giniCaptureBundle()),
            forCellReuseIdentifier: HelpImportCell.reuseIdentifier)
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
        let rowNr = indexPath.row + 1
        switch itemType {
        case .selectInvoice:
            cell.headerLabel.text = "\(rowNr). " + NSLocalizedStringPreferredFormat(
                "ginicapture.help.import.selectInvoice.title",
                comment: "Select an invoice header")
            cell.descriptionLabel.text = NSLocalizedStringPreferredFormat(
                "ginicapture.help.import.selectInvoice.desc",
                comment: "Select an invoice description")
            cell.importImageView.image = UIImageNamedPreferred(named: "helpImport1")
        case .importToApp:
            cell.headerLabel.text = "\(rowNr). " + NSLocalizedStringPreferredFormat(
                "ginicapture.help.import.importtoapp.title",
                comment: "Import to app header")
            cell.descriptionLabel.text = NSLocalizedStringPreferredFormat(
                "ginicapture.help.import.importtoapp.desc",
                comment: "Import to app description")
            cell.importImageView.image = UIImageNamedPreferred(named: "helpImport2")
        }
        cell.backgroundColor = UIColor.clear
        cell.headerLabel.textColor = UIColorPreferred(named: "labelColor")
        cell.headerLabel.backgroundColor = UIColor.clear
        cell.headerLabel.font = giniConfiguration.textStyleFonts[.headline]
        cell.descriptionLabel.backgroundColor = UIColor.clear
        cell.descriptionLabel.textColor = UIColorPreferred(named: "subHeadline")
        cell.descriptionLabel.font = giniConfiguration.textStyleFonts[.body]
        cell.contentView.backgroundColor = UIColor.clear
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: HelpImportCell.reuseIdentifier) as? HelpImportCell {
            configureCell(cell: cell, indexPath: indexPath)
            return cell
        }
        fatalError("undefined cell")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
}
