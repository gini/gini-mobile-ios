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

    public let sourceDocumentLocation: String?
    public let recipient: String
    public let iban: String
    public let bic: String
    public let amount: String
    public let purpose: String
    public let paymentUniversalLink: String
    public let paymentProviderId: String

    public init(sourceDocumentLocation: String? = nil,
                recipient: String,
                iban: String,
                bic: String,
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

    public var isComplete: Bool {
        !recipient.isEmpty &&
        !iban.isEmpty &&
        !amount.isEmpty &&
        !purpose.isEmpty
    }
}
