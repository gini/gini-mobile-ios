//
//  GiniViewConstraintAttribute.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

public class GiniViewConstraintAttribute {
    internal let view: AnyObject
    internal let attribute: NSLayoutConstraint.Attribute

    internal init(view: AnyObject, attribute: NSLayoutConstraint.Attribute) {
        self.view = view
        self.attribute = attribute
    }
}
