//
//  UIViewConstraintsTests.swift
//  GiniUtilitesTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//
//  Covers the UIView Gini layout DSL entry points (giniMakeConstraints,
//  giniUpdateConstraints, giniRemakeConstraints), the anchor / safe-area
//  anchor properties, and the +/- offset operators producing
//  GiniConstraintTarget from GiniViewConstraintAttribute.

import Testing
import UIKit
@testable import GiniUtilites

@Suite("UIView+Constraints — Gini layout DSL entry points")
@MainActor
struct UIViewConstraintsTests {

    /// Builds a superview/subview pair ready for constraint installation.
    private func makeHierarchy() -> (container: UIView, child: UIView) {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let child = UIView()
        container.addSubview(child)
        return (container, child)
    }

    // MARK: - giniMakeConstraints

    @Test("giniMakeConstraints disables autoresizing translation and activates constraints")
    func makeConstraintsDisablesAutoresizingAndActivates() throws {
        let (container, child) = makeHierarchy()
        defer { withExtendedLifetime(container) {} }
        #expect(child.translatesAutoresizingMaskIntoConstraints == true)

        let constraints = child.giniMakeConstraints { maker in
            maker.width.equalTo(50)
            maker.height.equalTo(60)
        }

        #expect(child.translatesAutoresizingMaskIntoConstraints == false)
        #expect(constraints.count == 2)
        for constraint in constraints {
            #expect(constraint.isActive == true)
        }
    }

    @Test("giniMakeConstraints returns the constraints it created in declaration order")
    func makeConstraintsReturnsCreatedConstraints() throws {
        let (container, child) = makeHierarchy()
        defer { withExtendedLifetime(container) {} }

        let constraints = child.giniMakeConstraints { maker in
            maker.top.equalToSuperview()
            maker.width.equalTo(80)
        }

        #expect(constraints.map(\.firstAttribute) == [.top, .width])
    }

    // MARK: - giniUpdateConstraints

    @Test("giniUpdateConstraints does not change translatesAutoresizingMaskIntoConstraints")
    func updateConstraintsKeepsAutoresizingTranslation() {
        let (container, child) = makeHierarchy()
        defer { withExtendedLifetime(container) {} }
        #expect(child.translatesAutoresizingMaskIntoConstraints == true)

        child.giniUpdateConstraints { maker in
            maker.width.equalTo(50)
        }

        #expect(child.translatesAutoresizingMaskIntoConstraints == true)
    }

    /// `giniUpdateConstraints` does not update existing constraints — it stacks
    /// brand-new ones next to the old ones. Current behavior, asserted as-is.
    @Test("giniUpdateConstraints stacks new constraints instead of updating existing ones (current behavior)")
    func updateConstraintsStacksNewConstraints() throws {
        let (container, child) = makeHierarchy()
        defer { withExtendedLifetime(container) {} }

        let first = child.giniMakeConstraints { maker in
            maker.width.equalTo(50)
        }
        let second = child.giniUpdateConstraints { maker in
            maker.width.equalTo(70)
        }

        let firstConstraint = try #require(first.first)
        let secondConstraint = try #require(second.first)
        #expect(firstConstraint !== secondConstraint)
        #expect(firstConstraint.isActive == true, "The old constraint stays active alongside the new one")
        #expect(secondConstraint.isActive == true)

        let widthConstraints = child.constraints.filter { $0.firstAttribute == .width }
        #expect(widthConstraints.count == 2)
    }

    // MARK: - giniRemakeConstraints

    @Test("giniRemakeConstraints deactivates constraints held by the view and activates new ones")
    func remakeConstraintsDeactivatesViewHeldConstraints() throws {
        let (container, child) = makeHierarchy()
        defer { withExtendedLifetime(container) {} }

        let original = child.giniMakeConstraints { maker in
            maker.width.equalTo(50)
        }
        let remade = child.giniRemakeConstraints { maker in
            maker.height.equalTo(90)
        }

        let originalConstraint = try #require(original.first)
        #expect(originalConstraint.isActive == false)

        let remadeConstraint = try #require(remade.first)
        #expect(remadeConstraint.isActive == true)
        #expect(remadeConstraint.firstAttribute == .height)
    }

    /// `giniRemakeConstraints` only deactivates `self.constraints`, i.e.
    /// constraints installed on the view itself (dimensions). Constraints to the
    /// superview are held by the superview and survive a remake. Current
    /// behavior, asserted as-is.
    @Test("giniRemakeConstraints leaves superview-held constraints active (current behavior)")
    func remakeConstraintsLeavesSuperviewHeldConstraintsActive() throws {
        let (container, child) = makeHierarchy()
        defer { withExtendedLifetime(container) {} }

        let original = child.giniMakeConstraints { maker in
            maker.top.equalToSuperview()
        }
        child.giniRemakeConstraints { maker in
            maker.bottom.equalToSuperview()
        }

        let originalTopConstraint = try #require(original.first)
        #expect(originalTopConstraint.isActive == true,
                "Superview-held constraints are not removed by giniRemakeConstraints today")
    }

    // MARK: - Anchor properties

    /**
     Resolves the UIView anchor property matching the given layout attribute so
     the anchor tests can be parameterized instead of duplicated per attribute.
     */
    private func anchor(for attribute: NSLayoutConstraint.Attribute,
                        on view: UIView) -> GiniViewConstraintAttribute? {
        switch attribute {
        case .top: return view.top
        case .bottom: return view.bottom
        case .leading: return view.leading
        case .trailing: return view.trailing
        case .left: return view.left
        case .right: return view.right
        case .centerX: return view.centerX
        case .centerY: return view.centerY
        case .width: return view.width
        case .height: return view.height
        default: return nil
        }
    }

    @Test("Anchor properties expose the view itself with the matching attribute",
          arguments: [NSLayoutConstraint.Attribute.top,
                      .bottom,
                      .leading,
                      .trailing,
                      .left,
                      .right,
                      .centerX,
                      .centerY,
                      .width,
                      .height])
    func anchorPropertyExposesViewAndAttribute(attribute: NSLayoutConstraint.Attribute) throws {
        let view = UIView()

        let viewAttribute = try #require(anchor(for: attribute, on: view))

        #expect(viewAttribute.view === view)
        #expect(viewAttribute.attribute == attribute)
    }

    @Test("Safe-area anchors expose the safeAreaLayoutGuide with the matching attribute")
    func safeAreaAnchorsExposeSafeAreaLayoutGuide() {
        let view = UIView()

        #expect(view.safeTop.view === view.safeAreaLayoutGuide)
        #expect(view.safeTop.attribute == .top)
        #expect(view.safeBottom.view === view.safeAreaLayoutGuide)
        #expect(view.safeBottom.attribute == .bottom)
        #expect(view.safeLeading.view === view.safeAreaLayoutGuide)
        #expect(view.safeLeading.attribute == .leading)
        #expect(view.safeTrailing.view === view.safeAreaLayoutGuide)
        #expect(view.safeTrailing.attribute == .trailing)
    }

    // MARK: - GiniConstraintTarget operators

    @Test("The + operator wraps the attribute into a target with a positive constant")
    func plusOperatorCreatesTargetWithPositiveConstant() {
        let view = UIView()

        let target = view.leading + 16

        #expect(target.item === view)
        #expect(target.attribute == .leading)
        #expect(target.constant == 16)
    }

    @Test("The - operator wraps the attribute into a target with a negative constant")
    func minusOperatorCreatesTargetWithNegativeConstant() {
        let view = UIView()

        let target = view.bottom - 8

        #expect(target.item === view)
        #expect(target.attribute == .bottom)
        #expect(target.constant == -8)
    }

    @Test("GiniConstraintTarget defaults its constant to zero")
    func constraintTargetDefaultsConstantToZero() {
        let view = UIView()

        let target = GiniConstraintTarget(view, .centerX)

        #expect(target.item === view)
        #expect(target.attribute == .centerX)
        #expect(target.constant == 0)
    }
}
