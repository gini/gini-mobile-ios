//
//  PaymentInfo.swift
//  GiniHealth
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
/**
 Model object for payment information
  */

public struct PaymentInfo {
    public var recipient, iban: String
    public var bic: String
    public var amount, purpose: String
    public var paymentUniversalLink: String
    public var paymentProviderId: String

}
