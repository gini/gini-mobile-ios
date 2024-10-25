//
//  UITableView+HeaderFooterViewRegistration.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

extension UITableViewHeaderFooterView: ReusableView { }
extension UITableViewHeaderFooterView: NibLoadableView { }
extension UITableView {
    /// Dequeue a reusable view with an identifier that has the same name of the class
    func dequeueReusableHeaderFooter<T: UITableViewHeaderFooterView>() -> T {
        guard let cell = dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as? T else {
            fatalError("Could not dequeue header/footer with identifier: \(T.reuseIdentifier)")
        }

        return cell
    }
    /// Registers a class and a nib with the same name in the tableView
    /// A .xib with the same name of the class must exists, otherwise it will crash
    func registerHeaderFooter<T: UITableViewHeaderFooterView & NibLoadableView & ReusableView>(_: T.Type) {

        let nib = UINib(nibName: T.nibName, bundle: nil)
        register(nib, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
    }
    /// Registers a class in the tableView for code-based header/footer view
    func registerHeaderFooter<T: UITableViewHeaderFooterView & CodeLoadableView & ReusableView>(_: T.Type) {
        register(T.self, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
    }
}
