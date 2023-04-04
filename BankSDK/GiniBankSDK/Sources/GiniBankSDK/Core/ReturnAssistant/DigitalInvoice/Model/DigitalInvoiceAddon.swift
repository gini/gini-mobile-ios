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
            return NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.addonname.discount",
                                                            comment: "addonNameDiscount")
        case .giftcard:
            return NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.addonname.giftcard",
                                                            comment: "addonNameGiftCard")
        case .otherDiscounts:
            return NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.addonname.otherdiscounts",
                                                            comment: "addonNameOtherDiscounts")
        case .otherCharges:
            return NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.addonname.othercharges",
                                                            comment: "addonNameOtherCharges")
        case .shipment:
            return NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.addonname.shipment",
                                                            comment: "addonNameShipment")
        }
    }
}
