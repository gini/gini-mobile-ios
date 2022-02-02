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
    let fileURLPath: String? = Bundle.module
        .path(forResource: "provider", ofType: "json")
    let jsonData = try? Data.init(contentsOf: URL(fileURLWithPath: fileURLPath!))
    return try! JSONDecoder().decode(PaymentProvider.self, from: jsonData!)
}

func loadProviderResponse() -> PaymentProviderResponse {
    let fileURLPath: String? = Bundle.module
        .path(forResource: "provider", ofType: "json")
    let jsonData = try? Data.init(contentsOf: URL(fileURLWithPath: fileURLPath!))
    return try! JSONDecoder().decode(PaymentProviderResponse.self, from: jsonData!)
}

func loadProviders() -> PaymentProviders {
    var providers: PaymentProviders = []
    let fileURLPath: String? = Bundle.module
        .path(forResource: "providers", ofType: "json")
    let jsonData = try? Data.init(contentsOf: URL(fileURLWithPath: fileURLPath!))
    let providersResponse = try! JSONDecoder().decode([PaymentProviderResponse].self, from: jsonData!)
    for providerResponse in providersResponse {
       let imageData = UIImage(named: "Gini-Test-Payment-Provider", in: Bundle.module, compatibleWith: nil)?.pngData()
        let provider = PaymentProvider(id: providerResponse.id, name: providerResponse.name, appSchemeIOS: providerResponse.appSchemeIOS, minAppVersion: providerResponse.minAppVersion, colors: providerResponse.colors, iconData: imageData ?? Data())
            providers.append(provider)
        }
    return providers
}

func loadPaymentRequest() -> PaymentRequest {
    let fileURLPath: String? = Bundle.module
        .path(forResource: "paymentRequest", ofType: "json")
    let jsonData = try? Data.init(contentsOf: URL(fileURLWithPath: fileURLPath!))
        return try! JSONDecoder().decode(PaymentRequest.self, from: jsonData!)
}
