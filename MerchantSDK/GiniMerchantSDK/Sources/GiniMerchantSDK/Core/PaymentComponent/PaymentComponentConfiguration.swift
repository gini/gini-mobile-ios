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
    public var isPaymentComponentBranded: Bool

    /**
     Set to `true` to make see payment component in 1 row instead of 2
     */
    var showPaymentComponentInOneRow: Bool

    /**
     Set to `true` to hide information like select your bank title label and more information view if user is returning and used component multiple times
     */
    var hideInfoForReturningUser: Bool

    public init(isPaymentComponentBranded: Bool = true) {
        self.isPaymentComponentBranded = isPaymentComponentBranded
        self.showPaymentComponentInOneRow = false
        self.hideInfoForReturningUser = false
    }
}
