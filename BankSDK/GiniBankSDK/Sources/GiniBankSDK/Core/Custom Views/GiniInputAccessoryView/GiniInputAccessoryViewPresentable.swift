//
//  GiniInputAccessoryViewPresentable.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

/**
A protocol that enables any conforming view to present an input accessory view.

This protocol provides a generic way to add input accessory functionality to any view type,
not just text input controls like UITextField or UITextView. By conforming to this protocol,
any view can display a custom accessory view above the keyboard or input method.
*/
protocol GiniInputAccessoryViewPresentable {
    var inputAccessoryView: UIView? { get set }
}
