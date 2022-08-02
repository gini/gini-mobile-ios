//
//  File.swift
//  
//
//  Created by Krzysztof Kryniecki on 02/08/2022.
//

import Foundation
import UIKit

protocol HelpDataSourceProtocol: UITableViewDelegate, UITableViewDataSource {
    associatedtype Cell
    func configureCell(cell: Cell, indexPath: IndexPath)
}

public protocol HelpCell: UITableViewCell {
    static var reuseIdentifier: String { get }
}
