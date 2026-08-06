//
//  DigitalLineItemTableViewCellTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import UIKit
@testable import GiniBankSDK

@Suite("DigitalLineItemTableViewCell nib loading")
@MainActor
struct DigitalLineItemTableViewCellTests {

    /// Value the source sets on iOS 26+ via the Liquid Glass availability branch.
    private let liquidGlassTrailingConstant: CGFloat = 23

    @Test("Cell instantiates from its xib and configures the mode-switch trailing constraint")
    func cellInstantiatesFromNib() throws {
        let nib = UINib(nibName: "DigitalLineItemTableViewCell", bundle: giniBankBundle())

        let cell = try #require(
            nib.instantiate(withOwner: nil, options: nil)
                .compactMap { $0 as? DigitalLineItemTableViewCell }
                .first,
            "Nib should produce a DigitalLineItemTableViewCell"
        )

        // The outlet must be wired up so the availability branch in setup() has
        // something to mutate.
        #expect(cell.modeSwitchTrailingConstraint != nil)

        if #available(iOS 26.0, *) {
            #expect(cell.modeSwitchTrailingConstraint.constant == liquidGlassTrailingConstant,
                    "iOS 26+ should bump trailing padding to the Liquid Glass constant")
        }
    }
}
