//
//  Utils.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniHealthAPILibrary

func loadProviderResponse() -> PaymentProviderResponse {
    let fileURLPath: String? = Bundle.module
        .path(forResource: "provider", ofType: "json")
    let jsonData = try? Data.init(contentsOf: URL(fileURLWithPath: fileURLPath!))
    return try! JSONDecoder().decode(PaymentProviderResponse.self, from: jsonData!)
}

func loadProvidersResponse() -> [PaymentProviderResponse] {
    let fileURLPath: String? = Bundle.module
        .path(forResource: "providers", ofType: "json")
    let jsonData = try? Data.init(contentsOf: URL(fileURLWithPath: fileURLPath!))
    
    return (try? JSONDecoder().decode([PaymentProviderResponse].self, from: jsonData!))!
}

func loadProviders(fileName: String = "providers") -> PaymentProviders {
    var providers: PaymentProviders = []
    let fileURLPath: String? = Bundle.module
        .path(forResource: fileName, ofType: "json")
    let jsonData = try? Data.init(contentsOf: URL(fileURLWithPath: fileURLPath!))
    let providersResponse = try! JSONDecoder().decode([PaymentProviderResponse].self, from: jsonData!)
    for providerResponse in providersResponse {
       let imageData = UIImage(named: "Gini-Test-Payment-Provider", in: Bundle.module, compatibleWith: nil)?.pngData()
        let provider = PaymentProvider(id: providerResponse.id, name: providerResponse.name, appSchemeIOS: providerResponse.appSchemeIOS, minAppVersion: providerResponse.minAppVersion, colors: providerResponse.colors, iconData: imageData ?? Data(), appStoreUrlIOS: providerResponse.appStoreUrlIOS, universalLinkIOS: providerResponse.universalLinkIOS)
            providers.append(provider)
        }
    return providers
}

func loadDocument(fileName: String, type: String) -> Document {
    let jsonData = loadFile(withName: fileName, ofType: type)

    return (try? JSONDecoder().decode(Document.self, from: jsonData))!
}

func loadExtractionResults(fileName: String, type: String) -> ExtractionsContainer {
    let jsonData = loadFile(withName: fileName, ofType: type)

    return (try? JSONDecoder().decode(ExtractionsContainer.self, from: jsonData))!
}

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

func loadPaymentRequest() -> PaymentRequest {
    let fileURLPath: String? = Bundle.module
        .path(forResource: "paymentRequest", ofType: "json")
    let jsonData = try? Data.init(contentsOf: URL(fileURLWithPath: fileURLPath!))
        return try! JSONDecoder().decode(PaymentRequest.self, from: jsonData!)
}
