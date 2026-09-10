//
//  PriceLabelViewInputTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import Testing
import UIKit
@testable import GiniBankSDK

extension GiniConfigurationSharedStateSuite {

    /**
     Covers `PriceLabelView`'s `UITextFieldDelegate` amount-input path: digits-only
     filtering, the seven-digit cap, cents-to-price formatting, the delegate return
     value, and the `priceLabelViewTextFieldDidChange(on:)` callback delivery.

     Nested in the shared-state suite because `PriceLabelView` reads fonts from
     `GiniBankConfiguration.shared` during layout.
     */
    @Suite("PriceLabelView input")
    @MainActor
    struct PriceLabelViewInputTests {

        // MARK: - Insertion

        @Test("A single digit typed into an empty field is formatted as one cent and blocks the system update")
        func singleDigitInsertsAsCents() throws {
            let (view, textField, spy) = makeView(withText: "")

            let handled = view.textField(textField,
                                         shouldChangeCharactersIn: NSRange(location: 0, length: 0),
                                         replacementString: "1")

            #expect(handled == false, "The delegate handled the change itself, so it must block the system update")
            #expect(textField.text == (try format("0.01")))
            #expect(spy.changeCount == 1)
        }

        @Test("Typing five digits builds up as 123.45")
        func multipleDigitsBuildUpAsCents() throws {
            let (view, textField, spy) = makeView(withText: "")

            simulateInput("12345", on: view, into: textField)

            #expect(textField.text == (try format("123.45")))
            #expect(spy.changeCount == 5)
        }

        // MARK: - Seven-digit cap

        @Test("Digits beyond the seven-digit cap are silently dropped")
        func capsAtSevenDigits() throws {
            let (view, textField, spy) = makeView(withText: "")

            simulateInput("99999999", on: view, into: textField)

            #expect(textField.text == (try format("99999.99")),
                    "Only the first seven digits should shape the amount")
            #expect(spy.changeCount == 8,
                    "Every attempted change still notifies the delegate, even when the formatted value is unchanged")
        }

        // MARK: - Invalid input

        @Test("Non-digit characters are stripped before formatting")
        func nonDigitsAreFilteredOut() throws {
            let (view, textField, _) = makeView(withText: "")

            simulateInput("1a2b3c", on: view, into: textField)

            #expect(textField.text == (try format("1.23")))
        }

        // MARK: - Deletion

        @Test("Deleting the trailing digit shifts the cents one place down")
        func deletionShiftsCentsDown() throws {
            let (view, textField, _) = makeView(withText: "")
            simulateInput("12345", on: view, into: textField)

            let currentText = try #require(textField.text)
            let range = NSRange(location: currentText.count - 1, length: 1)
            _ = view.textField(textField,
                               shouldChangeCharactersIn: range,
                               replacementString: "")

            #expect(textField.text == (try format("12.34")))
        }

        // MARK: - Delegate callback count

        @Test("The delegate is notified exactly once per accepted change")
        func delegateFiresOncePerAcceptedChange() throws {
            let (view, textField, spy) = makeView(withText: try format("0.01"))

            let currentText = textField.text ?? ""
            _ = view.textField(textField,
                               shouldChangeCharactersIn: NSRange(location: currentText.count, length: 0),
                               replacementString: "5")

            #expect(spy.changeCount == 1)
        }

        // MARK: - Helpers

        private func makeView(withText text: String?) -> (PriceLabelView,
                                                          UITextField,
                                                          PriceLabelViewDelegateSpy) {
            let view = PriceLabelView(frame: .zero)
            let spy = PriceLabelViewDelegateSpy()
            view.delegate = spy
            let textField = UITextField()
            textField.text = text
            return (view, textField, spy)
        }

        private func simulateInput(_ input: String,
                                   on view: PriceLabelView,
                                   into textField: UITextField) {
            for character in input {
                let currentText = textField.text ?? ""
                let range = NSRange(location: currentText.count, length: 0)
                _ = view.textField(textField,
                                   shouldChangeCharactersIn: range,
                                   replacementString: String(character))
            }
        }

        private func format(_ decimalString: String) throws -> String {
            let value = try #require(Decimal(string: decimalString),
                                     "Test fixture '\(decimalString)' is not a valid Decimal")
            return try #require(Price.stringWithoutSymbol(from: value),
                                "Price.stringWithoutSymbol should format the fixture")
        }
    }
}

private final class PriceLabelViewDelegateSpy: PriceLabelViewDelegate {
    var changeCount = 0
    var showCurrencyPickerCount = 0

    func priceLabelViewTextFieldDidChange(on: PriceLabelView) {
        changeCount += 1
    }

    func showCurrencyPicker(on view: UIView) {
        showCurrencyPickerCount += 1
    }
}
