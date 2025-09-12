//
//  GiniConstraintMaker.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//
import UIKit
/**
 A builder class that exposes a fluent API for creating Auto Layout constraints
 on a specific view. Each property returns a `GiniConstraintAttribute` or
 `GiniCompoundConstraintAttribute`, allowing you to chain constraint definitions.

 `GiniConstraintMaker` is typically used inside a closure to declare all
 constraints for a view in a clean, readable way.

 Example:
 myView.gini.make { in
 $0.top.equalToSuperview().constant(16)
 $0.leading.equalToSuperview().constant(16)
 $0.trailing.equalToSuperview().constant(16)
 $0.height.equalTo(44)

 // OR
 // Shorthand with compound attributes:
 $0.edges.equalToSuperview().constant(16)
 $0.center.equalToSuperview()
 $0.size.equalTo(100)
 }
 */
public class GiniConstraintMaker {
    private let view: UIView
    internal var constraints: [NSLayoutConstraint] = []

    internal init(view: UIView) {
        self.view = view
    }

    public var top: GiniConstraintAttribute { .init(view: view, attribute: .top, maker: self) }
    public var bottom: GiniConstraintAttribute { .init(view: view, attribute: .bottom, maker: self) }
    public var leading: GiniConstraintAttribute { .init(view: view, attribute: .leading, maker: self) }
    public var trailing: GiniConstraintAttribute { .init(view: view, attribute: .trailing, maker: self) }
    public var left: GiniConstraintAttribute { .init(view: view, attribute: .left, maker: self) }
    public var right: GiniConstraintAttribute { .init(view: view, attribute: .right, maker: self) }
    public var centerX: GiniConstraintAttribute { .init(view: view, attribute: .centerX, maker: self) }
    public var centerY: GiniConstraintAttribute { .init(view: view, attribute: .centerY, maker: self) }
    public var width: GiniConstraintAttribute { .init(view: view, attribute: .width, maker: self) }
    public var height: GiniConstraintAttribute { .init(view: view, attribute: .height, maker: self) }

    public var center: GiniCompoundConstraintAttribute {
        .init(attributes: [centerX, centerY])
    }

    public var size: GiniCompoundConstraintAttribute {
        .init(attributes: [width, height])
    }

    public var edges: GiniCompoundConstraintAttribute {
        .init(attributes: [top, bottom, leading, trailing])
    }

    public var horizontal: GiniCompoundConstraintAttribute {
        .init(attributes: [leading, trailing])
    }

    public var vertical: GiniCompoundConstraintAttribute {
        .init(attributes: [top, bottom])
    }

    public func constraint(for attribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint? {
        return constraints.first(where: {
            $0.firstAttribute == attribute && $0.firstItem as? UIView === view
        })
    }

    internal func addConstraint(_ constraint: NSLayoutConstraint) {
        constraints.append(constraint)
    }
}
