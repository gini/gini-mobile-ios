//
//  DefaultDocumentService.swift
//  GiniBankAPI
//
//  Created by Enrique del Pozo Gómez on 3/22/19.
//

import Foundation

typealias DefaultDocumentServiceProtocol = DocumentService & V2DocumentService

/// The default document service. By default interacts with the `APIDomain.default` api.
public final class DefaultDocumentService: DefaultDocumentServiceProtocol {
    
    let sessionManager: SessionManagerProtocol
    
    public var apiDomain: APIDomain
    
    init(sessionManager: SessionManagerProtocol, apiDomain: APIDomain = .default) {
        self.sessionManager = sessionManager
        self.apiDomain = apiDomain
    }
    
    /**
     *  Creates a partial document from a given image `Data` or a composite document for given partial documents.
     *
     * - Parameter fileName:            The document's filename
     * - Parameter docType:             The document's docType
     * - Parameter type:                The V2 document's type. It could be either partial or composite type.
     * - Parameter metadata:            The document's metadata
     * - Parameter completion:          A completion callback, returning the created document on success
     */
    public func createDocument(fileName: String?,
                               docType: Document.DocType?,
                               type: Document.TypeV2,
                               metadata: Document.Metadata?,
                               completion: @escaping CompletionResult<Document>) {
        let completionResult: CompletionResult<String> = { [weak self] result in
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
        
        switch type {
        case .composite(let compositeDocumentInfo):
            let resource = APIResource<String>.init(method: .createDocument(fileName: fileName,
                                                                            docType: docType,
                                                                            mimeSubType: "json",
                                                                            documentType: type),
                                                    apiDomain: apiDomain,
                                                    httpMethod: .post,
                                                    additionalHeaders: metadata?.headers ?? [:],
                                                    body: try? JSONEncoder().encode(compositeDocumentInfo))
            sessionManager.data(resource: resource, completion: completionResult)
        case .partial(let data):
            let resource = APIResource<String>.init(method: .createDocument(fileName: fileName,
                                                                            docType: docType,
                                                                            mimeSubType: "json",
                                                                            documentType: type),
                                                    apiDomain: apiDomain,
                                                    httpMethod: .post,
                                                    additionalHeaders: metadata?.headers ?? [:])
            sessionManager.upload(resource: resource, data: data, completion: completionResult)
        }
        
    }
    
    /**
     *  Deletes a document
     *
     * - Parameter document:            Document to be deleted
     * - Parameter completion:          A completion callback
     */
    public func delete(_ document: Document, completion: @escaping CompletionResult<String>) {
        switch document.sourceClassification {
        case .composite:
            deleteDocument(resourceHandler: sessionManager.data, with: document.id, completion: completion)
        default:
            fetchDocument(with: document.id) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let document):
                    // Before removing the partial document, all its composite documents must be deleted
                    let dispatchGroup = DispatchGroup()
                    document.compositeDocuments?.forEach { compositeDocument in
                        guard let id = compositeDocument.id else { return }
                        dispatchGroup.enter()
                        
                        self.deleteDocument(resourceHandler: self.sessionManager.data,
                                            with: id) { _ in
                            dispatchGroup.leave()
                        }
                    }
                    
                    // Once all composite documents are deleted, it proceeds with the partial document
                    dispatchGroup.notify(queue: DispatchQueue.global()) {
                        self.deleteDocument(resourceHandler: self.sessionManager.data,
                                            with: document.id,
                                            completion: completion)
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            
        }
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
     * - Parameter cancellationToken:   Token use to stopped the analysis when a user cancels it
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
     * - Parameter document:            The document from which to retrieve the layout
     * - Parameter completion:          A completion callback, returning the requested document layout on success
     */
    public func layout(for document: Document, completion: @escaping CompletionResult<Document.Layout>) {
        layout(resourceHandler: sessionManager.data, for: document, completion: completion)
    }
    
    /**
     *  Retrieves the pages of a given document
     *
     * - Parameter document:            The document from which to retrieve the pages
     * - Parameter completion:          A completion callback, returning the requested document layout on success
     */
    public func pages(in document: Document, completion: @escaping CompletionResult<[Document.Page]>) {
        pages(resourceHandler: sessionManager.data, in: document, completion: completion)
    }

    /**
     *  Retrieves the pages of a given document
     *
     * - Parameter documentId:          Document id from which to retrieve the pages
     * - Parameter completion:          A completion callback, returning the requested document layout on success
     */
    public func pages(for documentId: String, completion: @escaping CompletionResult<[Document.Page]>) {
        pages(resourceHandler: sessionManager.data, for: documentId, completion: completion)
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
     *  Retrieves the page preview of a document for a given page
     *
     * - Parameter documentId:          Document id to get the preview for
     * - Parameter pageNumber:          The document's page number starting from 1
     * - Parameter completion:          A completion callback, returning the requested page preview as Data on success
     */
    public func preview(for documentId: String,
                        pageNumber: Int,
                        completion: @escaping CompletionResult<Data>) {

        preview(resourceHandler: sessionManager.download,
                with: documentId,
                pageNumber: pageNumber,
                completion: completion)
    }

    /**
     *  Retrieves the page data of a document for a given page number and size
     *
     * - Parameter documentId:          Document id to get the preview for
     * - Parameter pageNumber:          The document's page number
     * - Parameter size:                The size of the page to retrieve (e.g., large, medium)
     * - Parameter completion:          A completion callback, returning the requested page preview on success, or an error on failure
     */
    public func documentPage(for documentId: String,
                             pageNumber: Int,
                             size: Document.Page.Size,
                             completion: @escaping CompletionResult<Data>) {
        documentPage(resourceHandler: sessionManager.download,
                     in: documentId,
                     pageNumber: pageNumber,
                     size: size,
                     completion: completion)
    }

    /**
     *  Retrieves the page data of a document for a given page number and size
     *
     * - Parameter document:            The document from which to retrieve the page data
     * - Parameter pageNumber:          The document's page number
     * - Parameter size:                The size of the page to retrieve (e.g., large, medium)
     * - Parameter completion:          A completion callback, returning the requested page preview on success, or an error on failure
     */
    public func documentPage(for document: Document,
                             pageNumber: Int,
                             size: Document.Page.Size,
                             completion: @escaping CompletionResult<Data>) {
        documentPage(resourceHandler: sessionManager.download,
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
     *  Submits the analysis feedback with compound extractions (e.g., "line items") for a given document.
     *
     * - Parameter document:            The document for which feedback should be sent
     * - Parameter extractions:         The document's updated extractions
     * - Parameter compoundExtractions: The document's updated compound extractions
     * - Parameter completion:          A completion callback
     */
    public func submitFeedback(for document: Document,
                               with extractions: [Extraction],
                               and compoundExtractions: [String: [[Extraction]]],
                               completion: @escaping CompletionResult<Void>) {
        submitFeedback(resourceHandler: sessionManager.data, for: document, with: extractions, and: compoundExtractions, completion: completion)
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
