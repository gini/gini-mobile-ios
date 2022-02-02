//
//  PaymentRequestBody.swift
//  GiniHealthAPI
//
//  Created by Nadya Karaban on 22.03.21.
//

import Foundation
/**
 Struct for payment request body
 */
struct PaymentRequestBody: Codable {
    var sourceDocumentLocation: String?
    var paymentProvider,recipient, iban: String
    var bic: String?
    var amount, purpose: String
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let sourceDocumentLocationString = sourceDocumentLocation {
            try container.encode(sourceDocumentLocationString, forKey: .sourceDocumentLocation)
        }
        try container.encode(paymentProvider, forKey: .paymentProvider)
        try container.encode(recipient, forKey: .recipient)
        try container.encode(iban, forKey: .iban)
        if let bicString = bic {
            try container.encode(bicString, forKey: .bic)
        }
        try container.encode(amount, forKey: .amount)
        try container.encode(purpose, forKey: .purpose)
    }
}
