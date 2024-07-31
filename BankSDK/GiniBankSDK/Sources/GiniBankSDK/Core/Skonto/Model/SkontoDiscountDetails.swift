//
//  SkontoDiscount.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import GiniBankAPILibrary

struct SkontoDiscountDetails {
    private let extractions: [Extraction]
    var dueDate: Date
    var percentageDiscounted: Double
    var amountToPay: Price
    var remainingDays: Int
    var amountDiscounted: Price
    var paymentMethod: PaymentMethod

    enum PaymentMethod {
        case cash
        case paypal
        case unspecified

        init(from string: String) {
            switch string.lowercased() {
            case "cash":
                self = .cash
            case "paypal":
                self = .paypal
            default:
                self = .unspecified
            }
        }
    }

    private enum CodingKeys: String {
        case skontoDueDate
        case skontoDueDateCalculated
        case skontoPercentageDiscounted
        case skontoPercentageDiscountedCalculated
        case skontoAmountToPay
        case skontoAmountToPayCalculated
        case skontoAmountDiscounted
        case skontoAmountDiscountedCalculated
        case skontoRemainingDays
        case skontoPaymentMethod
    }

    private enum SkontoDiscountParsingException: Error {
        case skontoDueDateMissing
        case skontoPercentageDiscountedMissing
        case skontoAmountToPayMissing
        case skontoAmountDiscountedMissing
        case skontoRemainingDaysMissing
        case skontoPaymentMethodMissing
    }

    init(extractions: [Extraction]) throws {
        self.extractions = extractions
        self.paymentMethod = try Self.extractPaymentMethod(from: extractions)
        self.amountToPay = try Self.extractAmountToPay(from: extractions)
        self.amountDiscounted = try Self.extractAmountDiscounted(from: extractions)
        self.dueDate = try Self.extractDueDate(from: extractions)
        self.percentageDiscounted = try Self.extractPercentageDiscounted(from: extractions)
        self.remainingDays = try Self.extractRemainingDays(from: extractions)
    }

    private static func extractPaymentMethod(from extractions: [Extraction]) throws -> PaymentMethod {
        guard let extractedPaymentMethod = extractions.first(where: {
            $0.name == CodingKeys.skontoPaymentMethod.rawValue
        })?.value else {
            throw SkontoDiscountParsingException.skontoPaymentMethodMissing
        }
        return PaymentMethod(from: extractedPaymentMethod)
    }

    private static func extractAmountToPay(from extractions: [Extraction]) throws -> Price {
        if let extractedAmountToPay = extractions.first(where: {
            $0.name == CodingKeys.skontoAmountToPay.rawValue
        })?.value, let amountToPay = Price(extractionString: extractedAmountToPay) {
            return amountToPay
        } else if let extractedAmountToPayCalculated = extractions.first(where: {
            $0.name == CodingKeys.skontoAmountToPayCalculated.rawValue
        })?.value, let amountToPay = Price(extractionString: extractedAmountToPayCalculated) {
            return amountToPay
        } else {
            throw SkontoDiscountParsingException.skontoAmountToPayMissing
        }
    }

    private static func extractAmountDiscounted(from extractions: [Extraction]) throws -> Price {
        if let extractedAmountDiscounted = extractions.first(where: {
            $0.name == CodingKeys.skontoAmountDiscounted.rawValue
        })?.value, let amountDiscounted = Price(extractionString: extractedAmountDiscounted) {
            return amountDiscounted
        } else if let extractedAmountCalculated = extractions.first(where: {
            $0.name == CodingKeys.skontoAmountDiscountedCalculated.rawValue
        })?.value, let amountDiscounted = Price(extractionString: extractedAmountCalculated) {
            return amountDiscounted
        } else {
            throw SkontoDiscountParsingException.skontoAmountDiscountedMissing
        }
    }

    private static func extractDueDate(from extractions: [Extraction]) throws -> Date {
        if let extractedDueDateString = extractions.first(where: {
            $0.name == CodingKeys.skontoDueDate.rawValue
        })?.value ?? extractions.first(where: {
            $0.name == CodingKeys.skontoDueDateCalculated.rawValue
        })?.value, let dueDate = extractedDueDateString.yearMonthDayDate {
            return dueDate
        } else {
            throw SkontoDiscountParsingException.skontoDueDateMissing
        }
    }

    private static func extractPercentageDiscounted(from extractions: [Extraction]) throws -> Double {
        if let extractedPercentageDiscountedString = extractions.first(where: {
            $0.name == CodingKeys.skontoPercentageDiscounted.rawValue
        })?.value ?? extractions.first(where: {
            $0.name == CodingKeys.skontoPercentageDiscountedCalculated.rawValue
        })?.value, let percentageDiscounted = Double(extractedPercentageDiscountedString) {
            return percentageDiscounted
        } else {
            throw SkontoDiscountParsingException.skontoPercentageDiscountedMissing
        }
    }

    private static func extractRemainingDays(from extractions: [Extraction]) throws -> Int {
        guard let extractedRemainingDays = extractions.first(where: {
            $0.name == CodingKeys.skontoRemainingDays.rawValue
        })?.value else {
            throw SkontoDiscountParsingException.skontoRemainingDaysMissing
        }
        return Int(extractedRemainingDays) ?? 0
    }
}
