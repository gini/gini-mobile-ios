//
//  APIMethod.swift
//  GiniHealthAPI
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

enum APIMethod: ResourceMethod {
    
    case createDocument(fileName: String?,
                        docType: Document.DocType?,
                        mimeSubType: MimeSubtype,
                        documentType: Document.TypeV2?)
    case documents(limit: Int?,
                   offset: Int?)
    case document(id: String)
    case composite
    case errorReport(forDocumentWithId: String,
                     summary: String?,
                     description: String?)
    case extractions(forDocumentId: String)
    case extraction(withLabel: String,
                    documentId: String)
    case feedback(forDocumentId: String)
    case layout(forDocumentId: String)
    case partial
    case pages(forDocumentId: String)
    case processedDocument(withId: String)
    case paymentProvider(id: String)
    case paymentProviders
    case createPaymentRequest
    case paymentRequest(id: String)
    case paymentRequests(limit: Int?,
                         offset: Int?)
    case file(urlString: String)
    case payment(id: String)
    case pdfWithQRCode(paymentRequestId: String,
                       mimeSubtype: MimeSubtype)
}
