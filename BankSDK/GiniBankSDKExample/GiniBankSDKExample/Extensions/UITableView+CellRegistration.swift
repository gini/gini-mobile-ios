//
//  UITableView+CellRegistration.swift
//  GiniBankSDKExample
//
//  Created by Valentina Iancu on 12.06.23.
//

import UIKit

extension UITableViewCell: ReusableView { }

extension UITableView {
	/// Dequeue a reusable view with an identifier that has the same name of the class
	func dequeueReusableCell<T: UITableViewCell>() -> T {
		guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier) as? T else {
			fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
		}
		
		return cell
	}

	/// Registers a class and a nib with the same name in the tableView
	/// A .xib with the same name of the class must exists, otherwise it will crash
	func register<T: UITableViewCell & NibLoadableView & ReusableView>(_: T.Type) {
		let nib = UINib(nibName: T.nibName, bundle: nil)
		register(nib, forCellReuseIdentifier: T.reuseIdentifier)
	}
    /// Registers a class in the tableView
    func register<T: UITableViewCell & CodeLoadableView & ReusableView>(_: T.Type) {
        register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }
}
