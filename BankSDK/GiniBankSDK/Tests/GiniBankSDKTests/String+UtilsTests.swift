//
//  String+UtilsTests.swift
//  
//
//  Created by Nadya Karaban on 05.11.21.
//

import Foundation
import XCTest
@testable import GiniBankSDK

final class StringUtilsTests: XCTestCase {
    
    func testParseAmountStringToBackendFormat(){
        let amountToPay = "28"
        let parsedAmount = try! String.parseAmountStringToBackendFormat(string: "28.00")
        XCTAssertEqual(parsedAmount, amountToPay + ":EUR")
    }
    
    func testParseAmountStringToBackendFormat1(){
        let amountToPay = "28"
        let parsedAmount = try! String.parseAmountStringToBackendFormat(string: amountToPay)
        XCTAssertEqual(parsedAmount, amountToPay + ":EUR")
    }
    
    func testParseAmountStringToBackendFormat2(){
        let amountToPay = "28.12"
        let parsedAmount = try! String.parseAmountStringToBackendFormat(string: amountToPay)
        XCTAssertEqual(parsedAmount, amountToPay + ":EUR")
    }
    
    func testParseAmountStringToBackendFormat3(){
        let amountToPay = "28.1"
        let parsedAmount = try! String.parseAmountStringToBackendFormat(string: amountToPay)
        XCTAssertEqual(parsedAmount, amountToPay + ":EUR")
    }
    
    func testParseAmountStringToBackendFormat4(){
        let amountToPay = "28.10"
        let parsedAmount = try! String.parseAmountStringToBackendFormat(string: amountToPay)
        XCTAssertEqual(parsedAmount, "28.1:EUR")
    }
    
    func testParseAmountStringToBackendFormat5(){
        let amountToPay = "28.10:EUR"
        XCTAssertNotEqual(try? String.parseAmountStringToBackendFormat(string: amountToPay), "28.1:EUR")
    }
    
    func testParseAmountStringToBackendFormat6(){
        let amountToPay = "28,10"
        XCTAssertNotEqual(try? String.parseAmountStringToBackendFormat(string: amountToPay), "28.1:EUR")
    }
    
    func testParseAmountStringToBackendFormat7(){
        let amountToPay = "28.10:EUR"
        var giniBankError = GiniBankError.amountParsingError(amountString: "")
        do {
            try String.parseAmountStringToBackendFormat(string: amountToPay)
        } catch let error {
            giniBankError = error as! GiniBankError
        }
        XCTAssertEqual(giniBankError, GiniBankError.amountParsingError(amountString: "28.10:EUR"))
    }
}
