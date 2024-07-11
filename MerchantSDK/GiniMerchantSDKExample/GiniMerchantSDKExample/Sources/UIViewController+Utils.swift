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
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
