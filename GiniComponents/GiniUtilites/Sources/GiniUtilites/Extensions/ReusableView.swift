//
//  UITableView+ReusableView.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

public protocol ReusableView: UIView {
    static var reuseIdentifier: String { get }
}

public extension ReusableView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

public extension UITableView {
    // Register a cell conforming to ReusableView
    func register<T: UITableViewCell & ReusableView>(cellType: T.Type) {
        register(cellType, forCellReuseIdentifier: cellType.reuseIdentifier)
    }

    // Dequeue a reusable cell
    func dequeueReusableCell<T: UITableViewCell & ReusableView>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Unable to dequeue a cell with identifier \(T.reuseIdentifier)")
        }
        return cell
    }
}

public extension UICollectionView {
    // Register a cell conforming to ReusableView
    func register<T: UICollectionViewCell & ReusableView>(cellType: T.Type) {
        register(cellType, forCellWithReuseIdentifier: cellType.reuseIdentifier)
    }

    // Dequeue a reusable cell
    func dequeueReusableCell<T: UICollectionViewCell & ReusableView>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Unable to dequeue a cell with identifier \(T.reuseIdentifier)")
        }
        return cell
    }
}
