//
//  File.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//


import Foundation

struct APIEndpoint {
    static var composite: String = "/documents/composite"
    static var documents: String = "/documents/"
    static var createDocument: String = "/documents/"
    static var document: (String) -> String = { id in "/documents/\(id)" }
    static var errorReport: (String) -> String = { id in "/documents/\(id)/errorreport" }
    static var extractions: (String) -> String = { id in "/documents/\(id)/extractions" }
    static var extraction: (String, String) -> String = { label, documentId in "/documents/\(documentId)/extractions/\(label)" }
    static var feedback: (String) -> String = { id in "/documents/\(id)/extractions" }
    static var layout: (String) -> String = { id in "/documents/\(id)/layout" }
    static var pages: (String) -> String = { id in "/documents/\(id)/pages" }
    static var partial: String = "/documents/partial"
    static var processedDocument: (String) -> String = { id in "/documents/\(id)/processed" }
    static var paymentProviders: String = "/paymentProviders"
    static var paymentProvider: (String) -> String = { id in "/paymentProviders/\(id)" }
    static var createPaymentRequest: String = "/paymentRequests"
    static var paymentRequest: (String) -> String = { id in "/paymentRequests/\(id)" }
    static var paymentRequests: String = "/paymentRequests"
    static var file: (String) -> String = { urlString in urlString }
    static var payment: (String) -> String = { id in "/paymentRequests/\(id)/payment" }
    static var pdfWithQRCode: (String) -> String = { paymentRequestId in "/paymentRequests/\(paymentRequestId)" }
    static var configurations: String = "/configurations"
}
