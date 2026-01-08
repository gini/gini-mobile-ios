//
//  UIView+Constraints.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

// MARK: - UIView Extension

/**
 Extension providing convenient Auto Layout constraint methods with a fluent syntax.

 Offers easy-to-use methods for creating, updating, and remaking constraints
 along with properties for accessing layout attributes.
 */
public extension UIView {

    /**
     Creates and activates new constraints for the view.

     - Parameter closure: Closure that receives a constraint maker for building constraints
     - Returns: Array of created and activated constraints
     */
    @discardableResult
    func giniMakeConstraints(_ closure: (GiniConstraintMaker) -> Void) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        return giniUpdateConstraints(closure)
    }

    /**
     Adds new constraints to the view without removing existing ones.

     - Parameter closure: Closure that receives a constraint maker for building constraints
     - Returns: Array of created and activated constraints
     */
    @discardableResult
    func giniUpdateConstraints(_ closure: (GiniConstraintMaker) -> Void) -> [NSLayoutConstraint] {
        let maker = GiniConstraintMaker(view: self)
        closure(maker)
        NSLayoutConstraint.activate(maker.constraints)
        return maker.constraints
    }

    /**
     Removes all existing constraints and creates new ones.

     - Parameter closure: Closure that receives a constraint maker for building constraints
     - Returns: Array of created and activated constraints
     */
    @discardableResult
    func giniRemakeConstraints(_ closure: (GiniConstraintMaker) -> Void) -> [NSLayoutConstraint] {
        NSLayoutConstraint.deactivate(self.constraints)
        return giniMakeConstraints(closure)
    }

    // MARK: - Safe Area Anchors for External Reference

    /// Safe area top anchor
    var safeTop: GiniViewConstraintAttribute { .init(view: safeAreaLayoutGuide, attribute: .top) }
    /// Safe area bottom anchor
    var safeBottom: GiniViewConstraintAttribute { .init(view: safeAreaLayoutGuide, attribute: .bottom) }
    /// Safe area leading anchor
    var safeLeading: GiniViewConstraintAttribute { .init(view: safeAreaLayoutGuide, attribute: .leading) }
    /// Safe area trailing anchor
    var safeTrailing: GiniViewConstraintAttribute { .init(view: safeAreaLayoutGuide, attribute: .trailing) }

    // MARK: - Anchor Properties for External Reference

    /// Top anchor
    var top: GiniViewConstraintAttribute { .init(view: self, attribute: .top) }
    /// Bottom anchor
    var bottom: GiniViewConstraintAttribute { .init(view: self, attribute: .bottom) }
    /// Leading anchor
    var leading: GiniViewConstraintAttribute { .init(view: self, attribute: .leading) }
    /// Trailing anchor
    var trailing: GiniViewConstraintAttribute { .init(view: self, attribute: .trailing) }
    /// Left anchor
    var left: GiniViewConstraintAttribute { .init(view: self, attribute: .left) }
    /// Right anchor
    var right: GiniViewConstraintAttribute { .init(view: self, attribute: .right) }
    /// Center X anchor
    var centerX: GiniViewConstraintAttribute { .init(view: self, attribute: .centerX) }
    /// Center Y anchor
    var centerY: GiniViewConstraintAttribute { .init(view: self, attribute: .centerY) }
    /// Width anchor
    var width: GiniViewConstraintAttribute { .init(view: self, attribute: .width) }
    /// Height anchor
    var height: GiniViewConstraintAttribute { .init(view: self, attribute: .height) }
}
