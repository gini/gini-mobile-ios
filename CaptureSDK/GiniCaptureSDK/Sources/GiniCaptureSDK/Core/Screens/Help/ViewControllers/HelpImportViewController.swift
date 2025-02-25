//
//  HelpImportViewController.swift
//  
//
//  Created by Krzysztof Kryniecki on 03/08/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit

final class HelpImportViewController: UIViewController, HelpBottomBarEnabledViewController {

    var bottomNavigationBar: UIView?
    var navigationBarBottomAdapter: HelpBottomNavigationBarAdapter?
    var bottomNavigationBarHeightConstraint: NSLayoutConstraint?

    private enum HelpImportCellType {
        case selectInvoice
        case importToApp
        case dragAndDrop
    }

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    private var dataSource: [HelpImportCellType] = [.selectInvoice, .importToApp]
    private var giniConfiguration: GiniConfiguration

    init(giniConfiguration: GiniConfiguration) {
        self.giniConfiguration = giniConfiguration
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(giniConfiguration:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateBottomBarHeightBasedOnOrientation()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: GiniMargins.margin * 2, right: 0)
    }

    private func setupView() {
		if UIDevice.current.isIpad && giniConfiguration.shouldShowDragAndDropTutorial {
			dataSource.append(.dragAndDrop)
        }
        configureMainView()
        configureTableView()
        configureConstraints()
    }

    func configureMainView() {
        self.title = NSLocalizedStringPreferredFormat(
            "ginicapture.help.import.title",
            comment: "Help Import screen title")
        view.addSubview(tableView)
        view.backgroundColor = GiniColor(light: UIColor.GiniCapture.light2, dark: UIColor.GiniCapture.dark2).uiColor()
        edgesForExtendedLayout = []
        configureBottomNavigationBar(
            configuration: giniConfiguration,
            under: tableView)
    }

    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.backgroundColor = UIColor.clear
		tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 300
        tableView.register(
            UINib(
                nibName: "HelpImportCell",
                bundle: giniCaptureBundle()),
            forCellReuseIdentifier: HelpImportCell.reuseIdentifier)
        tableView.contentInsetAdjustmentBehavior = .never
    }

    private func configureConstraints() {
        if !giniConfiguration.bottomNavigationBarEnabled {
            NSLayoutConstraint.activate([
                tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)])
        }
        view.addConstraints([
            tableView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
        if UIDevice.current.isIpad {
            view.addConstraints([
                tableView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: GiniMargins.iPadAspectScale),
                tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        } else {
            view.addConstraints([
                tableView.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(
                    equalTo: view.trailingAnchor)
            ])
        }
        view.layoutSubviews()
    }
}

extension HelpImportViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension HelpImportViewController: UITableViewDataSource {

    private func configureCellAccessibility(
        cell: HelpImportCell,
        item: String) {
        cell.importImageView?.accessibilityTraits = .image
        cell.importImageView.accessibilityLabel = item
    }

    private func configureAssetsForCell(
        cell: HelpImportCell,
        itemType: HelpImportCellType,
        rowNumber: Int) {
        let headerTitle: String
        let accessibilityDescription: String

        switch itemType {
        case .selectInvoice:
            headerTitle = "\(rowNumber). " + NSLocalizedStringPreferredFormat(
                "ginicapture.help.import.selectInvoice.title",
                comment: "Select an invoice header")
            cell.headerLabel.text = headerTitle
            cell.descriptionLabel.text = NSLocalizedStringPreferredFormat(
                "ginicapture.help.import.selectInvoice.desc",
                comment: "Select an invoice description")
            cell.importImageView.image = UIImageNamedPreferred(named: "helpImport1")

            accessibilityDescription = NSLocalizedStringPreferredFormat(
                "ginicapture.help.import.selectInvoice.accessibility",
                comment: "Select an invoice accessibility description")
        case .importToApp:
            headerTitle = "\(rowNumber). " + NSLocalizedStringPreferredFormat(
                "ginicapture.help.import.importtoapp.title", comment: "Import to app header")
            cell.headerLabel.text = headerTitle
            cell.descriptionLabel.text = NSLocalizedStringPreferredFormat(
                "ginicapture.help.import.importtoapp.desc",
                comment: "Import to app description")
            cell.importImageView.image = UIImageNamedPreferred(named: "helpImport2")

            accessibilityDescription = NSLocalizedStringPreferredFormat(
                "ginicapture.help.import.importtoapp.accessibility",
                comment: "Import to app accessibility description")
        case .dragAndDrop:
            headerTitle = "\(rowNumber). " + NSLocalizedStringPreferredFormat(
                "ginicapture.help.import.draganddrop.title", comment: "Drag and Drop header")
            cell.headerLabel.text = headerTitle
            cell.descriptionLabel.text = NSLocalizedStringPreferredFormat(
                "ginicapture.help.import.draganddrop.desc",
                comment: "Drag and Drop description")
            cell.importImageView.image = UIImageNamedPreferred(named: "helpImport3")

            accessibilityDescription = NSLocalizedStringPreferredFormat(
                "ginicapture.help.import.draganddrop.accessibility",
                comment: "Drag and Drop accessibility description")
        }
        configureCellAccessibility(cell: cell, item: accessibilityDescription)
    }

    private func configureCell(cell: HelpImportCell, indexPath: IndexPath) {
        let itemType = dataSource[indexPath.row]
        let rowNumber = indexPath.row + 1
        configureAssetsForCell(cell: cell, itemType: itemType, rowNumber: rowNumber)
        cell.backgroundColor = UIColor.clear
        cell.headerLabel.textColor = GiniColor(light: UIColor.GiniCapture.dark1,
                                               dark: UIColor.GiniCapture.light1).uiColor()
        cell.headerLabel.backgroundColor = UIColor.clear
        cell.headerLabel.adjustsFontForContentSizeCategory = true
        cell.headerLabel.font = giniConfiguration.textStyleFonts[.bodyBold]
        cell.descriptionLabel.backgroundColor = UIColor.clear
        cell.descriptionLabel.textColor = GiniColor(light: UIColor.GiniCapture.dark6,
                                                    dark: UIColor.GiniCapture.dark7).uiColor()
        cell.descriptionLabel.font = giniConfiguration.textStyleFonts[.body]
        cell.descriptionLabel.adjustsFontForContentSizeCategory = true
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
