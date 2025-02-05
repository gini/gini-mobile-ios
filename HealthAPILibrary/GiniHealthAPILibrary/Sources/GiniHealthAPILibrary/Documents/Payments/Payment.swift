//
//  Payment.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
/**
 Struct for payment response
 */
public struct Payment: Decodable {
    /**
     An initializer for a `Payment` structure

     - parameter paidAt: ISO 8601 date string defining point in time when the payment request was resolved.
     - parameter recipient: the recipient of the payment.
     - parameter iban: the iban (international bank account number) of the payment recipient.
     - parameter bic: the bic (bank identifier code) for the payment.
     - parameter purpose: the purpose of the payment, e.g. the invoice or customer identifier.
     - parameter links: object with links to other resources e.g. document and paymentRequest.
     */

    public init(paidAt: String,
                recipient: String,
                iban: String,
                bic: String? = nil,
                amount: String,
                purpose: String,
                links: PaymentLinks? = nil) {
        self.paidAt = paidAt
        self.recipient = recipient
        self.iban = iban
        self.bic = bic
        self.amount = amount
        self.purpose = purpose
        self.links = links
    }

    public var paidAt, recipient, iban: String
    public var bic: String?
    public var amount, purpose: String
    var links: PaymentLinks?

    enum CodingKeys: String, CodingKey {
        case paidAt, recipient, iban, bic, amount, purpose
        case links = "_links"
    }

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

/**
 Struct for links in payment response
 */
public struct PaymentLinks: Codable {
    var paymentRequest, sourceDocumentLocation, linksSelf: String?

    enum CodingKeys: String, CodingKey {
        case paymentRequest, sourceDocumentLocation
        case linksSelf = "self"
    }
}
