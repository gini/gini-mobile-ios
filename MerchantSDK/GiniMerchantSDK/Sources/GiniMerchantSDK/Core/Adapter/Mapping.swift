//
//  Mapping.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import GiniHealthAPILibrary

//MARK: - Mapping Extraction
extension Extraction {
    convenience init(healthExtraction: GiniHealthAPILibrary.Extraction) {
        self.init(box: nil,
                  candidates: healthExtraction.candidates,
                  entity: healthExtraction.entity,
                  value: healthExtraction.value,
                  name: healthExtraction.name)
    }
    
    func toHealthExtraction() -> GiniHealthAPILibrary.Extraction {
        return GiniHealthAPILibrary.Extraction(box: nil,
                                               candidates: candidates,
                                               entity: entity,
                                               value: value,
                                               name: name)
    }
}

extension ExtractionResult {
    convenience init(healthExtractionResult: GiniHealthAPILibrary.ExtractionResult) {
        let extractions = healthExtractionResult.extractions.map { Extraction(healthExtraction: $0) }
        
        self.init(extractions: extractions,
                  payment: [extractions],
                  lineItems: [extractions])
    }
    
    func toHealthExtractionResult() -> GiniHealthAPILibrary.ExtractionResult {
        let healthExtractions = extractions.map { $0.toHealthExtraction() }
        return GiniHealthAPILibrary.ExtractionResult(extractions: healthExtractions,
                                                     payment: [healthExtractions],
                                                     lineItems: [healthExtractions])
    }
}

//MARK: - PaymentProvider

extension PaymentProvider {
    init(healthPaymentProvider: GiniHealthAPILibrary.PaymentProvider) {
        let openPlatforms = healthPaymentProvider.openWithSupportedPlatforms.compactMap { PlatformSupported(rawValue: $0.rawValue) }
        let gpcPlatforms = healthPaymentProvider.gpcSupportedPlatforms.compactMap { PlatformSupported(rawValue: $0.rawValue) }
        let colors = ProviderColors(healthProviderColors: healthPaymentProvider.colors)
        
        self.init(id: healthPaymentProvider.id,
                  name: healthPaymentProvider.name,
                  appSchemeIOS: healthPaymentProvider.appSchemeIOS,
                  minAppVersion: nil,
                  colors: colors,
                  iconData: healthPaymentProvider.iconData,
                  appStoreUrlIOS: healthPaymentProvider.appStoreUrlIOS,
                  universalLinkIOS: healthPaymentProvider.universalLinkIOS,
                  index: healthPaymentProvider.index,
                  gpcSupportedPlatforms: gpcPlatforms,
                  openWithSupportedPlatforms: openPlatforms)
    }
}

extension ProviderColors {
    init(healthProviderColors: GiniHealthAPILibrary.ProviderColors) {
        self.init(background: healthProviderColors.background,
                  text: healthProviderColors.text)
    }
}

//extension MinAppVersions {
//    init(healthMinAppVersions: GiniHealthAPILibrary.MinAppVersions) {
//        self.init(ios: healthMinAppVersions.ios,
//                  android: healthMinAppVersions.android)
//    }
//}
