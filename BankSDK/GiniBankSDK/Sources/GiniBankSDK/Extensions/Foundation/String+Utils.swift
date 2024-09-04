//
//  String+Utils.swift
// GiniBank
//
//  Created by Nadya Karaban on 04.03.21.
//

import Foundation
import GiniCaptureSDK

extension String {
    public static func parseAmountStringToBackendFormat(string: String) throws -> String {
        if let doubleStringValue =  Double(string) {
            // It's needed because String representation of Double adds `0`
            let truncatedZeroString = String(format: "%g", doubleStringValue)
            return String(truncatedZeroString) + ":EUR"
        } else {
            throw GiniBankError.amountParsingError(amountString: string)
        }
    }
}

extension String {
    var yearMonthDayDate: Date? {
        return DateFormatter.yearMonthDay.date(from: self)
    }
}


// MARK: - String Extension for Concatenation

extension String {
    // This method concatenates two strings with a custom separator.
    // The method takes two strings as parameters (firstString and secondString) and an optional separator.
    // The separator defaults to ": " if not provided. The method returns a single string that
    // combines the firstString and secondString with the separator in between.

    public static func concatenateWithSeparator(_ firstString: String,
                                                _ secondString: String,
                                                separator: String = ": ") -> String {
        return "\(firstString)\(separator)\(secondString)"
    }
}
