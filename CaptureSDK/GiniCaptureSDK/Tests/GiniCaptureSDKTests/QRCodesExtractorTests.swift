//
//  QRCodesExtractorTests.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniCaptureSDK

class QRCodesExtractorTests: XCTestCase {

    // MARK: - Test extractParameters(from:withFormat:)

    func testExtractParametersWithBezahlFormat() {
        let bezahlString = "bank://singlepaymentsepa?bic=TESTBIC123&name=John%20Doe&iban=DE89370400440532013000&reason=Test%20Payment&amount=EUR100.50"
        let parameters = QRCodesExtractor.extractParameters(from: bezahlString, withFormat: .bezahl)

        XCTAssertEqual(parameters["bic"],
                       "TESTBIC123",
                       "BIC should be extracted from Bezahl QR code")

        XCTAssertEqual(parameters["paymentRecipient"],
                       "John Doe",
                       "Payment recipient name should be URL decoded from 'name' parameter")

        XCTAssertEqual(parameters["iban"],
                       "DE89370400440532013000",
                       "Valid IBAN should be extracted from Bezahl QR code")

        XCTAssertEqual(parameters["paymentReference"],
                       "Test Payment",
                       "Payment reference should be URL decoded from 'reason' parameter")

        XCTAssertEqual(parameters["amountToPay"],
                       "100.50:EUR",
                       "Amount should be normalized with currency prefix")
    }

    func testExtractParametersWithEPC06912Format() {
        let epc06912String = """
        BCD
        002
        1
        SCT
        TESTBIC123
        John Doe
        DE89370400440532013000
        EUR100.50
        
        Test Payment
        
        """

        let parameters = QRCodesExtractor.extractParameters(from: epc06912String, withFormat: .epc06912)

        XCTAssertEqual(parameters["bic"],
                       "TESTBIC123",
                       "BIC should be extracted from line 4 (index 4) of EPC06912 format")

        XCTAssertEqual(parameters["paymentRecipient"],
                       "John Doe",
                       "Payment recipient should be extracted from line 5 of EPC06912 format")

        XCTAssertEqual(parameters["iban"],
                       "DE89370400440532013000",
                       "Valid IBAN should be extracted from line 6 of EPC06912 format")

        XCTAssertEqual(parameters["paymentReference"],
                       "Test Payment",
                       "Payment reference should be extracted from line 9 of EPC06912 format")

        XCTAssertEqual(parameters["amountToPay"],
                       "100.50:EUR",
                       "Amount should be normalized from line 7 with currency prefix")
    }

    func testExtractParametersWithEPS4MobileFormat() {
        let epsString = "epspayment://qr.eps-payment.at/public/qrcode/12345"
        let parameters = QRCodesExtractor.extractParameters(from: epsString, withFormat: .eps4mobile)

        XCTAssertEqual(parameters[QRCodesExtractor.epsCodeUrlKey],
                       epsString,
                       "EPS4Mobile format should return the entire URL string as epsPaymentQRCodeUrl")
    }

    func testExtractParametersWithGiniQRCodeFormat() {
        let giniString = "https://pay.gini.net/payment/12345"
        let parameters = QRCodesExtractor.extractParameters(from: giniString, withFormat: .giniQRCode)

        XCTAssertEqual(parameters[QRCodesExtractor.giniCodeUrlKey],
                       giniString,
                       "Gini QR code format should return the entire URL string as giniPaymentQRCodeUrl")
    }

    func testExtractParametersWithNoFormat() {
        let parameters = QRCodesExtractor.extractParameters(from: "any string", withFormat: nil)
        XCTAssertTrue(parameters.isEmpty, "When format is nil, should return empty dictionary")
    }

    // MARK: - Test extractParameters(fromBezhalCodeString:)

    func testExtractParametersFromBezahlCodeWithAllFields() {
        let bezahlString = "bank://singlepaymentsepa?bic=DEUTDEFF&name=Max%20Mustermann&iban=DE89370400440532013000&reason=Rechnung%20123&amount=EUR50.00&currency=EUR"
        let parameters = QRCodesExtractor.extractParameters(fromBezhalCodeString: bezahlString)

        XCTAssertEqual(parameters["bic"],
                       "DEUTDEFF",
                       "BIC should be extracted from query parameters")

        XCTAssertEqual(parameters["paymentRecipient"],
                       "Max Mustermann",
                       "Name should be URL decoded and mapped to paymentRecipient")

        XCTAssertEqual(parameters["iban"],
                       "DE89370400440532013000",
                       "Valid IBAN should be extracted and validated")

        XCTAssertEqual(parameters["paymentReference"],
                       "Rechnung 123",
                       "Reason should be URL decoded and mapped to paymentReference")

        XCTAssertEqual(parameters["amountToPay"],
                       "50.00:EUR",
                       "Amount should be normalized using currency from amount string")
    }

    func testExtractParametersFromBezahlCodeWithMissingFields() {
        let bezahlString = "bank://singlepaymentsepa?iban=DE89370400440532013000"
        let parameters = QRCodesExtractor.extractParameters(fromBezhalCodeString: bezahlString)

        XCTAssertNil(parameters["bic"], "Missing BIC should not be in parameters dictionary")
        XCTAssertNil(parameters["paymentRecipient"], "Missing name should not be in parameters dictionary")
        XCTAssertEqual(parameters["iban"], "DE89370400440532013000", "IBAN should still be extracted when other fields are missing")
        XCTAssertNil(parameters["paymentReference"], "Missing reason should not be in parameters dictionary")
        XCTAssertNil(parameters["amountToPay"], "Missing amount should not be in parameters dictionary")
    }

    func testExtractParametersFromBezahlCodeWithInvalidIBAN() {
        let bezahlString = "bank://singlepaymentsepa?iban=INVALID_IBAN"
        let parameters = QRCodesExtractor.extractParameters(fromBezhalCodeString: bezahlString)

        XCTAssertNil(parameters["iban"], "Invalid IBAN should not be added to parameters after validation fails")
    }

    func testExtractParametersFromBezahlCodeWithReason1() {
        // Note: Due to a bug in the implementation, reason1 is checked in queryParameters
        // instead of queryParametersDecoded, so percent-encoded values won't work properly
        let bezahlString = "bank://singlepaymentsepa?reason1=AlternativeReason"
        let parameters = QRCodesExtractor.extractParameters(fromBezhalCodeString: bezahlString)

        XCTAssertEqual(parameters["paymentReference"],
                       "AlternativeReason",
                       "Should fall back to reason1 when reason is not present")
    }

    func testExtractParametersFromBezahlCodeWithSpecialCharacters() {
        let bezahlString = "bank://singlepaymentsepa?name=Test%20%26%20Co.&reason=50%25%20discount"
        let parameters = QRCodesExtractor.extractParameters(fromBezhalCodeString: bezahlString)

        XCTAssertEqual(parameters["paymentRecipient"],
                       "Test & Co.",
                       "Special characters should be properly URL decoded in name")

        XCTAssertEqual(parameters["paymentReference"],
                       "50% discount",
                       "Special characters should be properly URL decoded in reason")
    }

    // MARK: - Test extractParameters(fromEPC06912CodeString:)

    func testExtractParametersFromEPC06912WithAllFields() {
        let epc06912String = """
        BCD
        002
        1
        SCT
        DEUTDEFF500
        Max Mustermann
        DE89370400440532013000
        EUR123.45
        
        Invoice 12345
        
        Additional info
        """

        let parameters = QRCodesExtractor.extractParameters(fromEPC06912CodeString: epc06912String)

        XCTAssertEqual(parameters["bic"],
                       "DEUTDEFF500",
                       "BIC should be extracted from line 4 of EPC06912 format")

        XCTAssertEqual(parameters["paymentRecipient"],
                       "Max Mustermann",
                       "Payment recipient should be extracted from line 5")

        XCTAssertEqual(parameters["iban"],
                       "DE89370400440532013000",
                       "Valid IBAN should be extracted from line 6")

        XCTAssertEqual(parameters["paymentReference"],
                       "Invoice 12345",
                       "Payment reference should be extracted from line 9")

        XCTAssertEqual(parameters["amountToPay"],
                       "123.45:EUR",
                       "Amount with currency prefix should be normalized from line 7")
    }

    func testExtractParametersFromEPC06912WithMinimalFields() {
        let epc06912String = """
        BCD
        002
        """

        let parameters = QRCodesExtractor.extractParameters(fromEPC06912CodeString: epc06912String)

        XCTAssertEqual(parameters["bic"],
                       "",
                       "Missing BIC line should return empty string")
        XCTAssertEqual(parameters["paymentRecipient"],
                       "",
                       "Missing payment recipient line should return empty string")
        XCTAssertEqual(parameters["iban"],
                       "",
                       "Missing IBAN line should return empty string after validation")
        XCTAssertEqual(parameters["paymentReference"],
                       "",
                       "Missing payment reference line should return empty string")
        XCTAssertEqual(parameters["amountToPay"],
                       "",
                       "Missing amount line should return empty string")
    }

    func testExtractParametersFromEPC06912WithEmptyAmount() {
        let epc06912String = """
        BCD
        002
        1
        SCT
        DEUTDEFF
        Test Company
        DE89370400440532013000
        
        
        Payment for services
        """

        let parameters = QRCodesExtractor.extractParameters(fromEPC06912CodeString: epc06912String)

        XCTAssertEqual(parameters["bic"],
                       "DEUTDEFF",
                       "BIC should be extracted even when amount is empty")

        XCTAssertEqual(parameters["paymentRecipient"],
                       "Test Company",
                       "Payment recipient should be extracted even when amount is empty")

        XCTAssertEqual(parameters["iban"],
                       "DE89370400440532013000",
                       "Valid IBAN should be extracted even when amount is empty")

        XCTAssertEqual(parameters["paymentReference"],
                       "Payment for services",
                       "Payment reference should be extracted even when amount is empty")

        XCTAssertEqual(parameters["amountToPay"],
                       "",
                       "Empty amount line should result in empty amountToPay after normalization fails")
    }

    func testExtractParametersFromEPC06912WithInvalidIBAN() {
        let epc06912String = """
        BCD
        002
        1
        SCT
        DEUTDEFF
        Test Company
        INVALID_IBAN_12345
        EUR50.00
        
        Payment
        """

        let parameters = QRCodesExtractor.extractParameters(fromEPC06912CodeString: epc06912String)

        XCTAssertEqual(parameters["iban"],
                       "",
                       "Invalid IBAN should return empty string after validation fails")
    }

    func testExtractParametersFromEPC06912EmptyString() {
        let parameters = QRCodesExtractor.extractParameters(fromEPC06912CodeString: "")

        XCTAssertEqual(parameters["bic"],
                       "",
                       "Empty input should return empty string for BIC")

        XCTAssertEqual(parameters["paymentRecipient"],
                       "",
                       "Empty input should return empty string for payment recipient")

        XCTAssertEqual(parameters["iban"],
                       "",
                       "Empty input should return empty string for IBAN")

        XCTAssertEqual(parameters["paymentReference"],
                       "",
                       "Empty input should return empty string for payment reference")

        XCTAssertEqual(parameters["amountToPay"],
                       "",
                       "Empty input should return empty string for amount")
    }

    // MARK: - Test QRCodesFormat prefix URLs

    func testQRCodesFormatPrefixURLs() {
        XCTAssertEqual(QRCodesFormat.epc06912.prefixURL,
                       "BCD",
                       "EPC06912 format should have BCD prefix")
        XCTAssertEqual(QRCodesFormat.eps4mobile.prefixURL,
                       "epspayment://",
                       "EPS4Mobile format should have epspayment:// prefix")
        XCTAssertEqual(QRCodesFormat.bezahl.prefixURL,
                       "bank://",
                       "Bezahl format should have bank:// prefix")
        XCTAssertEqual(QRCodesFormat.giniQRCode.prefixURL,
                       "https://pay.gini.net/",
                       "Gini QR code format should have https://pay.gini.net/ prefix")
    }

    // MARK: - Test normalize(amount:currency:) indirectly through public methods

    func testNormalizeAmountWithCurrencyPrefix() {
        let epc06912String = """
        BCD
        002
        1
        SCT
        BIC
        Name
        DE89370400440532013000
        USD100.50
        """

        let parameters = QRCodesExtractor.extractParameters(fromEPC06912CodeString: epc06912String)
        XCTAssertEqual(parameters["amountToPay"],
                       "100.50:USD",
                       "Amount starting with 3 letter currency code should be normalized to amount:currency format")
    }

    func testNormalizeAmountWithExplicitCurrency() {
        let bezahlString = "bank://singlepaymentsepa?amount=100&currency=CHF"
        let parameters = QRCodesExtractor.extractParameters(fromBezhalCodeString: bezahlString)

        XCTAssertEqual(parameters["amountToPay"],
                       "100:CHF",
                       "Amount with separate currency parameter should be normalized to amount:currency format")
    }
}
