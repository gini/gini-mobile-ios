//
//  DecimalExtensionTests.swift
//  
//
//  Created by David Vizaknai on 04.04.2023.
//

import XCTest

class DecimalExtensionTests: XCTestCase {
    func testStringValueFromTwoDecimals() {
        let decimalValue: Decimal = 8.28
        let decimalString = decimalValue.stringValue(withDecimalPoint: 2)
        XCTAssertEqual(decimalString, "8.28", "Decimal string value is not equal to expected string value.")
    }

    func testStringValueFromWholeNumber() {
        let decimalValue: Decimal = 5
        let decimalString = decimalValue.stringValue(withDecimalPoint: 2)
        XCTAssertEqual(decimalString, "5.00", "Decimal string value is not equal to expected string value.")
    }

    func testStringValueFromOneDecimal() {
        let decimalValue: Decimal = 210.3
        let decimalString = decimalValue.stringValue(withDecimalPoint: 2)
        XCTAssertEqual(decimalString, "210.30", "Decimal string value is not equal to expected string value.")
    }

    func testStringValueFromTwoDecimals2() {
        let decimalValue: Decimal = 1000.09
        let decimalString = decimalValue.stringValue(withDecimalPoint: 2)
        XCTAssertEqual(decimalString, "1000.09", "Decimal string value is not equal to expected string value.")
    }

    func testStringValueFromTwoDecimals3() {
        let decimalValue: Decimal = 200.37
        let decimalString = decimalValue.stringValue(withDecimalPoint: 2)
        XCTAssertEqual(decimalString, "200.37", "Decimal string value is not equal to expected string value.")
    }

    func testStringValueFromTwoDecimals4() {
        let decimalValue: Decimal = 999.35
        let decimalString = decimalValue.stringValue(withDecimalPoint: 2)
        XCTAssertEqual(decimalString, "999.35", "Decimal string value is not equal to expected string value.")
    }

    func testStringValueFromTwoDecimals5() {
        let decimalValue: Decimal = 0.09
        let decimalString = decimalValue.stringValue(withDecimalPoint: 2)
        XCTAssertEqual(decimalString, "0.09", "Decimal string value is not equal to expected string value.")
    }
}
