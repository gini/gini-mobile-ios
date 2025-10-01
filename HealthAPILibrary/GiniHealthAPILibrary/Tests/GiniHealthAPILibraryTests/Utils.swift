//
//  Utils.swift
//  GiniExampleTests
//
//  Created by Enrique del Pozo Gómez on 1/14/18.
//  Copyright © 2018 Gini. All rights reserved.
//

import UIKit
@testable import GiniHealthAPILibrary

func loadFile(withName name: String, ofType type: String) -> Data {
    let fileURLPath: String? = Bundle.module
        .path(forResource: name, ofType: type)
    let data = try? Data.init(contentsOf: URL(fileURLWithPath: fileURLPath!))
    
    return data!
}

func load<T: Decodable>(fromFile named: String, type: String) -> T {
    let jsonData = loadFile(withName: named, ofType: type)
    
    return (try? JSONDecoder().decode(T.self, from: jsonData))!
}

func loadProvidersResponse() -> [PaymentProviderResponse] {
    let fileURLPath: String? = Bundle.module
        .path(forResource: "providers", ofType: "json")
    let jsonData = try? Data.init(contentsOf: URL(fileURLWithPath: fileURLPath!))
    
    return (try? JSONDecoder().decode([PaymentProviderResponse].self, from: jsonData!))!
}

func loadPaymentRequests() -> PaymentRequests {
    let fileURLPath: String? = Bundle.module
        .path(forResource: "paymentRequests", ofType: "json")
    let jsonData = try? Data.init(contentsOf: URL(fileURLWithPath: fileURLPath!))
    
    return (try? JSONDecoder().decode(PaymentRequests.self, from: jsonData!))!
}

func loadProvider() -> PaymentProvider {
    guard let fileURLPath = Bundle.module.path(forResource: "provider", ofType: "json"),
          let jsonData = try? Data(contentsOf: URL(fileURLWithPath: fileURLPath)),
          let provider = try? JSONDecoder().decode(PaymentProvider.self, from: jsonData) else {
        fatalError("Could not load provider.json in tests")
    }
    return provider
}

func loadProviderResponse() -> PaymentProviderResponse {
    guard let fileURLPath = Bundle.module.path(forResource: "provider", ofType: "json"),
          let jsonData = try? Data(contentsOf: URL(fileURLWithPath: fileURLPath)),
          let response = try? JSONDecoder().decode(PaymentProviderResponse.self, from: jsonData) else {
        fatalError("Could not load PaymentProviderResponse.json in tests")
    }
    return response
}

func loadProviders() -> PaymentProviders {
    var providers: PaymentProviders = []
    
    guard let fileURLPath = Bundle.module.path(forResource: "providers", ofType: "json"),
          let jsonData = try? Data(contentsOf: URL(fileURLWithPath: fileURLPath)),
          let providersResponse = try? JSONDecoder().decode([PaymentProviderResponse].self, from: jsonData) else {
        fatalError("Could not load providers.json in tests")
    }
    
    for providerResponse in providersResponse {
        let imageData = UIImage(named: "Gini-Test-Payment-Provider",
                                in: Bundle.module,
                                compatibleWith: nil)?.pngData() ?? Data()
        
        let provider = PaymentProvider(
            id: providerResponse.id,
            name: providerResponse.name,
            appSchemeIOS: providerResponse.appSchemeIOS,
            minAppVersion: providerResponse.minAppVersion,
            colors: providerResponse.colors,
            iconData: imageData,
            appStoreUrlIOS: providerResponse.appStoreUrlIOS,
            universalLinkIOS: providerResponse.universalLinkIOS,
            index: providerResponse.index,
            gpcSupportedPlatforms: providerResponse.gpcSupportedPlatforms,
            openWithSupportedPlatforms: providerResponse.openWithSupportedPlatforms
        )
        
        providers.append(provider)
    }
    
    return providers
}

func loadPaymentRequest() -> PaymentRequest {
    guard let fileURLPath = Bundle.module.path(forResource: "paymentRequest", ofType: "json"),
          let jsonData = try? Data(contentsOf: URL(fileURLWithPath: fileURLPath)),
          let request = try? JSONDecoder().decode(PaymentRequest.self, from: jsonData) else {
        fatalError("Could not load paymentRequest.json in tests")
    }
    return request
}

func loadPayment() -> Payment {
    guard let fileURLPath = Bundle.module.path(forResource: "payment", ofType: "json"),
          let jsonData = try? Data(contentsOf: URL(fileURLWithPath: fileURLPath)),
          let payment = try? JSONDecoder().decode(Payment.self, from: jsonData) else {
        fatalError("Could not load payment.json in tests")
    }
    return payment
}
