//
//  DigitalInvoice.swift
// GiniBank
//
//  Created by Maciej Trybilo on 20.11.19.
//

import Foundation
import GiniBankAPILibrary

/**
 `DigitalInvoice` represents all extracted data in the form usable by the `DigitalInvoiceViewController`.
 The `DigitalInvoiceViewController` returns a `DigitalInvoice` as amended by the user.
 */
public struct DigitalInvoice {
    
    private let _extractionResult: ExtractionResult
    var lineItems: [LineItem]
    var addons: [DigitalInvoiceAddon]
    var returnReasons: [ReturnReason]?
    let inaccurateResults: Bool
    private let amountToPay: Price
    
    var total: Price? {
        
        guard let firstLineItem = lineItems.first else { return nil }
        
        let deselectedLineItemsTotalPrice = lineItems.reduce(Price(value: 0, currencyCode: firstLineItem.price.currencyCode)) { (current, lineItem) -> Price? in
            
            guard let current = current else { return nil }
            
            switch lineItem.selectedState {
            case .deselected: return try? current + lineItem.totalPrice
            case .selected: return current
            }
        }
        
        let lineItemsTotalPriceDiffs = lineItems.reduce(Price(value: 0, currencyCode: firstLineItem.price.currencyCode)) { (current, lineItem) -> Price? in
            
            guard let current = current else { return nil }
            
            if !lineItem.isUserInitiated {
                return try? current + lineItem.totalPriceDiff
            } else {
                return current
            }
        }
        
        let userAddedLineItemsTotalPrice = lineItems.reduce(Price(value: 0, currencyCode: firstLineItem.price.currencyCode)) { (current, lineItem) -> Price? in
            
            guard let current = current else { return nil }
            
            if lineItem.isUserInitiated {
                return try? current + lineItem.totalPrice
            } else {
                return current
            }
        }
        
        if let deselectedLineItemsTotalPrice = deselectedLineItemsTotalPrice,
            let userAddedLineItemsTotalPrice = userAddedLineItemsTotalPrice,
            let lineItemsTotalPriceDiffs = lineItemsTotalPriceDiffs {
            return try? Price.max(amountToPay
                                    - deselectedLineItemsTotalPrice
                                    + lineItemsTotalPriceDiffs
                                    + userAddedLineItemsTotalPrice,
                                         Price(value: 0, currencyCode: firstLineItem.price.currencyCode))
        } else {
            return amountToPay
        }
    }
}

extension DigitalInvoice {
    
    var numSelected: Int {
        
        return lineItems.reduce(Int(0)) { (partial, lineItem) -> Int in
            
            switch lineItem.selectedState {
            case .selected: return partial + lineItem.quantity
            case .deselected: return partial
            }
        }
    }
    
    var numTotal: Int {
        
        return lineItems.reduce(Int(0)) { (partial, lineItem) -> Int in
            return partial + lineItem.quantity
        }
    }
}

extension DigitalInvoice {
    
    enum DigitalInvoiceParsingException: Error {
        case lineItemsMissing
        case nameMissing
        case quantityMissing
        case priceMissing
        case articleNumberMissing
        case mixedCurrenciesInOneInvoice
        case cannotParseQuantity(string: String)
        case cannotParsePrice(string: String)
    }
    
    /**
     Returns a `DigitalInfo` instance given an `ExtractionResult`.
     
     - returns: Instance of `DigitalInfo`.
     */
    public init(extractionResult: ExtractionResult) throws {
        
        self._extractionResult = extractionResult
        
        guard let extractedLineItems = extractionResult.lineItems else { throw DigitalInvoiceParsingException.lineItemsMissing }
        
        lineItems = try extractedLineItems.map { try LineItem(extractions: $0) }
        
        guard let firstLineItem = lineItems.first else { throw DigitalInvoiceParsingException.lineItemsMissing }
        
        for lineItem in lineItems where lineItem.price.currencyCode != firstLineItem.price.currencyCode {
            throw DigitalInvoiceParsingException.mixedCurrenciesInOneInvoice
        }
        
        addons = []
        
        if let amountsAreConsistent = extractionResult.extractions.first(where: { $0.name == "amountsAreConsistent" }) {
            inaccurateResults = amountsAreConsistent.value == "false"
        } else {
            inaccurateResults = true
        }
        
        if let amountToPayExtraction = extractionResult.extractions.first(where: { $0.name == "amountToPay" }) {
            amountToPay = Price(extractionString: amountToPayExtraction.value) ?? Price(value: 0, currencyCode: firstLineItem.price.currencyCode)
        } else {
            amountToPay = Price(value: 0, currencyCode: firstLineItem.price.currencyCode)
        }
        
        extractionResult.extractions.forEach { extraction in
            if let addon = DigitalInvoiceAddon(from: extraction) {
                addons.append(addon)
            }
        }
        
        returnReasons = extractionResult.returnReasons
    }
    
    /**
     The backing `ExtractionResult` data.
     */
    public var extractionResult: ExtractionResult {
        
        guard let totalValue = total?.extractionString else {
            
            return ExtractionResult(extractions: _extractionResult.extractions,
                                    lineItems: lineItems.map { $0.extractions },
                                    returnReasons: returnReasons)
        }
        
        let modifiedExtractions = _extractionResult.extractions.map { extraction -> Extraction in
            
            if extraction.name == "amountToPay" {
                extraction.value = totalValue
            }
            
            return extraction
        }
        
        return ExtractionResult(extractions: modifiedExtractions,
                                lineItems: lineItems.map { $0.extractions },
                                returnReasons: returnReasons)
    }
}
