//
//  PaymentComponentConfiguration.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation

public struct PaymentComponentConfiguration {
    /**
      * Please contact a Gini representative before changing this configuration option.
      */
    public var isPaymentComponentBranded: Bool = true

    public init(isPaymentComponentBranded: Bool = true) {
        self.isPaymentComponentBranded = isPaymentComponentBranded
    }
}
