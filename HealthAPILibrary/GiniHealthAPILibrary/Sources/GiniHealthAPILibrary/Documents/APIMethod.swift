//
//  APIMethod.swift
//  GiniHealthAPI
//
//  Created by Enrique del Pozo Gómez on 3/4/19.
//

import Foundation

enum APIMethod: ResourceMethod {
    
    case createDocument(fileName: String?,
        docType: Document.DocType?,
        mimeSubType: String,
        documentType: Document.TypeV2?)
    case documents(limit: Int?, offset: Int?)
    case document(id: String)
    case composite
    case errorReport(forDocumentWithId: String,
        summary: String?, description: String?)
    case extractions(forDocumentId: String)
    case extraction(withLabel: String, documentId: String)
    case feedback(forDocumentId: String)
    case layout(forDocumentId: String)
    case partial
    case pages(forDocumentId: String)
    case processedDocument(withId: String)
    case paymentProvider(id: String)
    case paymentProviders
    case createPaymentRequest
    case paymentRequest(id: String)
    case paymentRequests(limit: Int?, offset: Int?)
    case file(urlString: String)
}
