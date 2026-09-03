//
//  GiniConstraintTarget.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//
import UIKit

/**
 A wrapper representing a constraint target consisting of:
 - an item (`UIView` or `UILayoutGuide`)
 - a layout attribute
 - an optional constant offset

 This type is mainly used internally when combining a `GiniViewConstraintAttribute`
 with an offset using the `+` or `-` operators.

 Example:
 maker.leading.equalTo(otherView.leading + 16)
 maker.bottom.equalTo(otherView.bottom - 8)

 */
public struct GiniConstraintTarget {
    let item: AnyObject
    let attribute: NSLayoutConstraint.Attribute
    let constant: CGFloat

    init(_ item: AnyObject, _ attribute: NSLayoutConstraint.Attribute, _ constant: CGFloat = 0) {
        self.item = item
        self.attribute = attribute
        self.constant = constant
    }
}

public func + (lhs: GiniViewConstraintAttribute, rhs: CGFloat) -> GiniConstraintTarget {
    GiniConstraintTarget(lhs.view, lhs.attribute, rhs)
}

public func - (lhs: GiniViewConstraintAttribute, rhs: CGFloat) -> GiniConstraintTarget {
    GiniConstraintTarget(lhs.view, lhs.attribute, -rhs)
}
