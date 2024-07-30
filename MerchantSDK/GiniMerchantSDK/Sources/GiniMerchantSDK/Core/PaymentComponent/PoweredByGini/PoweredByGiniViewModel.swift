//
//  PoweredByGiniViewModel.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

final class PoweredByGiniViewModel {
    let poweredByGiniLabelText: String = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.poweredByGini.label", comment: "")
    let configuration: PoweredByGiniConfiguration

    init(configuration: PoweredByGiniConfiguration) {
        self.configuration = configuration
    }
}
