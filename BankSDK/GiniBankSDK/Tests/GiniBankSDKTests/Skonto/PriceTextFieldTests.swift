//
//  PriceTextFieldTests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniBankSDK

class PriceTextFieldTests: XCTestCase, PriceTextFieldDelegate {

    var priceTextField: PriceTextField!
    var priceTextChangeExpectation: XCTestExpectation?
    var changedText: String?

    override func setUp() {
        super.setUp()
        priceTextField = PriceTextField(frame: .zero)
        priceTextField.priceDelegate = self
        priceTextField.text = formatValue(0)
    }

    override func tearDown() {
        priceTextField = nil
        changedText = nil
        priceTextChangeExpectation = nil
        super.tearDown()
    }

    func priceTextField(_ textField: PriceTextField, didChangePrice editedText: String) {
        changedText = editedText
        priceTextChangeExpectation?.fulfill()
    }

    func testSingleDigitInput() {
        priceTextChangeExpectation = expectation(description: "Price text change should be triggered")
        simulateTextInput("1")
        let expectedValue = formatValue(0.01)
        wait(for: [priceTextChangeExpectation!], timeout: 1.0)
        XCTAssertEqual(priceTextField.text, expectedValue, "Expected formatted value of 0.01 when user inputs a single digit '1'")
    }

    func testMultipleDigitInput() {
        simulateTextInput("12345")
        let expectedValue = formatValue(123.45)
        XCTAssertEqual(priceTextField.text, expectedValue, "Expected formatted value of 123.45 when user inputs '12345'")
    }

    func testExceedingMaxDigitsBeforeDecimal() {
        simulateTextInput("123456789")
        let expectedValue = formatValue(12345.67)
        XCTAssertEqual(priceTextField.text, expectedValue, "Expected value to stop at 5 digits before the decimal point: 12345.67")
    }

    func testMaxPositiveValue() {
        simulateTextInput("99999.99")
        let expectedValue = formatValue(99999.99)
        XCTAssertEqual(priceTextField.text, expectedValue, "Expected maximum positive value to be 99999.99")
    }

    func testValueCappedAtMaxDigits() {
        simulateTextInput("100000.00")
        let expectedValue = formatValue(10000.00)
        XCTAssertEqual(priceTextField.text, expectedValue, "Expected value to be capped at 10000.00 after input exceeding max digits")
    }

    func testDeletingTwoDigits() {
        simulateTextInput("123456")
        simulateDeleteAction(count: 2)
        let expectedValue = formatValue(12.34)
        XCTAssertEqual(priceTextField.text, expectedValue, "Expected value to update to 12.34 after deleting two digits")
    }

    func testDeleteAllInput() {
        simulateTextInput("123456")
        simulateDeleteAction(count: 6)
        let expectedValue = formatValue(0.00)
        XCTAssertEqual(priceTextField.text, expectedValue, "Expected value to reset to 0.00 after deleting all digits")
    }

    func testInputWithLeadingZeros() {
        simulateTextInput("00012345")
        let expectedValue = formatValue(123.45)
        XCTAssertEqual(priceTextField.text, expectedValue, "Expected leading zeros to be ignored, resulting in 123.45")
    }

    func testInputAfterDeletingDecimal() {
        simulateTextInput("123456")
        simulateDeleteAction(count: 2)
        simulateTextInput("12")
        let expectedValue = formatValue(1234.12)
        XCTAssertEqual(priceTextField.text, expectedValue, "Expected value to update to 1234.12 after adding digits following deletion")
    }

    func testMixedInputWithInvalidCharacters() {
        simulateTextInput("1asd234fdsf5gfd6")
        let expectedValue = formatValue(1234.56)
        XCTAssertEqual(priceTextField.text, expectedValue, "Expected non-numeric characters to be ignored, resulting in 1234.56")
    }

    func testInputWithDoubleCommas() {
        simulateTextInput("1234,,56")
        let expectedValue = formatValue(1234.56)
        XCTAssertEqual(priceTextField.text, expectedValue, "Expected commas to be ignored, resulting in 1234.56")
    }

    func testInputWithExcessiveTrailingZeros() {
        simulateTextInput("123400000000")
        let expectedValue = formatValue(12340.00)
        XCTAssertEqual(priceTextField.text, expectedValue, "Expected trailing zeros after the decimal point to be handled, resulting in 12340.00")
    }

    func testAllZerosInput() {
        simulateTextInput("00000000")
        let expectedValue = formatValue(0.00)
        XCTAssertEqual(priceTextField.text, expectedValue, "Expected value to remain 0.00 when input consists only of zeros")
    }

    private func simulateTextInput(_ input: String) {
        for char in input {
            let currentText = priceTextField.text ?? ""
            let range = NSRange(location: currentText.count, length: 0)
            _ = priceTextField.textField(priceTextField, shouldChangeCharactersIn: range, replacementString: String(char))
        }
    }

    private func simulateDeleteAction(count: Int) {
        for _ in 0..<count {
            let currentText = priceTextField.text ?? ""
            let range = NSRange(location: currentText.count - 1, length: 1)
            _ = priceTextField.textField(priceTextField, shouldChangeCharactersIn: range, replacementString: "")
        }
    }

    private func formatValue(_ value: Double) -> String {
        return NumberFormatter.twoDecimalPriceFormatter.string(from: NSNumber(value: value)) ?? ""
    }
}
