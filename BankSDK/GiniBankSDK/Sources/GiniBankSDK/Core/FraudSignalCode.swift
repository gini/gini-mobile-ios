//
//  FraudSignalCode.swift
//  GiniBank
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation

/**
 Fraud-signal codes the SDK understands.

 The raw backend `signalCode` string is case-sensitive and matches an enum case
 one-for-one. An unknown value returns `nil` from `from(apiValue:)` so a new
 backend code never breaks the flow — it is silently dropped by `FraudSignalMapper`.
 */
internal enum FraudSignalCode: String {
    /**
     The IBAN in the payment QR code matches none of the IBANs printed on the document.
     */
    case qrPrintedIbanMismatch = "QR_PRINTED_IBAN_MISMATCH"

    /**
     The country of the delivered IBAN differs from the payment recipient's country.
     */
    case ibanCountryMismatch = "IBAN_COUNTRY_MISMATCH"

    /**
     Resolves a backend wire value to a known code, or `nil` if the SDK does not know it.
     */
    static func from(apiValue: String?) -> FraudSignalCode? {
        guard let apiValue else { return nil }
        return FraudSignalCode(rawValue: apiValue)
    }
}
