//
//  GiniConstraintTarget.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//
import UIKit

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
