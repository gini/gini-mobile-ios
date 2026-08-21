//
//  GiniCompoundConstraintAttribute.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//
import UIKit

/**
 A compound constraint builder that groups multiple `GiniConstraintAttribute`s
 (e.g. top, leading, trailing, bottom) and applies the same operation to all.

 Use this when you want to define constraints for multiple attributes at once,
 such as pinning all edges to a superview with the same inset.

 Example:
 maker.edges.equalToSuperview().constant(16).priority(.required)
 */

public class GiniCompoundConstraintAttribute {
    internal let attributes: [GiniConstraintAttribute]

    internal init(attributes: [GiniConstraintAttribute]) {
        self.attributes = attributes
    }

    @discardableResult
    public func equalTo(_ target: UIView) -> Self {
        attributes.forEach { $0.equalTo(target) }
        return self
    }

    @discardableResult
    public func equalTo(_ target: UILayoutGuide) -> Self {
        attributes.forEach { $0.equalTo(target) }
        return self
    }

    @discardableResult
    public func equalTo(_ constant: CGFloat) -> Self {
        attributes.forEach { $0.equalTo(constant) }
        return self
    }

    @discardableResult
    public func equalToSuperview() -> Self {
        attributes.forEach { $0.equalToSuperview() }
        return self
    }

    @discardableResult
    public func priority(_ priority: UILayoutPriority) -> Self {
        attributes.forEach { $0.priority(priority) }
        return self
    }

    @discardableResult
    public func constant(_ value: CGFloat) -> Self {
        for attribute in attributes {
            switch attribute.attribute {
            case .trailing, .right, .bottom:
                attribute.constant(-value)
            default:
                attribute.constant(value)
            }
        }
        return self
    }
}
