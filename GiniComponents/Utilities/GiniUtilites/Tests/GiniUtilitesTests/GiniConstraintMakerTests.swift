//
//  GiniConstraintMakerTests.swift
//  GiniUtilitesTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import UIKit
@testable import GiniUtilites

@Suite("GiniConstraintMaker — attribute accessors and lookup")
@MainActor
struct GiniConstraintMakerTests {

    /**
     Resolves the maker property matching the given layout attribute so the
     accessor tests can be parameterized instead of duplicated per attribute.
     */
    private func attributeAccessor(for attribute: NSLayoutConstraint.Attribute,
                                   on maker: GiniConstraintMaker) -> GiniConstraintAttribute? {
        switch attribute {
        case .top: return maker.top
        case .bottom: return maker.bottom
        case .leading: return maker.leading
        case .trailing: return maker.trailing
        case .left: return maker.left
        case .right: return maker.right
        case .centerX: return maker.centerX
        case .centerY: return maker.centerY
        case .width: return maker.width
        case .height: return maker.height
        default: return nil
        }
    }

    @Test("Each single-attribute accessor exposes the matching layout attribute and view",
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
    func singleAttributeAccessorExposesMatchingAttribute(attribute: NSLayoutConstraint.Attribute) throws {
        let view = UIView()
        let maker = GiniConstraintMaker(view: view)

        let constraintAttribute = try #require(attributeAccessor(for: attribute, on: maker))

        #expect(constraintAttribute.attribute == attribute)
        #expect(constraintAttribute.view === view)
        #expect(constraintAttribute.maker === maker)
    }

    @Test("Compound accessors group the expected single attributes")
    func compoundAccessorsGroupExpectedAttributes() {
        let maker = GiniConstraintMaker(view: UIView())

        #expect(maker.edges.attributes.map(\.attribute) == [.top, .bottom, .leading, .trailing])
        #expect(maker.center.attributes.map(\.attribute) == [.centerX, .centerY])
        #expect(maker.size.attributes.map(\.attribute) == [.width, .height])
        #expect(maker.horizontal.attributes.map(\.attribute) == [.leading, .trailing])
        #expect(maker.vertical.attributes.map(\.attribute) == [.top, .bottom])
    }

    @Test("constraint(for:) returns the first constraint created for the given attribute")
    func constraintForAttributeReturnsCreatedConstraint() throws {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let child = UIView()
        container.addSubview(child)

        var capturedMaker: GiniConstraintMaker?
        child.giniMakeConstraints { maker in
            maker.top.equalToSuperview().constant(8)
            maker.width.equalTo(44)
            capturedMaker = maker
        }

        let maker = try #require(capturedMaker)
        let topConstraint = try #require(maker.constraint(for: .top))
        #expect(topConstraint.firstAttribute == .top)
        #expect(topConstraint.constant == 8)

        let widthConstraint = try #require(maker.constraint(for: .width))
        #expect(widthConstraint.constant == 44)
    }

    @Test("constraint(for:) returns nil when no constraint exists for the attribute")
    func constraintForAttributeReturnsNilWhenMissing() {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let child = UIView()
        container.addSubview(child)

        var capturedMaker: GiniConstraintMaker?
        child.giniMakeConstraints { maker in
            maker.width.equalTo(44)
            capturedMaker = maker
        }

        #expect(capturedMaker?.constraint(for: .bottom) == nil)
    }
}
