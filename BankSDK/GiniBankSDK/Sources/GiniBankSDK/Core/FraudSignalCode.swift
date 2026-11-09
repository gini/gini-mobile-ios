//
//  FraudSignalCode.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation

/**
 Fraud-signal codes the SDK understands.

 The raw backend `signalCode` string is case-sensitive and matches an enum case
 one-for-one. Unknown values are silently dropped by `FraudSignalMapper` so a new
 backend code never breaks the flow.
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
}
