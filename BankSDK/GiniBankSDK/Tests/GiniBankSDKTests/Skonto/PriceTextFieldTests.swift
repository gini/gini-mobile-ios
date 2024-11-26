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

    override func setUp() {
        super.setUp()
        priceTextField = PriceTextField(frame: .zero)
        priceTextField.priceDelegate = self
        priceTextField.text = formatValue(0)
    }

    override func tearDown() {
        priceTextField = nil
        priceTextChangeExpectation = nil
        super.tearDown()
    }

    func priceTextField(_ textField: PriceTextField, didChangePrice editedText: String) {
        priceTextChangeExpectation?.fulfill()
    }

    func testSingleDigitInput() {
        let input = "1"
        let expectedValue = formatValue(0.01)
        let expectation = expectation(description: "Price text change should be triggered")
        priceTextChangeExpectation = expectation
        simulateTextInput(input)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(priceTextField.text,
                       expectedValue,
                       "Expected formatted value of \(expectedValue) when user inputs '\(input)'")
    }

    func testMultipleDigitInput() {
        let input = "12345"
        let expectedValue = formatValue(123.45)

        simulateTextInput(input)
        XCTAssertEqual(priceTextField.text,
                       expectedValue,
                       "Expected formatted value of \(expectedValue) when user inputs '\(input)'")
    }

    func testMaxPositiveValue() {
        let input = "99999.99"
        let expectedValue = formatValue(99999.99)

        simulateTextInput(input)
        XCTAssertEqual(priceTextField.text,
                       expectedValue,
                       "Expected maximum positive value to be \(expectedValue)")
    }

    func testDeletingTwoDigits() {
        let input = "123456"
        let deleteCount = 2
        let expectedValue = formatValue(12.34)

        simulateTextInput(input)
        simulateDeleteAction(count: deleteCount)
        XCTAssertEqual(priceTextField.text,
                       expectedValue,
                       "Expected value to update to \(expectedValue) after deleting \(deleteCount) digits")
    }

    func testDeleteAllInput() {
        let input = "123456"
        let deleteCount = 6
        let expectedValue = formatValue(0.00)

        simulateTextInput(input)
        simulateDeleteAction(count: deleteCount)
        XCTAssertEqual(priceTextField.text,
                       expectedValue,
                       "Expected value to reset to \(expectedValue) after deleting all digits")
    }

    func testInputWithLeadingZeros() {
        let input = "00012345"
        let expectedValue = formatValue(123.45)

        simulateTextInput(input)
        XCTAssertEqual(priceTextField.text,
                       expectedValue,
                       "Expected leading zeros to be ignored, resulting in \(expectedValue)")
    }

    func testInputAfterDeletingDecimal() {
        let initialInput = "123456"
        let deleteCount = 2
        let additionalInput = "12"
        let expectedValue = formatValue(1234.12)

        simulateTextInput(initialInput)
        simulateDeleteAction(count: deleteCount)
        simulateTextInput(additionalInput)
        XCTAssertEqual(priceTextField.text,
                       expectedValue,
                       "Expected value to update to \(expectedValue) after adding digits following deletion")
    }

    func testMixedInputWithInvalidCharacters() {
        let input = "1asd234fdsf5gfd6"
        let expectedValue = formatValue(1234.56)

        simulateTextInput(input)
        XCTAssertEqual(priceTextField.text,
                       expectedValue,
                       "Expected non-numeric characters to be ignored, resulting in \(expectedValue)")
    }

    func testInputWithDoubleCommas() {
        let input = "1234,,56"
        let expectedValue = formatValue(1234.56)

        simulateTextInput(input)
        XCTAssertEqual(priceTextField.text,
                       expectedValue,
                       "Expected commas to be ignored, resulting in \(expectedValue)")
    }

    func testAllZerosInput() {
        let input = "00000000"
        let expectedValue = formatValue(0.00)

        simulateTextInput(input)
        XCTAssertEqual(priceTextField.text,
                       expectedValue,
                       "Expected value to remain \(expectedValue) when input consists only of zeros")
    }

    func testInputWithSpaces() {
        let input = "12 34 56"
        let expectedValue = formatValue(1234.56)

        simulateTextInput(input)
        XCTAssertEqual(priceTextField.text,
                       expectedValue,
                       "Expected spaces to be ignored, resulting in \(expectedValue)")
    }

    func testNegativeValueInput() {
        let input = "-12345"
        let expectedValue = formatValue(123.45)

        simulateTextInput(input)
        XCTAssertEqual(priceTextField.text,
                       expectedValue,
                       "Expected negative sign to be ignored, resulting in \(expectedValue)")
    }

    // Helper methods for simulating text input and formatting values
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
