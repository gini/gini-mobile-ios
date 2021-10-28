//
//  Payment.swift
//  GiniBankAPI
//
//  Created by Nadya Karaban on 19.03.21.
//

import Foundation
/**
 Struct for payment response
 */
public struct Payment {
    public var paidAt, recipient, iban: String
    public var bic: String?
    public var amount, purpose: String
    var links: PaymentLinks?

    enum CodingKeys: String, CodingKey {
        case paidAt, recipient, iban, bic, amount, purpose
        case links = "_links"
    }
    
}

/**
 Struct for links in payment response
 */
public struct PaymentLinks: Codable {
    var paymentRequest, sourceDocumentLocation, linksSelf: String?

    enum CodingKeys: String, CodingKey {
        case paymentRequest, sourceDocumentLocation
        case linksSelf
    }
}

// MARK: - Decodable

extension Payment: Decodable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.paidAt = try container.decode(String.self, forKey: .paidAt)
        self.recipient = try container.decode(String.self, forKey: .recipient)
        self.iban = try container.decode(String.self, forKey: .iban)

        if container.contains(.bic) {
            self.bic = try container.decodeIfPresent(String.self, forKey: .bic)
        } else {
            self.bic = nil
        }

        self.amount = try container.decode(String.self, forKey: .amount)
        self.purpose = try container.decode(String.self, forKey: .purpose)
        self.links = try container.decode(PaymentLinks.self, forKey: .links)
    }
}
