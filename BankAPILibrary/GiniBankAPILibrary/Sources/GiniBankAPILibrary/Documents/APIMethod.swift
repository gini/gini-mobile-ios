//
//  APIMethod.swift
//  GiniBankAPI
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
    case page(forDocumentId: String, number: Int, size: Document.Page.Size?)
    case pagePreview(forDocumentId: String, number: Int)
    case documentPage(forDocumentId: String, number: Int, size: Document.Page.Size)
    case processedDocument(withId: String)
    case paymentRequest(id: String)
    case paymentRequests(limit: Int?, offset: Int?)
    case resolvePaymentRequest(id: String)
    case payment(id: String)
    case logErrorEvent
    case configurations
}
