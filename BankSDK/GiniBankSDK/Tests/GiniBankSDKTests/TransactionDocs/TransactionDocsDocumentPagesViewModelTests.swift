//
//  TransactionDocsDocumentPagesViewModelTests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import XCTest
@testable import GiniBankSDK

final class TransactionDocsDocumentPagesViewModelTests: XCTestCase {
    private let testIban = "IBAN12345678901234567890"
    private let validAmountToPay = Price(value: 100, currencyCode: "EUR")
    private let zeroAmountToPay = Price(value: 0, currencyCode: "EUR")
    private let testImages = [UIImage(), UIImage()]
    private let singleTestImage = [UIImage()]

    private func buildViewModel(amount: Price, iban: String, images: [UIImage]) -> TransactionDocsDocumentPagesViewModel {
        let extractions = TransactionDocsExtractions(amountToPay: amount, iban: iban)
        return TransactionDocsDocumentPagesViewModel(originalImages: images, extractions: extractions)
    }

    func testInitializationWithValidAmountToPayAndIBAN() {
        let viewModel = buildViewModel(amount: validAmountToPay, iban: testIban, images: testImages)

        XCTAssertEqual(viewModel.bottomInfoItems.count,
                       2,
                       "Expected bottomInfoItems to contain 2 items: amountToPayString and ibanString")
        XCTAssertTrue(viewModel.bottomInfoItems.contains(viewModel.amountToPayString),
                      "Expected bottomInfoItems to contain amountToPayString")
        XCTAssertTrue(viewModel.bottomInfoItems.contains(viewModel.ibanString),
                      "Expected bottomInfoItems to contain ibanString")
    }
    
    func testInitializationWithEmptyIBANAndZeroAmount() {
        let viewModel = buildViewModel(amount: zeroAmountToPay, iban: "", images: singleTestImage)
        XCTAssertTrue(viewModel.bottomInfoItems.isEmpty,
                      "Expected no bottom info items when both IBAN and amount are empty")
    }

    func testInitializationWithZeroAmountToPay() {
        let viewModel = buildViewModel(amount: zeroAmountToPay, iban: testIban, images: singleTestImage)

        XCTAssertEqual(viewModel.bottomInfoItems.count,
                       1,
                       "Expected bottomInfoItems to contain 1 item (ibanString) when amountToPay is zero")
        XCTAssertFalse(viewModel.bottomInfoItems.contains(viewModel.amountToPayString),
                       "Expected bottomInfoItems not to contain amountToPayString when amountToPay is zero")
        XCTAssertTrue(viewModel.bottomInfoItems.contains(viewModel.ibanString),
                      "Expected bottomInfoItems to contain ibanString")
    }

    func testInitializationWithEmptyIBAN() {
        let viewModel = buildViewModel(amount: validAmountToPay, iban: "", images: singleTestImage)

        XCTAssertEqual(viewModel.bottomInfoItems.count,
                       1,
                       "Expected bottomInfoItems to contain 1 item (amountToPayString) when IBAN is empty")
        XCTAssertTrue(viewModel.bottomInfoItems.contains(viewModel.amountToPayString),
                      "Expected bottomInfoItems to contain amountToPayString")
        XCTAssertFalse(viewModel.bottomInfoItems.contains(viewModel.ibanString),
                       "Expected bottomInfoItems not to contain ibanString when IBAN is empty")
    }

    func testImagesForDisplay() {
        let extractions = TransactionDocsExtractions(amountToPay: zeroAmountToPay, iban: testIban)
        let viewModel = TransactionDocsDocumentPagesViewModel(originalImages: testImages, extractions: extractions)

        let displayedImages = viewModel.imagesForDisplay()

        XCTAssertEqual(displayedImages.count,
                       testImages.count,
                       "Expected displayedImages count to match original testImages count")
        XCTAssertEqual(displayedImages,
                       testImages,
                       "Expected displayedImages to match the original testImages")
    }

    func testRightBarButtonAction() {
        let extractions = TransactionDocsExtractions(amountToPay: validAmountToPay, iban: testIban)
        let viewModel = TransactionDocsDocumentPagesViewModel(originalImages: singleTestImage, extractions: extractions)

        var actionExecuted = false
        viewModel.rightBarButtonAction = {
            actionExecuted = true
        }

        viewModel.rightBarButtonAction?()
        
        XCTAssertTrue(actionExecuted, "Expected rightBarButtonAction to be executed")
    }
}
