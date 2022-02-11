//
//  ResolvedPaymentRequest.swift
//  GiniBankAPI
//
//  Created by Nadya Karaban on 05.05.21.
//
import Foundation
/**
 Struct for payment request response
 */
public struct ResolvedPaymentRequest: Codable {
    public var requesterUri: String
    public var iban: String
    public var bic: String?
    public var amount, purpose, recipient, createdAt: String
    public var status: String
    var links: ResolvedPaymentRequestLinks?

    enum CodingKeys: String, CodingKey {
        case requesterUri
        case iban, bic, amount, purpose, recipient, createdAt, status
        case links = "_links"
    }
}

/**
 Struct for links in payment request response
 */
struct ResolvedPaymentRequestLinks: Codable {
    var linksSelf, sourceDocumentLocation: String?
    var payment: String?

    enum CodingKeys: String, CodingKey {
        case linksSelf = "self"
        case payment,sourceDocumentLocation
    }
}
