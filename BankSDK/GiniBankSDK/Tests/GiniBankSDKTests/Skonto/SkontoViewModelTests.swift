//
//  SkontoViewModelTests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniBankSDK
@testable import GiniBankAPILibrary

class SkontoViewModelTests: XCTestCase {
    
    var viewModel: SkontoViewModel!
    var skontoDiscounts: SkontoDiscounts!
    
    override func setUp() {
        super.setUp()
        let filename = "skontoDiscounts"
        let filetype = "json"
        do {
            skontoDiscounts = try loadSkontoDiscounts(from: filename, filetype: filetype)
            viewModel = SkontoViewModel(skontoDiscounts: skontoDiscounts)
        } catch {
            XCTFail("Failed to decode JSON: \(error)")
        }
    }
    
    /**
     Helper method to load and decode the SkontoDiscounts JSON file.

     - Parameters:
        - filename: The name of the JSON file to load.
        - filetype: The type of the file (usually "json").
     
     - Returns: A `SkontoDiscounts` object if decoding is successful, otherwise throws an error.
     */
    func loadSkontoDiscounts(from filename: String, filetype: String) throws -> SkontoDiscounts {
        guard let skontoDiscountsJson = FileLoader.loadFile(withName: filename, ofType: filetype) else {
            XCTFail("Error loading file: `\(filename).\(filetype)`")
            throw NSError(domain: "FileLoader", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error loading file: \(filename).\(filetype)"])
        }
        
        let extractionsContainer = try JSONDecoder().decode(ExtractionsContainer.self, from: skontoDiscountsJson)
        let extractionResult = ExtractionResult(extractionsContainer: extractionsContainer)
        return try SkontoDiscounts(extractions: extractionResult)
    }
    
    override func tearDown() {
        viewModel = nil
        skontoDiscounts = nil
        super.tearDown()
    }
    
    func testViewModelInitialization() {
        XCTAssertEqual(viewModel.amountToPay,
                       skontoDiscounts.totalAmountToPay,
                       "Amount to pay should be initialized correctly.")
        XCTAssertEqual(viewModel.skontoAmountToPay,
                       skontoDiscounts.discounts[0].amountToPay,
                       "Skonto amount to pay should be initialized correctly.")
        XCTAssertEqual(viewModel.dueDate,
                       skontoDiscounts.discounts[0].dueDate,
                       "Due date should be initialized correctly.")
        XCTAssertEqual(viewModel.amountDiscounted,
                       skontoDiscounts.discounts[0].amountDiscounted,
                       "Amount discounted should be initialized correctly.")
        XCTAssertEqual(viewModel.currencyCode,
                       skontoDiscounts.discounts[0].amountToPay.currencyCode,
                       "Currency code should match the amount to pay.")
    }
    
    func testStateChangeHandlerIsCalled() {
        var handlerCalled = false
        viewModel.addStateChangeHandler {
            handlerCalled = true
        }

        viewModel.toggleDiscount()
        XCTAssertTrue(handlerCalled,
                      "State change handler should be called when a state-changing action occurs.")
    }
    
    func testToggleDiscount() {
        let initialState = viewModel.isSkontoApplied
        viewModel.toggleDiscount()
        XCTAssertNotEqual(viewModel.isSkontoApplied,
                          initialState,
                          "Toggling discount should change the `isSkontoApplied` state.")
    }
    
    func testRecalculateRemainingDays() {
        let remainingDays = 5
        let newDate = Calendar.current.date(byAdding: .day, value: remainingDays, to: Date()) ?? Date()
        viewModel.setExpiryDate(newDate)
        XCTAssertEqual(viewModel.remainingDays,
                       remainingDays,
                       "Remaining days should be recalculated correctly when the expiry date changes.")
    }
    
    func testExpiredDiscountEdgeCase() {
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        viewModel.setExpiryDate(pastDate)
        XCTAssertEqual(viewModel.edgeCase,
                       .expired,
                       "Edge case should be set to 'expired' when the expiry date is in the past.")
        XCTAssertFalse(viewModel.isSkontoApplied,
                       "Skonto should not be applied when the discount is expired.")
    }

    func testPaymentTodayEdgeCase() {
        let todayDate = Date()
        viewModel.setExpiryDate(todayDate)
        XCTAssertEqual(viewModel.edgeCase,
                       .paymentToday,
                       "Edge case should be 'payment today' when the expiry date is today.")
    }
    
    func testEditedExtractionResult() {
        let extractionResult = viewModel.editedExtractionResult
        let skontoDiscountsExtractions = extractionResult.skontoDiscounts?.first
        let amountToPayExtraction = extractionResult.extractions.first { $0.name == "amountToPay" }
        XCTAssertEqual(amountToPayExtraction?.value,
                       viewModel.finalAmountToPay.extractionString,
                       "Edited extraction result should reflect the final amount to pay.")
        
        let skontoAmountToPayExtraction = skontoDiscountsExtractions?.first {
            $0.name == "skontoAmountToPay" || $0.name == "skontoAmountToPayCalculated"
        }
        XCTAssertEqual(skontoAmountToPayExtraction?.value,
                       viewModel.skontoAmountToPay.extractionString,
                       "Edited extraction result should reflect the updated skonto amount to pay.")
        
        let skontoDueDateExtraction = skontoDiscountsExtractions?.first {
            $0.name == "skontoDueDate" || $0.name == "skontoDueDateCalculated"
        }
        XCTAssertEqual(skontoDueDateExtraction?.value,
                       viewModel.dueDate.yearMonthDayString,
                       "Edited extraction result should reflect the updated skonto due date.")
        
        let skontoPercentageDiscountedExtraction = skontoDiscountsExtractions?.first {
            $0.name == "skontoPercentageDiscounted" || $0.name == "skontoPercentageDiscountedCalculated"
        }
        XCTAssertEqual(skontoPercentageDiscountedExtraction?.value,
                       viewModel.formattedPercentageDiscounted,
                       "Edited extraction result should reflect the updated skonto percentage discounted.")
        
        let skontoAmountDiscountedExtraction = skontoDiscountsExtractions?.first {
            $0.name == "skontoAmountDiscounted" || $0.name == "skontoAmountDiscountedCalculated"
        }
        XCTAssertEqual(skontoAmountDiscountedExtraction?.value,
                       viewModel.amountDiscounted.extractionString,
                       "Edited extraction result should reflect the updated skonto amount discounted.")
        
        let skontoRemainingDaysExtraction = skontoDiscountsExtractions?.first { $0.name == "skontoRemainingDays" }
        XCTAssertEqual(skontoRemainingDaysExtraction?.value,
                       "\(viewModel.remainingDays)",
                       "Edited extraction result should reflect the updated skonto remaining days.")
    }

    func testSetSkontoAmountToPayPrice() {
        let newPrice = 90.00
        viewModel.setSkontoAmountToPayPrice(formatValue(newPrice))

        XCTAssertEqual(viewModel.skontoAmountToPay.value,
                       Decimal(newPrice),
                       "Skonto amount to pay should be updated correctly when a new price is set.")
    }

    func testSetAmountToPayPrice() {
        let newPrice = 120.00
        viewModel.setAmountToPayPrice(formatValue(newPrice))

        XCTAssertEqual(viewModel.amountToPay.value,
                       Decimal(newPrice),
                       "Amount to pay should be updated correctly when a new price is set.")
    }
    
    func testSetInvalidSkontoAmountToPayPrice() {
        let amountToPayInitialValue = skontoDiscounts.totalAmountToPay.value
        let skontoAmountToPayInitialValue = skontoDiscounts.discounts[0].amountToPay.value
        let newPrice = formatValue(Double(truncating: amountToPayInitialValue as NSNumber) + 1)
        viewModel.setSkontoAmountToPayPrice(newPrice)

        XCTAssertEqual(viewModel.skontoAmountToPay.value,
                       skontoAmountToPayInitialValue,
                       "Skonto amount should remain unchanged if an invalid price is provided.")
    }
    
    func testSetZeroSkontoAmountToPayPrice() {
        let newPrice = 0.00
        viewModel.setSkontoAmountToPayPrice(formatValue(newPrice))

        XCTAssertEqual(viewModel.skontoAmountToPay.value,
                       Decimal(newPrice),
                       "Skonto amount to pay should be updated to zero correctly.")
    }

    func testSetZeroAmountToPayPrice() {
        let newPrice = 0.00
        viewModel.setAmountToPayPrice(formatValue(newPrice))

        XCTAssertEqual(viewModel.amountToPay.value,
                       Decimal(newPrice),
                       "Amount to pay should be updated to zero correctly.")
    }

    func testSetNonNumericSkontoAmountToPayPrice() {
        let newPrice = "abc"
        viewModel.setSkontoAmountToPayPrice(newPrice)

        XCTAssertNotEqual(viewModel.skontoAmountToPay.value,
                          Decimal(string: newPrice),
                          "Skonto amount to pay should not accept non-numeric values.")
    }

    func testSetNonNumericAmountToPayPrice() {
        let newPrice = "abc"
        viewModel.setAmountToPayPrice(newPrice)

        XCTAssertNotEqual(viewModel.amountToPay.value,
                          Decimal(string: newPrice),
                          "Amount to pay should not accept non-numeric values.")
    }

    func testSetPriceWithTooManyDecimalsForSkontoAmountToPay() {
        let newPrice = 123.45678
        viewModel.setSkontoAmountToPayPrice(formatValue(newPrice))

        let expectedValue = Decimal(123.46)
        XCTAssertEqual(viewModel.skontoAmountToPay.value,
                       expectedValue,
                       "Skonto amount to pay should be rounded to two decimal places.")
    }

    func testSetPriceWithTooManyDecimalsForAmountToPay() {
        let newPrice = 123.45678
        viewModel.setAmountToPayPrice(formatValue(newPrice))

        let expectedValue = Decimal(123.46)
        XCTAssertEqual(viewModel.amountToPay.value,
                       expectedValue,
                       "Amount to pay should be rounded to two decimal places.")
    }
    
    func testInitialSkontoStateDetermination() {
        let isSkontoApplied = viewModel.isSkontoApplied

        if viewModel.remainingDays < 0 {
            XCTAssertFalse(isSkontoApplied,
                           "Skonto should not be applied if the discount is expired.")
            XCTAssertEqual(viewModel.edgeCase,
                           .expired,
                           "Edge case should be 'expired' when remaining days are negative.")
        } else if viewModel.paymentMethod == .cash {
            XCTAssertFalse(isSkontoApplied,
                           "Skonto should not be applied if the payment method is cash.")
            XCTAssertEqual(viewModel.edgeCase,
                           .payByCash,
                           "Edge case should be 'pay by cash' if the payment method is cash.")
        } else if viewModel.remainingDays == 0 {
            XCTAssertTrue(isSkontoApplied,
                          "Skonto should be applied if the payment is due today.")
            XCTAssertEqual(viewModel.edgeCase,
                           .paymentToday,
                           "Edge case should be 'payment today' when the due date is today.")
        } else {
            XCTAssertTrue(isSkontoApplied,
                          "Skonto should be applied by default.")
            XCTAssertNil(viewModel.edgeCase,
                         "Edge case should be nil for normal conditions.")
        }
    }

    func testToggleDiscountChangesFinalAmountToPay() {
        let initialAmount = viewModel.finalAmountToPay

        viewModel.toggleDiscount()
        let newAmount = viewModel.finalAmountToPay

        XCTAssertNotEqual(initialAmount,
                          newAmount,
                          "Toggling the Skonto discount should change the final amount to pay.")
    }

    func testRecalculateSkontoPercentageThroughFormattedValue() {
        let initialViewModel: SkontoViewModel! = viewModel
        let initialFormattedPercentage = initialViewModel?.formattedPercentageDiscounted

        // Set a new Skonto amount to pay that is lower than the current one to trigger recalculation
        let newSkontoAmountToPay = Price(value: 200, currencyCode: initialViewModel.currencyCode)

        // Assert that the new Skonto amount to pay is less than or equal to the original amount
        XCTAssertTrue(newSkontoAmountToPay.value <= viewModel.amountToPay.value,
                      "New Skonto amount to pay must be less than or equal to the total amount to pay.")

        viewModel.setSkontoAmountToPayPrice(newSkontoAmountToPay.stringWithoutSymbol ?? "")

        let updatedFormattedPercentage = viewModel.formattedPercentageDiscounted
        XCTAssertNotEqual(updatedFormattedPercentage,
                          initialFormattedPercentage,
                          "Skonto percentage should be recalculated and reflected in the formatted percentage string when the Skonto amount to pay changes.")
    }

    func testSkontoSavingsAmountCalculation() {
        let initialSavings = viewModel.savingsPriceString
        let newSkontoAmountToPay = Price(value: viewModel.amountToPay.value * 0.5, currencyCode: viewModel.currencyCode)

        XCTAssertTrue(newSkontoAmountToPay.value <= viewModel.amountToPay.value,
                      "New Skonto amount to pay must be less than or equal to the total amount to pay.")

        viewModel.setSkontoAmountToPayPrice(newSkontoAmountToPay.stringWithoutSymbol ?? "")

        let updatedSavings = viewModel.savingsPriceString

        XCTAssertNotEqual(updatedSavings,
                          initialSavings,
                          "Skonto savings amount should be updated when the Skonto amount to pay changes, reflecting a change in the Skonto percentage.")
    }
    
    func testValueCappedAtMaxDigits() {
        let initialValue = viewModel.amountToPay
        let newPrice = 1234567.89
        viewModel.setAmountToPayPrice(formatValue(newPrice))
        let updatedValue = viewModel.amountToPay
        XCTAssertEqual(updatedValue,
                       initialValue,
                       "Expected value to ignore amount which is greater than 99999.99 and stay with: \(initialValue)")
    }
    
    func testMaxAllowedAmountToPay() {
        let newPrice = 99999.98
        viewModel.setAmountToPayPrice(formatValue(newPrice))
        let updatedValue = viewModel.amountToPay.value
        let expectedValue = Decimal(newPrice)
        XCTAssertEqual(updatedValue,
                       expectedValue,
                       "Expected value to be equal to: \(newPrice)")
    }

    private func formatValue(_ value: Double) -> String {
        return NumberFormatter.twoDecimalPriceFormatter.string(from: NSNumber(value: value)) ?? ""
    }
}
