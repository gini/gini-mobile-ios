//
//  PoweredByGiniViewModel.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

public final class PoweredByGiniViewModel {
    let strings: PoweredByGiniStrings
    let configuration: PoweredByGiniConfiguration

    public init(configuration: PoweredByGiniConfiguration, strings: PoweredByGiniStrings) {
        self.strings = strings
        self.configuration = configuration
    }
}
