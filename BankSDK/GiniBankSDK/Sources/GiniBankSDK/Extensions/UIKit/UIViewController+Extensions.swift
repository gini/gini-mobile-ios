//
//  UIViewController+Extensions.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

extension UIViewController {

    func setupInputAccessoryView(for views: [GiniInputAccessoryViewPresentable]) {
        let accessoryView = GiniInputAccessoryView(fields: views.compactMap { $0 as? UIView })

        accessoryView.delegate = self as? GiniInputAccessoryViewDelegate

        for var view in views {
            view.inputAccessoryView = accessoryView
        }
    }

    func updateCurrentField(_ field: GiniInputAccessoryViewPresentable) {
        let inputAccessoryView = field.inputAccessoryView as? GiniInputAccessoryView

        guard let view = field as? UIView else { return }

        inputAccessoryView?.updateCurrentField(view)
    }
}

