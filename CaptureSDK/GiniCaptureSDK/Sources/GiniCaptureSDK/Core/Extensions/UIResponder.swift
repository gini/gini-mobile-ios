//
//  UIResponder.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

// TODO: Remove this file from here and use it from `GiniUtilites` SDK
public extension UIResponder {

    /// Recursively searches up the responder chain to find the parent view controller.
    ///
    /// This computed property traverses the responder chain starting from the current
    /// UIResponder instance and returns the first UIViewController found in the chain.
    /// It's particularly useful when you need to access the parent view controller
    /// from a UIView or any other UIResponder subclass.
    ///
    /// - Returns: The parent UIViewController if found in the responder chain, nil otherwise.
    ///
    /// - Note: This property uses recursive traversal through the `next` property
    ///         of the responder chain until it finds a UIViewController or reaches
    ///         the end of the chain.
    ///
    /// Example usage:
    /// ```swift
    /// // From within a UIView
    /// if let parentVC = self.parentViewController {
    ///     parentVC.present(alertController, animated: true)
    /// }
    ///
    /// // From a UIButton action
    /// @IBAction func buttonTapped(_ sender: UIButton) {
    ///     sender.parentViewController?.navigationController?.popViewController(animated: true)
    /// }
    ///```
    var parentViewController: UIViewController? {
        next as? UIViewController ?? next?.parentViewController
    }
}
