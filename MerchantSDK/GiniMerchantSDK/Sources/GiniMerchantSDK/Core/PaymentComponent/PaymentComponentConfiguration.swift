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

    /**
     Set to `true` to make see payment component in 1 row instead of 2
     */
    public var showPaymentComponentInOneRow = false

    /**
     Set to `true` to hide information like select your bank title label and more information view if user is returning and used component multiple times
     */
    public var hideInfoForReturningUser = false

    public init(isPaymentComponentBranded: Bool = true, showPaymentComponentInOneRow: Bool = false, hideInfoForReturningUser: Bool = false) {
        self.isPaymentComponentBranded = isPaymentComponentBranded
        self.showPaymentComponentInOneRow = showPaymentComponentInOneRow
        self.hideInfoForReturningUser = hideInfoForReturningUser
    }
}
