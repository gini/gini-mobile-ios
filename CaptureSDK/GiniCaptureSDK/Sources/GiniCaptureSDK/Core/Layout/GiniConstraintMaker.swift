//
//  GiniConstraintMaker.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//
import UIKit

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
