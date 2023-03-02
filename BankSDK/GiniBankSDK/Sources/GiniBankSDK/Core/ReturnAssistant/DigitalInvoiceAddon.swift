//
//  DigitalInvoiceAddon.swift
// GiniBank
//
//  Created by Alpár Szotyori on 03.09.20.
//

import Foundation
import GiniBankAPILibrary

struct DigitalInvoiceAddon: Equatable {
    let price: Price
    var name: String {
        return addonExtraction.name
    }
    
    private let addonExtraction: AddonExtraction
    
    init?(from extraction: Extraction) {
        guard let name = extraction.name,
            let addonExtraction = AddonExtraction(rawValue: name),
            let price = Price(extractionString: extraction.value) else {
                return nil
        }
        
        self.price = price
        self.addonExtraction = addonExtraction
    }
}

private enum AddonExtraction: String {
    case discount = "discount-addon"
    case giftcard = "giftcard-addon"
    case otherDiscounts = "other-discounts-addon"
    case otherCharges = "other-charges-addon"
    case shipment = "shipment-addon"
    
    var name: String {
        switch self {
        case .discount:
            return .ginibankLocalized(resource: DigitalInvoiceStrings.addonNameDiscount)
        case .giftcard:
            return .ginibankLocalized(resource: DigitalInvoiceStrings.addonNameGiftCard)
        case .otherDiscounts:
            return .ginibankLocalized(resource: DigitalInvoiceStrings.addonNameOtherDiscounts)
        case .otherCharges:
            return .ginibankLocalized(resource: DigitalInvoiceStrings.addonNameOtherCharges)
        case .shipment:
            return .ginibankLocalized(resource: DigitalInvoiceStrings.addonNameShipment)
        }
    }
}
