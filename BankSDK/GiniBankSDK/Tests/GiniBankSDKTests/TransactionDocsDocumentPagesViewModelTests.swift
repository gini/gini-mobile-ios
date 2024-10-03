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

    func testInitializationWithValidAmountToPayAndIBAN() {
        let extractions = TransactionDocsExtractions(amountToPay: validAmountToPay, iban: testIban)
        let viewModel = TransactionDocsDocumentPagesViewModel(originalImages: testImages, extractions: extractions)
        
        XCTAssertEqual(viewModel.bottomInfoItems.count, 2)
        XCTAssertTrue(viewModel.bottomInfoItems.contains(viewModel.amountToPayString))
        XCTAssertTrue(viewModel.bottomInfoItems.contains(viewModel.ibanString))
    }
    
    func testInitializationWithZeroAmountToPay() {
        let extractions = TransactionDocsExtractions(amountToPay: zeroAmountToPay, iban: testIban)
        let viewModel = TransactionDocsDocumentPagesViewModel(originalImages: singleTestImage, extractions: extractions)
        
        XCTAssertEqual(viewModel.bottomInfoItems.count, 1)
        XCTAssertFalse(viewModel.bottomInfoItems.contains(viewModel.amountToPayString))
        XCTAssertTrue(viewModel.bottomInfoItems.contains(viewModel.ibanString))
    }

    func testInitializationWithEmptyIBAN() {
        let extractions = TransactionDocsExtractions(amountToPay: validAmountToPay, iban: "")
        let viewModel = TransactionDocsDocumentPagesViewModel(originalImages: singleTestImage, extractions: extractions)
        
        XCTAssertEqual(viewModel.bottomInfoItems.count, 1)
        XCTAssertTrue(viewModel.bottomInfoItems.contains(viewModel.amountToPayString))
        XCTAssertFalse(viewModel.bottomInfoItems.contains(viewModel.ibanString))
    }

    func testImagesForDisplay() {
        let extractions = TransactionDocsExtractions(amountToPay: zeroAmountToPay, iban: testIban)
        let viewModel = TransactionDocsDocumentPagesViewModel(originalImages: testImages, extractions: extractions)

        let displayedImages = viewModel.imagesForDisplay()

        XCTAssertEqual(displayedImages.count, testImages.count)
        XCTAssertEqual(displayedImages, testImages)
    }

    func testRightBarButtonAction() {
        let extractions = TransactionDocsExtractions(amountToPay: validAmountToPay, iban: testIban)
        let viewModel = TransactionDocsDocumentPagesViewModel(originalImages: singleTestImage, extractions: extractions)

        var actionExecuted = false
        viewModel.rightBarButtonAction = {
            actionExecuted = true
        }

        viewModel.rightBarButtonAction?()
        
        XCTAssertTrue(actionExecuted)
    }
}
