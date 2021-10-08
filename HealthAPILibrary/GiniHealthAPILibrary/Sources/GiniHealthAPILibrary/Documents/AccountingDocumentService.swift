//
//  AccountingDocumentService.swift
//  GiniHealthAPI
//
//  Created by Enrique del Pozo Gómez on 3/22/19.
//

import Foundation

typealias AccountingDocumentServiceProtocol = DocumentService & V1DocumentService

/// The accounting document service. Interacts with the `APIDomain.accounting` api.
public final class AccountingDocumentService: AccountingDocumentServiceProtocol {
    
    fileprivate let sessionManager: SessionManagerProtocol
    
    /// The accounting API domain
    public var apiDomain: APIDomain = .accounting
    
    init(sessionManager: SessionManagerProtocol) {
        self.sessionManager = sessionManager
    }
    
    /**
     *  Creates a document from a given image `Data`
     *
     * - Parameter data:                The image's data
     * - Parameter fileName:            The document's filename
     * - Parameter docType:             The document's docType
     * - Parameter metadata:            The document's metadata
     * - Parameter completion:          A completion callback, returning the created document on success
     */
    public func createDocument(with data: Data,
                               fileName: String?,
                               docType: Document.DocType?,
                               metadata: Document.Metadata?,
                               completion: @escaping CompletionResult<Document>) {
        let resource = APIResource<String>(method: .createDocument(fileName: fileName,
                                                                   docType: docType,
                                                                   mimeSubType: data.mimeSubType,
                                                                   documentType: nil),
                                           apiDomain: apiDomain,
                                           httpMethod: .post,
                                           additionalHeaders: metadata?.headers ?? [:])
        sessionManager.upload(resource: resource, data: data) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let documentUrl):
                guard let id = documentUrl.split(separator: "/").last else {
                    completion(.failure(.parseError(message: "Invalid document url: \(documentUrl)")))
                    return
                }
                self.fetchDocument(with: String(id), completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /**
     *  Deletes a document
     *
     * - Parameter document:            Document to be deleted
     * - Parameter completion:          A completion callback
     */
    public func delete(_ document: Document, completion: @escaping CompletionResult<String>) {
        deleteDocument(resourceHandler: sessionManager.data, with: document.id, completion: completion)
    }
    
    /**
     *  Fetches the user documents, with the possibility to retrieve them paginated
     *
     * - Parameter limit:               Limit of documents to retrieve
     * - Parameter offset:              Document's offset
     * - Parameter completion:          A completion callback, returning the document list on success
     */
    public func documents(limit: Int?, offset: Int?, completion: @escaping CompletionResult<[Document]>) {
        documents(resourceHandler: sessionManager.data, limit: limit, offset: offset, completion: completion)
    }
    
    /**
     *  Retrieves a document for a given document id
     *
     * - Parameter id:                  The document's unique identifier
     * - Parameter completion:          A completion callback, returning the requested document on success
     */
    public func fetchDocument(with id: String, completion: @escaping CompletionResult<Document>) {
        fetchDocument(resourceHandler: sessionManager.data, with: id, completion: completion)
    }
    
    /**
     *  Retrieves the extractions for a given document.
     *
     * - Parameter document:            Document to get the extractions for
     * - Parameter cancellationToken:   Used to stop the analysis when a user cancels it
     * - Parameter completion:          A completion callback, returning the extraction list on success
     */
    public func extractions(for document: Document,
                            cancellationToken: CancellationToken,
                            completion: @escaping CompletionResult<ExtractionResult>) {
        extractions(resourceHandler: sessionManager.data,
                    documentResourceHandler: sessionManager.data,
                    for: document,
                    cancellationToken: cancellationToken,
                    completion: completion)
    }
    
    /**
     *  Retrieves the layout of a given document
     *
     * - Parameter id:                  The document's unique identifier
     * - Parameter completion:          A completion callback, returning the requested document layout on success
     */
    public func layout(for document: Document, completion: @escaping CompletionResult<Document.Layout>) {
        layout(resourceHandler: sessionManager.data, for: document, completion: completion)
    }
    
    /**
     *  Retrieves the pages of a given document
     *
     * - Parameter id:                  The document's unique identifier
     * - Parameter completion:          A completion callback, returning the requested document layout on success
     */
    public func pages(in document: Document, completion: @escaping CompletionResult<[Document.Page]>) {
        pages(resourceHandler: sessionManager.data, in: document, completion: completion)
    }
    
    /**
     *  Retrieves the page preview of a document for a given page and size
     *
     * - Parameter document:            Document to get the preview for
     * - Parameter pageNumber:          The document's page number
     * - Parameter size:                The document's page size
     * - Parameter completion:          A completion callback, returning the requested page preview on success
     */
    public func pagePreview(for document: Document,
                            pageNumber: Int,
                            size: Document.Page.Size,
                            completion: @escaping CompletionResult<Data>) {
        pagePreview(resourceHandler: sessionManager.download,
                    in: document,
                    pageNumber: pageNumber,
                    size: size,
                    completion: completion)
    }
    
    /**
     *  Submits the analysis feedback for a given document.
     *
     * - Parameter document:            The document for which feedback should be sent
     * - Parameter extractions:         The document's updated extractions
     * - Parameter completion:          A completion callback
     */
    public func submitFeedback(for document: Document,
                               with extractions: [Extraction],
                               completion: @escaping CompletionResult<Void>) {
        submitFeedback(resourceHandler: sessionManager.data, for: document, with: extractions, completion: completion)
    }

    /**
     * Logs an error event.
     *
     * - Parameter errorEvent:          The error event details
     * - Parameter completion:          A completion callback
     */
    public func log(errorEvent: ErrorEvent,
                    completion: @escaping CompletionResult<Void>) {
        log(resourceHandler: sessionManager.data,
            errorEvent: errorEvent,
            completion: completion)
    }
}
