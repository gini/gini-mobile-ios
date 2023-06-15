//
//  ReuseIdentifier.swift
//  
//
//  Created by David Vizaknai on 13.09.2022.
//

import UIKit

protocol Reusable {
    static var reuseIdentifier: String { get }
}

extension Reusable {
    static var reuseIdentifier: String {
        String(describing: self)
    }
}

extension UICollectionReusableView: Reusable {}

extension UITableViewCell: Reusable {}

extension UITableViewHeaderFooterView: Reusable {}
