//
//  HelpBaseDataSource.swift
//  
//
//  Created by Krzysztof Kryniecki on 02/08/2022.
//

import UIKit

public class HelpBaseDataSource<Item, Cell>: NSObject, UITableViewDelegate, UITableViewDataSource  where Cell: HelpCell {
    
    var items: [Item] = []
    let giniConfiguration: GiniConfiguration
    
    init(
        configuration: GiniConfiguration
    ) {
        giniConfiguration = configuration
    }
    
    public func configureCell(cell: Cell, indexPath: IndexPath) {
    }
    
    @objc public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    @objc(tableView:cellForRowAtIndexPath:) public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Cell.reuseIdentifier) as? Cell {
            self.configureCell(cell: cell, indexPath: indexPath)
            return cell
        }
        fatalError()
    }
    
    @objc(tableView:willDisplayCell:forRowAtIndexPath:) public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if items.count == 1 {
          cell.round(corners: [.bottomLeft, .bottomRight, .topLeft, .topRight], withRadius: 8)
        } else {
            if indexPath.row == 0 {
                cell.round(corners: [.topLeft, .topRight], withRadius: 8)
            }
            if indexPath.row == items.count - 1 {
                cell.round(corners: [.bottomLeft, .bottomRight], withRadius: 8)
            }
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
