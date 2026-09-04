//
//  GiniConstraintAttributeTests.swift
//  GiniUtilitesTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//
//  Covers GiniConstraintAttribute: relations (equal / lessThanOrEqual /
//  greaterThanOrEqual), all target overloads (view, layout guide, view
//  attribute, offset target, raw constant, superview), plus the
//  priority / multipliedBy / constant modifiers.
//
//  These tests intentionally assert CURRENT behavior, including quirks
//  (see the "current behavior" tests at the bottom) — production code
//  must not be changed to make them pass.

import Testing
import UIKit
@testable import GiniUtilites

@Suite("GiniConstraintAttribute — single-constraint building")
@MainActor
struct GiniConstraintAttributeTests {

    /// Builds a superview/subview pair ready for constraint installation.
    private func makeHierarchy() -> (container: UIView, child: UIView) {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let child = UIView()
        container.addSubview(child)
        return (container, child)
    }

    // MARK: - equalTo overloads

    @Test("equalToSuperview creates an equal constraint to the superview with multiplier 1")
    func equalToSuperviewCreatesEqualConstraint() throws {
        let (container, child) = makeHierarchy()

        let constraints = child.giniMakeConstraints { maker in
            maker.top.equalToSuperview().constant(16)
        }

        let constraint = try #require(constraints.first)
        #expect(constraints.count == 1)
        #expect(constraint.firstItem as? UIView === child)
        #expect(constraint.firstAttribute == .top)
        #expect(constraint.relation == .equal)
        #expect(constraint.secondItem as? UIView === container)
        #expect(constraint.secondAttribute == .top)
        #expect(constraint.multiplier == 1.0)
        #expect(constraint.constant == 16)
        #expect(constraint.isActive == true)
    }

    @Test("equalTo(UIView) targets the same attribute on the other view")
    func equalToViewTargetsSameAttribute() throws {
        let (container, child) = makeHierarchy()
        let sibling = UIView()
        container.addSubview(sibling)

        let constraints = child.giniMakeConstraints { maker in
            maker.leading.equalTo(sibling)
        }

        let constraint = try #require(constraints.first)
        #expect(constraint.secondItem as? UIView === sibling)
        #expect(constraint.firstAttribute == .leading)
        #expect(constraint.secondAttribute == .leading)
        #expect(constraint.relation == .equal)
        #expect(constraint.constant == 0)
    }

    @Test("equalTo(UILayoutGuide) targets the guide with the same attribute")
    func equalToLayoutGuideTargetsGuide() throws {
        let (container, child) = makeHierarchy()

        let constraints = child.giniMakeConstraints { maker in
            maker.top.equalTo(container.layoutMarginsGuide)
        }

        let constraint = try #require(constraints.first)
        #expect(constraint.secondItem === container.layoutMarginsGuide)
        #expect(constraint.firstAttribute == .top)
        #expect(constraint.secondAttribute == .top)
    }

    @Test("equalTo(GiniViewConstraintAttribute) supports cross-attribute constraints")
    func equalToViewAttributeSupportsCrossAttribute() throws {
        let (container, child) = makeHierarchy()
        let sibling = UIView()
        container.addSubview(sibling)

        let constraints = child.giniMakeConstraints { maker in
            maker.top.equalTo(sibling.bottom)
        }

        let constraint = try #require(constraints.first)
        #expect(constraint.firstAttribute == .top)
        #expect(constraint.secondItem as? UIView === sibling)
        #expect(constraint.secondAttribute == .bottom)
    }

    @Test("equalTo(GiniConstraintTarget) applies the target's offset as constant")
    func equalToTargetAppliesOffsetConstant() throws {
        let (container, child) = makeHierarchy()
        let sibling = UIView()
        container.addSubview(sibling)

        let constraints = child.giniMakeConstraints { maker in
            maker.leading.equalTo(sibling.trailing + 16)
            maker.bottom.equalTo(sibling.top - 8)
        }

        let leadingConstraint = try #require(constraints.first)
        #expect(leadingConstraint.secondItem as? UIView === sibling)
        #expect(leadingConstraint.secondAttribute == .trailing)
        #expect(leadingConstraint.constant == 16)

        let bottomConstraint = try #require(constraints.last)
        #expect(bottomConstraint.secondAttribute == .top)
        #expect(bottomConstraint.constant == -8)
    }

    @Test("equalTo(CGFloat) creates a dimension constraint without a second item")
    func equalToConstantCreatesDimensionConstraint() throws {
        let (container, child) = makeHierarchy()
        defer { withExtendedLifetime(container) {} }

        let constraints = child.giniMakeConstraints { maker in
            maker.width.equalTo(120)
        }

        let constraint = try #require(constraints.first)
        #expect(constraint.secondItem == nil)
        #expect(constraint.secondAttribute == .notAnAttribute)
        #expect(constraint.constant == 120)
        #expect(constraint.relation == .equal)
        #expect(constraint.isActive == true)
    }

    // MARK: - lessThanOrEqualTo overloads

    @Test("lessThanOrEqualToSuperview creates a .lessThanOrEqual relation")
    func lessThanOrEqualToSuperviewCreatesRelation() throws {
        let (container, child) = makeHierarchy()

        let constraints = child.giniMakeConstraints { maker in
            maker.bottom.lessThanOrEqualToSuperview()
        }

        let constraint = try #require(constraints.first)
        #expect(constraint.relation == .lessThanOrEqual)
        #expect(constraint.secondItem as? UIView === container)
        #expect(constraint.secondAttribute == .bottom)
    }

    @Test("lessThanOrEqualTo(CGFloat) creates a bounded dimension constraint")
    func lessThanOrEqualToConstantCreatesBoundedDimension() throws {
        let (container, child) = makeHierarchy()
        defer { withExtendedLifetime(container) {} }

        let constraints = child.giniMakeConstraints { maker in
            maker.height.lessThanOrEqualTo(200)
        }

        let constraint = try #require(constraints.first)
        #expect(constraint.relation == .lessThanOrEqual)
        #expect(constraint.secondAttribute == .notAnAttribute)
        #expect(constraint.constant == 200)
    }

    @Test("lessThanOrEqualTo(UILayoutGuide) targets the guide")
    func lessThanOrEqualToLayoutGuideTargetsGuide() throws {
        let (container, child) = makeHierarchy()

        let constraints = child.giniMakeConstraints { maker in
            maker.trailing.lessThanOrEqualTo(container.safeAreaLayoutGuide)
        }

        let constraint = try #require(constraints.first)
        #expect(constraint.relation == .lessThanOrEqual)
        #expect(constraint.secondItem === container.safeAreaLayoutGuide)
        #expect(constraint.secondAttribute == .trailing)
    }

    @Test("lessThanOrEqualTo(GiniConstraintTarget) applies the offset")
    func lessThanOrEqualToTargetAppliesOffset() throws {
        let (container, child) = makeHierarchy()

        let constraints = child.giniMakeConstraints { maker in
            maker.width.lessThanOrEqualTo(container.width - 32)
        }

        let constraint = try #require(constraints.first)
        #expect(constraint.relation == .lessThanOrEqual)
        #expect(constraint.secondItem as? UIView === container)
        #expect(constraint.constant == -32)
    }

    // MARK: - greaterThanOrEqualTo overloads

    @Test("greaterThanOrEqualToSuperview creates a .greaterThanOrEqual relation")
    func greaterThanOrEqualToSuperviewCreatesRelation() throws {
        let (container, child) = makeHierarchy()

        let constraints = child.giniMakeConstraints { maker in
            maker.top.greaterThanOrEqualToSuperview()
        }

        let constraint = try #require(constraints.first)
        #expect(constraint.relation == .greaterThanOrEqual)
        #expect(constraint.secondItem as? UIView === container)
    }

    @Test("greaterThanOrEqualTo(CGFloat) creates a minimum dimension constraint")
    func greaterThanOrEqualToConstantCreatesMinimumDimension() throws {
        let (container, child) = makeHierarchy()
        defer { withExtendedLifetime(container) {} }

        let constraints = child.giniMakeConstraints { maker in
            maker.height.greaterThanOrEqualTo(44)
        }

        let constraint = try #require(constraints.first)
        #expect(constraint.relation == .greaterThanOrEqual)
        #expect(constraint.secondAttribute == .notAnAttribute)
        #expect(constraint.constant == 44)
    }

    @Test("greaterThanOrEqualTo(UILayoutGuide) targets the guide")
    func greaterThanOrEqualToLayoutGuideTargetsGuide() throws {
        let (container, child) = makeHierarchy()

        let constraints = child.giniMakeConstraints { maker in
            maker.leading.greaterThanOrEqualTo(container.layoutMarginsGuide)
        }

        let constraint = try #require(constraints.first)
        #expect(constraint.relation == .greaterThanOrEqual)
        #expect(constraint.secondItem === container.layoutMarginsGuide)
    }

    @Test("greaterThanOrEqualTo(GiniConstraintTarget) applies the offset")
    func greaterThanOrEqualToTargetAppliesOffset() throws {
        let (container, child) = makeHierarchy()

        let constraints = child.giniMakeConstraints { maker in
            maker.top.greaterThanOrEqualTo(container.top + 20)
        }

        let constraint = try #require(constraints.first)
        #expect(constraint.relation == .greaterThanOrEqual)
        #expect(constraint.constant == 20)
    }

    // MARK: - Modifiers

    @Test("priority sets the layout priority of the just-created constraint")
    func prioritySetsLayoutPriority() throws {
        let (container, child) = makeHierarchy()
        defer { withExtendedLifetime(container) {} }

        let constraints = child.giniMakeConstraints { maker in
            maker.width.equalTo(100).priority(.defaultLow)
        }

        let constraint = try #require(constraints.first)
        #expect(constraint.priority == .defaultLow)
    }

    @Test("multipliedBy replaces the created constraint with one using the new multiplier")
    func multipliedByReplacesConstraintWithNewMultiplier() throws {
        let (container, child) = makeHierarchy()

        let constraints = child.giniMakeConstraints { maker in
            maker.height.equalTo(container).multipliedBy(0.5).constant(10)
        }

        /// The original 1.0-multiplier constraint must be removed from the maker.
        #expect(constraints.count == 1)
        let constraint = try #require(constraints.first)
        #expect(constraint.multiplier == 0.5)
        #expect(constraint.constant == 10)
        #expect(constraint.relation == .equal)
        #expect(constraint.secondItem as? UIView === container)
        #expect(constraint.isActive == true)
    }

    @Test("multipliedBy preserves relation and priority of the original constraint")
    func multipliedByPreservesRelationAndPriority() throws {
        let (container, child) = makeHierarchy()

        let constraints = child.giniMakeConstraints { maker in
            maker.width.lessThanOrEqualTo(container).priority(.defaultHigh).multipliedBy(0.75)
        }

        let constraint = try #require(constraints.first)
        #expect(constraint.relation == .lessThanOrEqual)
        #expect(constraint.priority == .defaultHigh)
        #expect(constraint.multiplier == 0.75)
    }

    @Test("multipliedBy without a previously created constraint is a no-op")
    func multipliedByWithoutCreatedConstraintIsNoOp() {
        let (container, child) = makeHierarchy()
        defer { withExtendedLifetime(container) {} }

        let constraints = child.giniMakeConstraints { maker in
            maker.width.multipliedBy(2)
        }

        #expect(constraints.isEmpty)
    }

    @Test("constant before any relation call is a no-op and creates no constraint")
    func constantBeforeRelationIsNoOp() {
        let (container, child) = makeHierarchy()
        defer { withExtendedLifetime(container) {} }

        let constraints = child.giniMakeConstraints { maker in
            maker.width.constant(50)
        }

        #expect(constraints.isEmpty)
    }

    // MARK: - Current behavior (assert as-is; do not "fix" in production)

    /// Single-attribute `constant(_:)` applies the raw value, even for
    /// trailing/bottom. Only compound attributes negate — this asymmetry is
    /// current behavior and is asserted as-is.
    @Test("Single-attribute constant does NOT negate trailing/bottom (current behavior)")
    func singleAttributeConstantDoesNotNegateTrailingOrBottom() throws {
        let (container, child) = makeHierarchy()
        defer { withExtendedLifetime(container) {} }

        let constraints = child.giniMakeConstraints { maker in
            maker.trailing.equalToSuperview().constant(16)
            maker.bottom.equalToSuperview().constant(24)
        }

        let trailingConstraint = try #require(constraints.first)
        #expect(trailingConstraint.constant == 16)

        let bottomConstraint = try #require(constraints.last)
        #expect(bottomConstraint.constant == 24)
    }

    /// `priority(_:)` targets `maker.constraints.last`, not the constraint owned
    /// by the receiving attribute — calling it on a different attribute mutates
    /// the previously created constraint. Current behavior, asserted as-is.
    @Test("priority applies to the maker's last constraint, even from another attribute (current behavior)")
    func priorityAppliesToLastMakerConstraint() throws {
        let (container, child) = makeHierarchy()
        defer { withExtendedLifetime(container) {} }

        let constraints = child.giniMakeConstraints { maker in
            maker.width.equalTo(100)
            maker.height.priority(.defaultLow)
        }

        /// `height.priority` created no height constraint but re-prioritized width.
        #expect(constraints.count == 1)
        let widthConstraint = try #require(constraints.first)
        #expect(widthConstraint.firstAttribute == .width)
        #expect(widthConstraint.priority == .defaultLow)
    }
}
