//
//  DigitalInvoiceAddon.swift
//  GiniPayBank
//
//  Created by Alpár Szotyori on 03.09.20.
//

import Foundation
import GiniPayApiLib

struct DigitalInvoiceAddon {
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
            return .ginipayLocalized(resource: DigitalInvoiceStrings.addonNameDiscount)
        case .giftcard:
            return .ginipayLocalized(resource: DigitalInvoiceStrings.addonNameGiftCard)
        case .otherDiscounts:
            return .ginipayLocalized(resource: DigitalInvoiceStrings.addonNameOtherDiscounts)
        case .otherCharges:
            return .ginipayLocalized(resource: DigitalInvoiceStrings.addonNameOtherCharges)
        case .shipment:
            return .ginipayLocalized(resource: DigitalInvoiceStrings.addonNameShipment)
        }
    }
}
