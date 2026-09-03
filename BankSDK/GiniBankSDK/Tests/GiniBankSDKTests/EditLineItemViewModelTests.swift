//
//  EditLineItemViewModelTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import Testing
@testable import GiniBankSDK
@testable import GiniCaptureSDK

@Suite("EditLineItemViewModel")
struct EditLineItemViewModelTests {

    // MARK: - Exposed values

    @Test("Exposes the line item values and index")
    func exposesLineItemValues() throws {
        let lineItem = try ExtractionResultFixture.lineItem(at: 0)
        let viewModel = EditLineItemViewModel(lineItem: lineItem, index: 3)

        #expect(viewModel.name == "Nike Sportswear Air Max 97 - Sneaker")
        #expect(viewModel.price == Decimal(string: "10.99"))
        #expect(viewModel.currency == "eur")
        #expect(viewModel.quantity == 2)
        #expect(viewModel.index == 3)
    }

    // MARK: - Saving

    @Test("Saving with changed values forwards the updated line item to the delegate")
    func saveForwardsUpdatedLineItem() throws {
        let lineItem = try ExtractionResultFixture.lineItem(at: 0)
        let viewModel = EditLineItemViewModel(lineItem: lineItem, index: 0)
        let delegate = MockEditLineItemViewModelDelegate()
        viewModel.delegate = delegate

        viewModel.didTapSave(name: "Adidas Runner",
                             price: Decimal(string: "20.50")!,
                             currency: "usd",
                             quantity: 5)

        let saved = try #require(delegate.savedLineItems.first,
                                 "The delegate should receive the saved line item")
        #expect(saved.name == "Adidas Runner")
        #expect(saved.price.value == Decimal(string: "20.50"))
        #expect(saved.price.currencyCode == "usd")
        #expect(saved.quantity == 5)
    }

    @Test("Saving records which fields changed for analytics",
          arguments: [(name: "Changed name", price: "10.99", quantity: 2, expected: ["name"]),
                      (name: "Nike Sportswear Air Max 97 - Sneaker", price: "99.99", quantity: 2, expected: ["price"]),
                      (name: "Nike Sportswear Air Max 97 - Sneaker", price: "10.99", quantity: 7, expected: ["quantity"]),
                      (name: "Changed name", price: "99.99", quantity: 7, expected: ["name", "price", "quantity"])])
    func saveTracksChangedItems(input: (name: String,
                                        price: String,
                                        quantity: Int,
                                        expected: [String])) throws {
        let lineItem = try ExtractionResultFixture.lineItem(at: 0)
        let viewModel = EditLineItemViewModel(lineItem: lineItem, index: 0)
        let delegate = MockEditLineItemViewModelDelegate()
        viewModel.delegate = delegate

        viewModel.didTapSave(name: input.name,
                             price: Decimal(string: input.price)!,
                             currency: "eur",
                             quantity: input.quantity)

        #expect(viewModel.itemsChanged.map(\.rawValue) == input.expected)
        #expect(delegate.savedLineItems.count == 1)
    }

    @Test("Saving with unchanged values records no changed items")
    func saveWithUnchangedValuesTracksNothing() throws {
        let lineItem = try ExtractionResultFixture.lineItem(at: 0)
        let viewModel = EditLineItemViewModel(lineItem: lineItem, index: 0)
        let delegate = MockEditLineItemViewModelDelegate()
        viewModel.delegate = delegate

        viewModel.didTapSave(name: viewModel.name,
                             price: viewModel.price,
                             currency: viewModel.currency,
                             quantity: viewModel.quantity)

        #expect(viewModel.itemsChanged.isEmpty,
                "Saving identical values should not be tracked as a change")
        #expect(delegate.savedLineItems.count == 1,
                "The delegate should still be notified about the save")
    }

    // MARK: - Cancelling

    @Test("Cancelling forwards to the delegate without saving")
    func cancelForwardsToDelegate() throws {
        let lineItem = try ExtractionResultFixture.lineItem(at: 0)
        let viewModel = EditLineItemViewModel(lineItem: lineItem, index: 0)
        let delegate = MockEditLineItemViewModelDelegate()
        viewModel.delegate = delegate

        viewModel.didTapCancel()

        #expect(delegate.cancelCallCount == 1)
        #expect(delegate.savedLineItems.isEmpty)
    }
}
