//
//  Utils.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniHealthAPILibrary


func loadProviders(fileName: String) -> PaymentProviders? {
    var providers: PaymentProviders = []
    let providersResponse: [PaymentProviderResponse]? = load(fromFile: fileName)
    guard let providersResponse else { return nil }
    for providerResponse in providersResponse {
        let imageData = UIImage(named: "Gini-Test-Payment-Provider", in: Bundle.module, compatibleWith: nil)?.pngData()
        let provider = PaymentProvider(id: providerResponse.id, name: providerResponse.name, appSchemeIOS: providerResponse.appSchemeIOS, minAppVersion: providerResponse.minAppVersion, colors: providerResponse.colors, iconData: imageData ?? Data(), appStoreUrlIOS: providerResponse.appStoreUrlIOS, universalLinkIOS: providerResponse.universalLinkIOS, index: providerResponse.index, gpcSupportedPlatforms: providerResponse.gpcSupportedPlatforms, openWithSupportedPlatforms: providerResponse.openWithSupportedPlatforms)
            providers.append(provider)
    }
    return providers
}

func load<T: Decodable>(fromFile named: String, type: String = "json") -> T? {
    guard let jsonData = FileLoader.loadFile(withName: named, ofType: type) else {
        return nil
    }
    
    return try? JSONDecoder().decode(T.self, from: jsonData)
}
