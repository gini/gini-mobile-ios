//
//  IBANRecogniserTests.swift
//  
//
//  Created by Nadya Karaban on 09.10.23.
//

import Foundation
@testable import GiniCaptureSDK
import XCTest
final class IBANRecogniserTests: XCTestCase {

    func testIBANRecogniserWithEmptyString() {
        let emptyIbans = extractIBANS(string: "")
        XCTAssertEqual(emptyIbans, [], "returns empty list when no IBAN found")
    }

    func testIBANRecogniserWithWhiteSpaces() {
        let expectedIBANs : [String] = ["DE16700202700005713153"]
        let text = GiniCaptureTestsHelper.loadTextFromFile(named: "o2doc2-dookuid-8645")
        let extractedIBANs = extractIBANS(string: text)
        XCTAssertEqual(expectedIBANs, extractedIBANs, "IBANs should be equal")
    }

    func testShortIBANRecogniserWithManyWhiteSpaces() {
        let expectedIBANs : [String] = ["BE34817181591890", "NO9386011117947"]
        let text = "BE34817181591890, NO93 8601 1117 947 "
        let extractedIBANs = extractIBANS(string: text)
        XCTAssertEqual(expectedIBANs, extractedIBANs, "IBANs should be equal")
    }

    func testIBANRecogniserWithWhiteSpaces2() {
        let expectedIBANs : [String] = ["DE28430609672032163700"]
        let text = GiniCaptureTestsHelper.loadTextFromFile(named: "smantix_1756-dookuid-281")
        let extractedIBANs = extractIBANS(string: text)
        XCTAssertEqual(expectedIBANs, extractedIBANs, "IBANs should be equal")
    }

    func testIBANRecogniserWithMultipleIBANs() {
        let expectedIBANs : [String] = ["DE50700100800014060800", "DE64700202700000088811", "DE23701500000000109850"]
        let text = GiniCaptureTestsHelper.loadTextFromFile(named: "samplecontract-dookuid-380")
        let extractedIBANs = extractIBANS(string: text)
        XCTAssertEqual(expectedIBANs, extractedIBANs, "3 IBANs should be extracted")
    }

    func testIBANRecogniserWithFirstDetectedIBAN() {
        let expectedIBANS : [String] = ["DE50700100800014060800", "DE64700202700000088811", "DE23701500000000109850"]
        let text = GiniCaptureTestsHelper.loadTextFromFile(named: "samplecontract-dookuid-380")
        let extractedIBANs = extractIBANS(string: text)
        XCTAssertEqual(extractedIBANs[0], expectedIBANS[0], "3 IBANs should be extracted")
    }

    func testIBANRecogniserPreferGermanIBAN() {
        let expectedIBANs : [String] = ["DE92680800300672270200"]
        let text = GiniCaptureTestsHelper.loadTextFromFile(named: "dookuid-1311")
        let extractedIBANs = extractIBANS(string: text)
        XCTAssertEqual(expectedIBANs, extractedIBANs, "German IBAN should be preffered")
    }

    func testIBANRecogniserWithLetters() {
        let expectedIBANs : [String] = ["DE15500105171729472483"]
        let text = "DE15S00105171729472483"
        let extractedIBANs = extractIBANS(string: text)
        XCTAssertEqual(expectedIBANs, extractedIBANs, "IBANs should be equal")
    }
}

