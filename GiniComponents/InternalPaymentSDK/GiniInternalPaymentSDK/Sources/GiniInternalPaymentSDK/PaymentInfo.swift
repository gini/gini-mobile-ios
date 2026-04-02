//
//  PaymentInfo.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
/**
 Model object for payment information
  */

public struct PaymentInfo {

    /** The URI of the source document from which payment details were extracted, if available. */
    public var sourceDocumentLocation: String?
    /** The recipient of the payment. */
    public var recipient: String
    /** The IBAN (International Bank Account Number) of the payment recipient. */
    public var iban: String
    /** The BIC (Bank Identifier Code) for the payment, if available. */
    public var bic: String?
    /** The payment amount as a formatted string (e.g., "100.00:EUR"). */
    public var amount: String
    /** The purpose of the payment, such as an invoice reference or customer identifier. */
    public var purpose: String
    /** The universal link used to open the selected payment provider app. */
    public var paymentUniversalLink: String
    /** The unique identifier of the selected payment provider. */
    public var paymentProviderId: String

    /**
     Creates a new payment info object.
     - Parameters:
       - sourceDocumentLocation: The URI of the source document, if available.
       - recipient: The recipient of the payment.
       - iban: The IBAN of the payment recipient.
       - bic: The BIC for the payment, if available.
       - amount: The payment amount as a formatted string.
       - purpose: The purpose of the payment.
       - paymentUniversalLink: The universal link used to open the payment provider app.
       - paymentProviderId: The unique identifier of the selected payment provider.
     */
    public init(sourceDocumentLocation: String? = nil,
                recipient: String,
                iban: String,
                bic: String? = nil,
                amount: String,
                purpose: String,
                paymentUniversalLink: String,
                paymentProviderId: String) {
        self.sourceDocumentLocation = sourceDocumentLocation
        self.recipient = recipient
        self.iban = iban.uppercased()
        self.bic = bic
        self.amount = amount
        self.purpose = purpose
        self.paymentUniversalLink = paymentUniversalLink
        self.paymentProviderId = paymentProviderId
    }

    /**
     Indicates whether all required payment fields are filled in.
     Returns `true` when `recipient`, `iban`, `amount`, and `purpose` are all non-empty.
     */
    public var isComplete: Bool {
        !recipient.isEmpty &&
        !iban.isEmpty &&
        !amount.isEmpty &&
        !purpose.isEmpty
    }
}
