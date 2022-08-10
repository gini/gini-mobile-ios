//
//  HelpBaseDataSource.swift
//  
//
//  Created by Krzysztof Kryniecki on 02/08/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit

public class HelpBaseDataSource<Item, Cell>: NSObject,
    UITableViewDelegate, UITableViewDataSource  where Cell: HelpCell {
    var items: [Item] = []
    let giniConfiguration: GiniConfiguration

    init(
        configuration: GiniConfiguration
    ) {
        giniConfiguration = configuration
    }

    public func configureCell(cell: Cell, indexPath: IndexPath) {
        fatalError("init(coder:) has not been implemented")
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Cell.reuseIdentifier) as? Cell {
            self.configureCell(cell: cell, indexPath: indexPath)
            return cell
        }
        fatalError("undefined cell")
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if items.count == 1 {
            cell.round(
                corners: [.bottomLeft, .bottomRight, .topLeft, .topRight],
                withRadius: RoundedCorners.cornerRadius)
        } else {
            if indexPath.row == 0 {
                cell.round(corners: [.topLeft, .topRight], withRadius: RoundedCorners.cornerRadius)
            }
            if indexPath.row == items.count - 1 {
                cell.round(corners: [.bottomLeft, .bottomRight], withRadius: RoundedCorners.cornerRadius)
            }
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        fatalError("tableView(tableView: didSelectRowAt:) has not been implemented")
    }
}
