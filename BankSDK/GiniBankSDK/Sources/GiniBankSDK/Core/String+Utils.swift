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
