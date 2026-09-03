//
//  GiniCompoundConstraintAttributeTests.swift
//  GiniUtilitesTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//
//  Covers GiniCompoundConstraintAttribute: edges / center / size /
//  horizontal / vertical groups, all equalTo overloads, and the
//  constant negation rule for trailing/right/bottom.

import Testing
import UIKit
@testable import GiniUtilites

@Suite("GiniCompoundConstraintAttribute — grouped constraint building")
@MainActor
struct GiniCompoundConstraintAttributeTests {

    /// Builds a superview/subview pair ready for constraint installation.
    private func makeHierarchy() -> (container: UIView, child: UIView) {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let child = UIView()
        container.addSubview(child)
        return (container, child)
    }

    /// Returns the constraint with the given first attribute or fails the test.
    private func constraint(for attribute: NSLayoutConstraint.Attribute,
                            in constraints: [NSLayoutConstraint]) throws -> NSLayoutConstraint {
        try #require(constraints.first { $0.firstAttribute == attribute },
                     "Missing constraint for \(attribute)")
    }

    @Test("edges.equalToSuperview creates four active constraints to the superview")
    func edgesEqualToSuperviewCreatesFourConstraints() throws {
        let (container, child) = makeHierarchy()

        let constraints = child.giniMakeConstraints { maker in
            maker.edges.equalToSuperview()
        }

        #expect(constraints.count == 4)
        #expect(Set(constraints.map(\.firstAttribute)) == [.top, .bottom, .leading, .trailing])
        for constraint in constraints {
            #expect(constraint.secondItem as? UIView === container)
            #expect(constraint.relation == .equal)
            #expect(constraint.isActive == true)
            #expect(constraint.firstAttribute == constraint.secondAttribute)
        }
    }

    @Test("Compound constant negates trailing and bottom but not top and leading")
    func compoundConstantNegatesTrailingAndBottom() throws {
        let (container, child) = makeHierarchy()
        defer { withExtendedLifetime(container) {} }

        let constraints = child.giniMakeConstraints { maker in
            maker.edges.equalToSuperview().constant(16)
        }

        #expect(try constraint(for: .top, in: constraints).constant == 16)
        #expect(try constraint(for: .leading, in: constraints).constant == 16)
        #expect(try constraint(for: .bottom, in: constraints).constant == -16)
        #expect(try constraint(for: .trailing, in: constraints).constant == -16)
    }

    @Test("horizontal creates leading and trailing constraints with negated trailing constant")
    func horizontalCreatesLeadingAndTrailing() throws {
        let (container, child) = makeHierarchy()
        defer { withExtendedLifetime(container) {} }

        let constraints = child.giniMakeConstraints { maker in
            maker.horizontal.equalToSuperview().constant(12)
        }

        #expect(constraints.count == 2)
        #expect(try constraint(for: .leading, in: constraints).constant == 12)
        #expect(try constraint(for: .trailing, in: constraints).constant == -12)
    }

    @Test("vertical creates top and bottom constraints with negated bottom constant")
    func verticalCreatesTopAndBottom() throws {
        let (container, child) = makeHierarchy()
        defer { withExtendedLifetime(container) {} }

        let constraints = child.giniMakeConstraints { maker in
            maker.vertical.equalToSuperview().constant(10)
        }

        #expect(constraints.count == 2)
        #expect(try constraint(for: .top, in: constraints).constant == 10)
        #expect(try constraint(for: .bottom, in: constraints).constant == -10)
    }

    @Test("center.equalToSuperview creates centerX and centerY constraints")
    func centerEqualToSuperviewCreatesCenterConstraints() throws {
        let (container, child) = makeHierarchy()

        let constraints = child.giniMakeConstraints { maker in
            maker.center.equalToSuperview()
        }

        #expect(constraints.count == 2)
        #expect(Set(constraints.map(\.firstAttribute)) == [.centerX, .centerY])
        for constraint in constraints {
            #expect(constraint.secondItem as? UIView === container)
        }
    }

    @Test("size.equalTo(constant) creates width and height dimension constraints")
    func sizeEqualToConstantCreatesDimensionConstraints() throws {
        let (container, child) = makeHierarchy()
        defer { withExtendedLifetime(container) {} }

        let constraints = child.giniMakeConstraints { maker in
            maker.size.equalTo(100)
        }

        #expect(constraints.count == 2)
        #expect(Set(constraints.map(\.firstAttribute)) == [.width, .height])
        for constraint in constraints {
            #expect(constraint.secondItem == nil)
            #expect(constraint.secondAttribute == .notAnAttribute)
            #expect(constraint.constant == 100)
        }
    }

    @Test("Compound equalTo(UIView) constrains every grouped attribute to that view")
    func compoundEqualToViewConstrainsAllAttributes() throws {
        let (container, child) = makeHierarchy()
        let sibling = UIView()
        container.addSubview(sibling)

        let constraints = child.giniMakeConstraints { maker in
            maker.edges.equalTo(sibling)
        }

        #expect(constraints.count == 4)
        for constraint in constraints {
            #expect(constraint.secondItem as? UIView === sibling)
        }
    }

    @Test("Compound equalTo(UILayoutGuide) constrains every grouped attribute to the guide")
    func compoundEqualToLayoutGuideConstrainsAllAttributes() throws {
        let (container, child) = makeHierarchy()

        let constraints = child.giniMakeConstraints { maker in
            maker.edges.equalTo(container.safeAreaLayoutGuide)
        }

        #expect(constraints.count == 4)
        for constraint in constraints {
            #expect(constraint.secondItem === container.safeAreaLayoutGuide)
        }
    }

    // MARK: - Current behavior (assert as-is; do not "fix" in production)

    /// Compound `priority(_:)` forwards to `GiniConstraintAttribute.priority`,
    /// which mutates `maker.constraints.last` — so all four calls hit the same
    /// (last-added) constraint. Only the last constraint's priority changes.
    /// Current behavior, asserted as-is.
    @Test("Compound priority only changes the last-added constraint (current behavior)")
    func compoundPriorityOnlyChangesLastConstraint() throws {
        let (container, child) = makeHierarchy()
        defer { withExtendedLifetime(container) {} }

        let constraints = child.giniMakeConstraints { maker in
            maker.edges.equalToSuperview().priority(.defaultHigh)
        }

        let lastConstraint = try #require(constraints.last)
        #expect(lastConstraint.priority == .defaultHigh)

        let otherConstraints = constraints.dropLast()
        for constraint in otherConstraints {
            #expect(constraint.priority == .required,
                    "Only the last constraint gets the compound priority today")
        }
    }
}
