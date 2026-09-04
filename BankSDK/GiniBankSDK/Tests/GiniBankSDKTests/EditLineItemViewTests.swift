//
//  EditLineItemViewTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import Testing
import UIKit
@testable import GiniBankSDK
@testable import GiniCaptureSDK

extension GiniConfigurationSharedStateSuite {

    /**
     Covers `EditLineItemView`: data population from the view model, save
     validation with inline error views, error clearing on text changes,
     the accessibility element composition and the currency picker delegate.

     Nested in the shared-state suite because the view and its subviews read
     fonts from `GiniBankConfiguration.shared`.
     */
    @Suite("EditLineItemView")
    @MainActor
    struct EditLineItemViewTests {

        // MARK: - Data population

        @Test("Setting the view model populates name, price, currency and quantity")
        func viewModelPopulatesFields() throws {
            let (view, viewModel, _) = try makeViewWithFixtureLineItem()

            #expect(try nameLabelView(in: view).text == viewModel.name)
            #expect(try priceLabelView(in: view).priceValue == viewModel.price)
            #expect(try priceLabelView(in: view).currencyValue == viewModel.currency)
            #expect(try quantityView(in: view).quantity == viewModel.quantity)
        }

        // MARK: - Saving

        @Test("Tapping save with valid name and price forwards the exact values")
        func saveWithValidValuesForwardsExactValues() throws {
            let (view, _, delegate) = try makeViewWithFixtureLineItem()

            try saveButton(in: view).triggerTouchUpInside()

            let saved = try #require(delegate.savedLineItems.first,
                                     "Save should reach the view model delegate for valid input")
            #expect(saved.name == "Nike Sportswear Air Max 97 - Sneaker")
            #expect(saved.price.value == Decimal(string: "10.99"))
            #expect(saved.price.currencyCode == "eur")
            #expect(saved.quantity == 2)
            #expect(try errorViews(in: view).name.alpha == 0)
            #expect(try errorViews(in: view).price.alpha == 0)
        }

        @Test("Tapping save with a whitespace-only name shows the name error and does not save")
        func saveWithInvalidNameShowsErrorAndDoesNotSave() throws {
            let lineItem = makeLineItem(name: "   ", price: Decimal(10))
            let (view, _, delegate) = makeView(with: lineItem)

            try saveButton(in: view).triggerTouchUpInside()

            #expect(delegate.savedLineItems.isEmpty,
                    "An invalid name must not trigger a save")
            #expect(try errorViews(in: view).name.alpha == 1,
                    "The name error view should become visible")
            #expect(try errorViews(in: view).price.alpha == 0,
                    "The price error view should stay hidden for a valid price")
        }

        @Test("Tapping save with a non-positive price shows the price error and does not save")
        func saveWithInvalidPriceShowsErrorAndDoesNotSave() throws {
            let lineItem = makeLineItem(name: "Valid name", price: .zero)
            let (view, _, delegate) = makeView(with: lineItem)

            try saveButton(in: view).triggerTouchUpInside()

            #expect(delegate.savedLineItems.isEmpty,
                    "A non-positive price must not trigger a save")
            #expect(try errorViews(in: view).price.alpha == 1,
                    "The price error view should become visible")
            #expect(try errorViews(in: view).name.alpha == 0,
                    "The name error view should stay hidden for a valid name")
        }

        @Test("Tapping save with both fields invalid shows both errors")
        func saveWithBothFieldsInvalidShowsBothErrors() throws {
            let lineItem = makeLineItem(name: nil, price: .zero)
            let (view, _, delegate) = makeView(with: lineItem)

            try saveButton(in: view).triggerTouchUpInside()

            #expect(delegate.savedLineItems.isEmpty)
            #expect(try errorViews(in: view).name.alpha == 1)
            #expect(try errorViews(in: view).price.alpha == 1)
        }

        // MARK: - Error clearing

        @Test("Changing the name text clears the name error")
        func nameTextChangeClearsNameError() throws {
            let lineItem = makeLineItem(name: "  ", price: Decimal(10))
            let (view, _, _) = makeView(with: lineItem)
            try saveButton(in: view).triggerTouchUpInside()
            #expect(try errorViews(in: view).name.alpha == 1, "Precondition: error should be shown")

            let nameView = try nameLabelView(in: view)
            nameView.text = "New valid name"
            view.nameLabelViewTextFieldDidChange(on: nameView)

            #expect(try errorViews(in: view).name.alpha == 0,
                    "Typing a non-empty name should clear the name error")
        }

        @Test("Changing the price text to a positive value clears the price error")
        func priceTextChangeClearsPriceError() throws {
            let lineItem = makeLineItem(name: "Valid name", price: .zero)
            let (view, _, _) = makeView(with: lineItem)
            try saveButton(in: view).triggerTouchUpInside()
            #expect(try errorViews(in: view).price.alpha == 1, "Precondition: error should be shown")

            let priceView = try priceLabelView(in: view)
            priceView.priceValue = Decimal(string: "5.00")!
            view.priceLabelViewTextFieldDidChange(on: priceView)

            #expect(try errorViews(in: view).price.alpha == 0,
                    "Entering a positive price should clear the price error")
        }

        // MARK: - Accessibility composition

        @Test("Accessibility elements exclude the error views while they are transparent")
        func accessibilityExcludesTransparentErrorViews() throws {
            let (view, _, _) = try makeViewWithFixtureLineItem()

            let elements = try #require(view.accessibilityElements)

            /// Current behavior: cancel, title, save, name, price and quantity — errors at alpha 0 are excluded.
            #expect(elements.count == 6)
            #expect(elements[0] is UIButton)
            #expect(elements[1] is UILabel)
            #expect(elements[2] is UIButton)
            #expect(elements[3] is NameLabelView)
            #expect(elements[4] is PriceLabelView)
            #expect(elements[5] is QuantityView)
        }

        @Test("Recomputing accessibility after validation errors includes the visible error views")
        func accessibilityIncludesVisibleErrorViews() throws {
            let lineItem = makeLineItem(name: nil, price: .zero)
            let (view, _, _) = makeView(with: lineItem)
            try saveButton(in: view).triggerTouchUpInside()

            /// Current behavior: `setupAccessibility` is only re-evaluated when called explicitly.
            let elementsBeforeRecompute = try #require(view.accessibilityElements)
            #expect(elementsBeforeRecompute.count == 6,
                    "Showing errors does not automatically refresh the accessibility elements")

            view.setupAccessibility()

            let elements = try #require(view.accessibilityElements)
            #expect(elements.count == 8,
                    "Both visible error views should join the accessibility elements")
            #expect(elements.contains { $0 is ErrorView })
        }

        // MARK: - Currency picker

        @Test("Picking a currency updates the price label currency value")
        func currencyPickerSelectionUpdatesPriceLabel() throws {
            let (view, _, _) = try makeViewWithFixtureLineItem()

            view.currencyPickerDidPick("usd", on: CurrencyPickerView())

            #expect(try priceLabelView(in: view).currencyValue == "usd")
        }

        @Test("Requesting the currency picker shows it above the price view")
        func showCurrencyPickerMakesPickerVisible() throws {
            let (view, _, _) = try makeViewWithFixtureLineItem()

            view.showCurrencyPicker(on: try priceLabelView(in: view))

            let picker = try #require(view.subviews.compactMap { $0 as? CurrencyPickerView }.first,
                                      "The currency picker should be added to the view")
            #expect(picker.alpha == 1)
        }

        // MARK: - Helpers

        private func makeViewWithFixtureLineItem() throws -> (EditLineItemView,
                                                              EditLineItemViewModel,
                                                              MockEditLineItemViewModelDelegate) {
            makeView(with: try ExtractionResultFixture.lineItem(at: 0))
        }

        private func makeView(with lineItem: DigitalInvoice.LineItem) -> (EditLineItemView,
                                                                          EditLineItemViewModel,
                                                                          MockEditLineItemViewModelDelegate) {
            let viewModel = EditLineItemViewModel(lineItem: lineItem, index: 0)
            let delegate = MockEditLineItemViewModelDelegate()
            viewModel.delegate = delegate
            let view = EditLineItemView()
            view.viewModel = viewModel
            return (view, viewModel, delegate)
        }

        private func makeLineItem(name: String?, price: Decimal) -> DigitalInvoice.LineItem {
            DigitalInvoice.LineItem(name: name,
                                    quantity: 1,
                                    price: Price(value: price, currencyCode: "eur"),
                                    selectedState: .selected)
        }

        private func accessibilityElement<Element>(_ elementType: Element.Type,
                                                   at index: Int,
                                                   in view: EditLineItemView) throws -> Element {
            let elements = try #require(view.accessibilityElements)
            try #require(elements.indices.contains(index))
            return try #require(elements[index] as? Element)
        }

        private func saveButton(in view: EditLineItemView) throws -> UIButton {
            try accessibilityElement(UIButton.self, at: 2, in: view)
        }

        private func nameLabelView(in view: EditLineItemView) throws -> NameLabelView {
            try accessibilityElement(NameLabelView.self, at: 3, in: view)
        }

        private func priceLabelView(in view: EditLineItemView) throws -> PriceLabelView {
            try accessibilityElement(PriceLabelView.self, at: 4, in: view)
        }

        private func quantityView(in view: EditLineItemView) throws -> QuantityView {
            try accessibilityElement(QuantityView.self, at: 5, in: view)
        }

        private func errorViews(in view: EditLineItemView) throws -> (name: ErrorView, price: ErrorView) {
            let stackView = try #require(view.subviews.compactMap { $0 as? UIStackView }.first,
                                         "EditLineItemView should lay out its fields in a stack view")
            try #require(stackView.arrangedSubviews.count >= 2)
            let nameError = try #require(stackView.arrangedSubviews[0].subviews
                                            .compactMap { $0 as? ErrorView }.first,
                                         "The name container should hold an error view")
            let priceError = try #require(stackView.arrangedSubviews[1].subviews
                                             .compactMap { $0 as? ErrorView }.first,
                                          "The price container should hold an error view")
            return (nameError, priceError)
        }
    }
}
