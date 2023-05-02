//
//  PaymentInfo.swift
// GiniBank
//
//  Created by Nadya Karaban on 29.04.21.
//

import Foundation
/**
 Model object for payment information
  */

public struct PaymentInfo {
    public var recipient, iban: String
    public var bic: String?
    public var amount, purpose: String

    public init(recipient: String, iban: String, bic: String?, amount: String, purpose: String) {
        self.recipient = recipient
        self.iban = iban
        self.bic = bic
        self.amount = amount
        self.purpose = purpose
    }
}
