//
//  HelpBaseDataSource.swift
//  
//
//  Created by Krzysztof Kryniecki on 02/08/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit

protocol HelpDataSource: UITableViewDelegate, UITableViewDataSource {}

class HelpRoundedCornersDataSource<Item, Cell>: NSObject, HelpDataSource where Cell: HelpCell {
    var items: [Item] = []
    let giniConfiguration = GiniConfiguration.shared

    func configureCell(cell: Cell, indexPath: IndexPath) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - HelpMenuDataSourceDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Cell.reuseIdentifier) as? Cell {
            self.configureCell(cell: cell, indexPath: indexPath)
            return cell
        }
        fatalError("undefined cell")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        fatalError("tableView(tableView: didSelectRowAt:) has not been implemented")
    }
}
