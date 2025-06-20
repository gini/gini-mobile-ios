//
//  GiniInputAccessoryViewConfigurable.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

protocol GiniInputAccessoryViewConfigurable {
    func setupInputAccessoryView(for views: [GiniInputAccessoryViewPresentable])
    func updateCurrentField(_ field: GiniInputAccessoryViewPresentable)
}

extension GiniInputAccessoryViewConfigurable {
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

// MARK: Protocol conformance

extension UIViewController: GiniInputAccessoryViewConfigurable {}
extension UIView: GiniInputAccessoryViewConfigurable {}
