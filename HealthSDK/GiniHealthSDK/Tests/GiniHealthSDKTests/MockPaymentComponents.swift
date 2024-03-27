//
//  MockPaymentComponentsController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
@testable import GiniHealthSDK
@testable import GiniHealthAPILibrary

class MockPaymentComponents: PaymentComponentsProtocol {

    var isLoading: Bool = false
    var selectedPaymentProvider: PaymentProvider?
    
    private var giniHealth: GiniHealth
    private var paymentProviders: PaymentProviders = []
    private var installedPaymentProviders: PaymentProviders = []
    
    init(giniHealthSDK: GiniHealth) {
        self.giniHealth = giniHealthSDK
    }
    
    func loadPaymentProviders() {
        isLoading = false
        let paymentProviderResponse = loadProviderResponse()
        selectedPaymentProvider = PaymentProvider(id: paymentProviderResponse.id, name: paymentProviderResponse.name, appSchemeIOS: paymentProviderResponse.appSchemeIOS, minAppVersion: paymentProviderResponse.minAppVersion, colors: paymentProviderResponse.colors, iconData: Data(url: URL(string: paymentProviderResponse.iconLocation))!, appStoreUrlIOS: paymentProviderResponse.appStoreUrlIOS, universalLinkIOS: paymentProviderResponse.universalLinkIOS)
    }
}
