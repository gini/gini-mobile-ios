//
//  GiniConstraintAttribute.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//
import UIKit

public class GiniConstraintAttribute {
    internal let view: UIView
    internal let attribute: NSLayoutConstraint.Attribute
    internal let maker: GiniConstraintMaker
    private var createdConstraint: NSLayoutConstraint?

    internal init(view: UIView, attribute: NSLayoutConstraint.Attribute, maker: GiniConstraintMaker) {
        self.view = view
        self.attribute = attribute
        self.maker = maker
    }

    @discardableResult
    public func equalTo(_ target: UIView) -> Self {
        equalTo(GiniViewConstraintAttribute(view: target, attribute: attribute))
    }

    @discardableResult
    public func equalTo(_ target: UILayoutGuide) -> Self {
        equalTo(GiniViewConstraintAttribute(view: target, attribute: attribute))
    }

    @discardableResult
    public func equalTo(_ target: GiniViewConstraintAttribute) -> Self {
        let constraint = NSLayoutConstraint(
            item: view,
            attribute: attribute,
            relatedBy: .equal,
            toItem: target.view,
            attribute: target.attribute,
            multiplier: 1.0,
            constant: 0
        )
        maker.addConstraint(constraint)
        self.createdConstraint = constraint
        return self
    }

    @discardableResult
    public func equalTo(_ target: GiniConstraintTarget) -> Self {
        let constraint = NSLayoutConstraint(
            item: view,
            attribute: attribute,
            relatedBy: .equal,
            toItem: target.item,
            attribute: target.attribute,
            multiplier: 1.0,
            constant: target.constant
        )
        maker.addConstraint(constraint)
        self.createdConstraint = constraint
        return self
    }

    @discardableResult
    public func equalTo(_ constant: CGFloat) -> Self {
        let constraint = NSLayoutConstraint(
            item: view,
            attribute: attribute,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: constant
        )
        maker.addConstraint(constraint)
        self.createdConstraint = constraint
        return self
    }

    @discardableResult
    public func equalToSuperview() -> Self {
        guard let superview = view.superview else {
            fatalError("View must have a superview")
        }
        return equalTo(superview)
    }

    @discardableResult
    public func priority(_ priority: UILayoutPriority) -> Self {
        if let lastConstraint = maker.constraints.last {
            lastConstraint.priority = priority
        }
        return self
    }

    @discardableResult
    public func multipliedBy(_ multiplier: CGFloat) -> Self {
        guard let original = createdConstraint else { return self }

        let newConstraint = NSLayoutConstraint(
            item: original.firstItem!,
            attribute: original.firstAttribute,
            relatedBy: original.relation,
            toItem: original.secondItem,
            attribute: original.secondAttribute,
            multiplier: multiplier,
            constant: original.constant
        )
        newConstraint.priority = original.priority

        // Replace in maker
        if let index = maker.constraints.firstIndex(of: original) {
            maker.constraints.remove(at: index)
        }
        maker.addConstraint(newConstraint)
        self.createdConstraint = newConstraint

        return self
    }

    @discardableResult
    public func constant(_ value: CGFloat) -> Self {
        createdConstraint?.constant = value
        return self
    }
}
