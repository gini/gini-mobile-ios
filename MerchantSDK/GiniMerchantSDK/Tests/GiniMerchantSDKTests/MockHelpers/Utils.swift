//
//  Utils.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniHealthAPILibrary
import GiniMerchantSDK

func loadProviders(fileName: String) -> GiniMerchantSDK.PaymentProviders? {
    var providers: GiniMerchantSDK.PaymentProviders = []
    let providersResponse: [PaymentProviderResponse]? = load(fromFile: fileName)
    guard let providersResponse else { return nil }
    for providerResponse in providersResponse {
        let imageData = UIImage(named: "Gini-Test-Payment-Provider", in: Bundle.module, compatibleWith: nil)?.pngData()
        let openWithPlatforms = providerResponse.openWithSupportedPlatforms.compactMap { GiniMerchantSDK.PlatformSupported(rawValue: $0.rawValue) }
        let gpcSupportedPlatforms = providerResponse.gpcSupportedPlatforms.compactMap { GiniMerchantSDK.PlatformSupported(rawValue: $0.rawValue) }
        let colors = GiniMerchantSDK.ProviderColors(background: providerResponse.colors.background,
                                                    text: providerResponse.colors.text)
        
        let provider = GiniMerchantSDK.PaymentProvider(id: providerResponse.id,
                                                       name: providerResponse.name,
                                                       appSchemeIOS: providerResponse.appSchemeIOS,
                                                       minAppVersion: nil,
                                                       colors: colors,
                                                       iconData: imageData ?? Data(),
                                                       appStoreUrlIOS: providerResponse.appStoreUrlIOS,
                                                       universalLinkIOS: providerResponse.universalLinkIOS,
                                                       index: providerResponse.index,
                                                       gpcSupportedPlatforms: gpcSupportedPlatforms,
                                                       openWithSupportedPlatforms: openWithPlatforms)
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
