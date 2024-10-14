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

    public var recipient: String
    public var iban: String
    public var bic: String
    public var amount: String
    public var purpose: String
    public var paymentUniversalLink: String
    public var paymentProviderId: String

    public init(recipient: String, iban: String, bic: String, amount: String, purpose: String, paymentUniversalLink: String, paymentProviderId: String) {
        self.recipient = recipient
        self.iban = iban
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
