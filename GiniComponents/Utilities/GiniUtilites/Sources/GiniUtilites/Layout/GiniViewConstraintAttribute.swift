//
//  GiniViewConstraintAttribute.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

/**
 A lightweight representation of a view and its layout attribute.
 Used as a passive target in constraint expressions (e.g., `equalTo(view.top)` or `view.leading + 16`).

 This class does not create constraints itself; it is only used as input for constraint-building
 methods in `GiniConstraintAttribute`.
 */

public class GiniViewConstraintAttribute {
    internal let view: AnyObject
    internal let attribute: NSLayoutConstraint.Attribute

    internal init(view: AnyObject, attribute: NSLayoutConstraint.Attribute) {
        self.view = view
        self.attribute = attribute
    }
}
