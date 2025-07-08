//
//  UIView+Constraints.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

// MARK: - UIView Extension

public extension UIView {

    @discardableResult
    func giniMakeConstraints(_ closure: (GiniConstraintMaker) -> Void) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        let maker = GiniConstraintMaker(view: self)
        closure(maker)
        NSLayoutConstraint.activate(maker.constraints)
        return maker.constraints
    }

    @discardableResult
    func giniUpdateConstraints(_ closure: (GiniConstraintMaker) -> Void) -> [NSLayoutConstraint] {
        let maker = GiniConstraintMaker(view: self)
        closure(maker)
        NSLayoutConstraint.activate(maker.constraints)
        return maker.constraints
    }

    @discardableResult
    func giniRemakeConstraints(_ closure: (GiniConstraintMaker) -> Void) -> [NSLayoutConstraint] {
        NSLayoutConstraint.deactivate(self.constraints)
        return giniMakeConstraints(closure)
    }

    // MARK: - Safe Area Anchors for External Reference
    var safeTop: GiniViewConstraintAttribute { .init(view: safeAreaLayoutGuide, attribute: .top) }
    var safeBottom: GiniViewConstraintAttribute { .init(view: safeAreaLayoutGuide, attribute: .bottom) }
    var safeLeading: GiniViewConstraintAttribute { .init(view: safeAreaLayoutGuide, attribute: .leading) }
    var safeTrailing: GiniViewConstraintAttribute { .init(view: safeAreaLayoutGuide, attribute: .trailing) }

    // MARK: - Anchor Properties for External Reference
    var top: GiniViewConstraintAttribute { .init(view: self, attribute: .top) }
    var bottom: GiniViewConstraintAttribute { .init(view: self, attribute: .bottom) }
    var leading: GiniViewConstraintAttribute { .init(view: self, attribute: .leading) }
    var trailing: GiniViewConstraintAttribute { .init(view: self, attribute: .trailing) }
    var left: GiniViewConstraintAttribute { .init(view: self, attribute: .left) }
    var right: GiniViewConstraintAttribute { .init(view: self, attribute: .right) }
    var centerX: GiniViewConstraintAttribute { .init(view: self, attribute: .centerX) }
    var centerY: GiniViewConstraintAttribute { .init(view: self, attribute: .centerY) }
    var width: GiniViewConstraintAttribute { .init(view: self, attribute: .width) }
    var height: GiniViewConstraintAttribute { .init(view: self, attribute: .height) }
}
