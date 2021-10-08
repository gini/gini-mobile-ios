//
//  PaymentRequest.swift
//  GiniHealthAPILib
//
//  Created by Nadya Karaban on 19.03.21.
//

import Foundation
/**
 Struct for payment request response
 */
public struct PaymentRequest: Codable {
    public var paymentProvider: String
    public var requesterURI: String?
    public var iban: String
    public var bic: String?
    public var amount, purpose, recipient, createdAt: String
    public var status: String
    var links: Links?

    enum CodingKeys: String, CodingKey {
        case paymentProvider
        case requesterURI = "requesterUri"
        case iban, bic, amount, purpose, recipient, createdAt, status
        case links = "_links"
    }
}

/**
 Struct for links in payment request response
 */
public struct Links: Codable {
    var linksSelf, paymentProvider: String
    var payment: String?

    enum CodingKeys: String, CodingKey {
        case linksSelf = "self"
        case paymentProvider, payment
    }
}

public typealias PaymentRequests = [PaymentRequest]
