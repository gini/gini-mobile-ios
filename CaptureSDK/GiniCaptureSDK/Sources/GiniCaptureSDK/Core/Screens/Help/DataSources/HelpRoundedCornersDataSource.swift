//
//  HelpBaseDataSource.swift
//  
//
//  Created by Krzysztof Kryniecki on 02/08/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit

class HelpRoundedCornersDataSource<Item, Cell>: NSObject, HelpDataSource where Cell: HelpCell {
    var items: [Item] = []
    let giniConfiguration: GiniConfiguration

    required init(
        configuration: GiniConfiguration
    ) {
        giniConfiguration = configuration
    }

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

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if #available(iOS 13, *) {
            // The rounded corners are done in iOS13+ by using the tableView style mode .insetGrouped
            return
        }
        
        cell.reset()
        if items.count == 1 {
            cell.round(corners: [.bottomLeft, .bottomRight, .topLeft, .topRight],
                       withRadius: RoundedCorners.cornerRadius)
        } else {
            if indexPath.row == 0 {
                cell.round(corners: [.topLeft, .topRight], withRadius: RoundedCorners.cornerRadius)
            } else {
                if indexPath.row == items.count - 1 {
                    cell.round(corners: [.bottomLeft, .bottomRight], withRadius: RoundedCorners.cornerRadius)
                } else {
                    cell.round(corners: [], withRadius: 0)
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        fatalError("tableView(tableView: didSelectRowAt:) has not been implemented")
    }
}
