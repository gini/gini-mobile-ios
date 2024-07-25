//
//  UIViewController+Utils.swift
//  Example Swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
extension UIViewController {
    func showError(_ title: String? = nil, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
}
