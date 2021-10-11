//
//  UIViewController+Utils.swift
//  Example Swift
//
//  Created by Nadya Karaban on 16.04.21.
//

import Foundation
import UIKit
extension UIViewController {
    func showError(_ title: String? = nil, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        present(alertController, animated: true, completion: nil)
    }
}
