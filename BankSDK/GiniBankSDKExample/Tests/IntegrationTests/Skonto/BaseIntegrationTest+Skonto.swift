//
//  BaseIntegrationTest+Skonto.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import XCTest
@testable import GiniBankAPILibrary
@testable import GiniCaptureSDK
@testable import GiniBankSDK


extension BaseIntegrationTest {

    /**
     Verifies the `skontoDiscounts` compound extractions against the the mocked JSON.

     - Parameters:
     - result: The `ExtractionResult` containing the extracted data.
     - fixtureContainer: The `ExtractionsContainer` representing the expected extractions from the mocked JSON.
     */
    func verifySkontoDiscounts(result: ExtractionResult, fixtureContainer: ExtractionsContainer) {
        do {
            // Initialize SkontoDiscounts from the extraction result
            let mappedExtractedSkontoDiscounts = try SkontoDiscounts(extractions: result)
            // Map fixtureSkontoDiscounts from `fixtureContainer` - mock data
            let fixtureSkontoDiscounts = fixtureContainer.compoundExtractions?.skontoDiscounts ?? []
            // Make sure the number of discounts matches
            XCTAssertEqual(mappedExtractedSkontoDiscounts.discounts.count,
                           fixtureSkontoDiscounts.count,
                           "Mismatch in the number of skonto discounts")

            let extractedSkontoDiscount = mappedExtractedSkontoDiscounts.discounts.first
            let fixtureSkontoDiscount = try fixtureSkontoDiscounts.map { try SkontoDiscountDetails(extractions: $0) }.first

            // Existence check for required fields in extracted discounts
            XCTAssertNotNil(extractedSkontoDiscount?.dueDate, "The dueDate should exist in the extracted skonto discount")
            XCTAssertNotNil(extractedSkontoDiscount?.percentageDiscounted, "The percentageDiscounted should exist in the extracted skonto discount")
            XCTAssertNotNil(extractedSkontoDiscount?.amountToPay, "The amountToPay should exist in the extracted skonto discount")
            XCTAssertNotNil(extractedSkontoDiscount?.remainingDays, "The remainingDays should exist in the extracted skonto discount")
            XCTAssertNotNil(extractedSkontoDiscount?.amountDiscounted, "The amountDiscounted should exist in the extracted skonto discount")
            XCTAssertNotNil(extractedSkontoDiscount?.paymentMethod, "The paymentMethod should exist in the extracted skonto discount")
            XCTAssertFalse(extractedSkontoDiscount?.boundingBoxes.isEmpty ?? true, "Bounding boxes should exist in the extracted skonto discount")

            // Compare the values - keep in mind that this might fail since the extraction result might be different
            XCTAssertEqual(extractedSkontoDiscount?.amountToPay.value,
                           fixtureSkontoDiscount?.amountToPay.value,
                           "Skonto amount to pay values are not equal.")
            XCTAssertEqual(extractedSkontoDiscount?.amountToPay.currencyCode,
                           fixtureSkontoDiscount?.amountToPay.currencyCode,
                           "Skonto amount to pay currency is not equal.")
            XCTAssertEqual(extractedSkontoDiscount?.percentageDiscounted,
                           fixtureSkontoDiscount?.percentageDiscounted,
                           "Skonto percentage discounted values are not equal.")
            XCTAssertEqual(extractedSkontoDiscount?.dueDate,
                           fixtureSkontoDiscount?.dueDate,
                           "Skonto due date values are not equal.")
            XCTAssertEqual(extractedSkontoDiscount?.amountDiscounted.value,
                           fixtureSkontoDiscount?.amountDiscounted.value,
                           "Skonto amount discounted values are not equal.")
            XCTAssertEqual(extractedSkontoDiscount?.amountDiscounted.currencyCode,
                           fixtureSkontoDiscount?.amountDiscounted.currencyCode,
                           "Skonto amount discounted currency is not equal.")
            XCTAssertEqual(extractedSkontoDiscount?.paymentMethod,
                           fixtureSkontoDiscount?.paymentMethod,
                           "Skonto payment method values are not equal.")

        } catch {
            XCTFail("Failed to map skonto discounts: \(error)")
        }
    }
}
