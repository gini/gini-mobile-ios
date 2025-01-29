//
//  DocumentService.swift
//  GiniBankAPI
//
//  Created by Enrique del Pozo Gómez on 3/21/19.
//

import Foundation

typealias ResourceDataHandler<T: Resource> = (T, @escaping CompletionResult<T.ResponseType>) -> Void
typealias CancellableResourceDataHandler<T: Resource> = (T, CancellationToken?,
    @escaping CompletionResult<T.ResponseType>) -> Void

public protocol DocumentService: AnyObject {
    
    var apiDomain: APIDomain { get }
    
    /**
     *  Deletes a document
     *
     * - Parameter document:            Document to be deleted
     * - Parameter completion:          A completion callback
     */
    func delete(_ document: Document,
                completion: @escaping CompletionResult<String>)
    
    /**
     *  Fetches the user documents, with the possibility to retrieve them paginated
     *
     * - Parameter limit:               Limit of documents to retrieve
     * - Parameter offset:              Document's offset
     * - Parameter completion:          A completion callback, returning the document list on success
     */
    func documents(limit: Int?,
                   offset: Int?,
                   completion: @escaping CompletionResult<[Document]>)
    
    /**
     *  Retrieves the extractions for a given document.
     *
     * - Parameter document:            Document to get the extractions for
     * - Parameter cancellationToken:   Token use to stopped the analysis when a user cancels it
     * - Parameter completion:          A completion callback, returning the extraction list on success
     */
    func extractions(for document: Document,
                     cancellationToken: CancellationToken,
                     completion: @escaping CompletionResult<ExtractionResult>)
    
    /**
     *  Retrieves a document for a given document id
     *
     * - Parameter id:                  The document's unique identifier
     * - Parameter completion:          A completion callback, returning the requested document on success
     */
    func fetchDocument(with id: String,
                       completion: @escaping CompletionResult<Document>)
    
    /**
     *  Retrieves the layout of a given document
     *
     * - Parameter document:            The document from which to retrieve the page data
     * - Parameter completion:          A completion callback, returning the requested document layout on success
     */
    func layout(for document: Document,
                completion: @escaping CompletionResult<Document.Layout>)
    
    /**
     *  Retrieves the pages of a given document
     *
     * - Parameter document:            The document from which to retrieve the page data
     * - Parameter completion:          A completion callback, returning the requested document layout on success
     */
    func pages(in document: Document,
               completion: @escaping CompletionResult<[Document.Page]>)

    /**
     *  Retrieves the pages of a given document
     *
     * - Parameter id:                  The document's unique identifier
     * - Parameter completion:          A completion callback, returning the requested document layout on success
     */
    func pages(for documentId: String,
               completion: @escaping CompletionResult<[Document.Page]>)

    /**
     *  Retrieves the page preview of a document for a given page and size
     *
     * - Parameter document:            Document to get the preview for
     * - Parameter pageNumber:          The document's page number
     * - Parameter size:                The document's page size
     * - Parameter completion:          A completion callback, returning the requested page preview on success
     */
    func pagePreview(for document: Document,
                     pageNumber: Int,
                     size: Document.Page.Size,
                     completion: @escaping CompletionResult<Data>)

    /**
     *  Retrieves the page data of a document for a given page number and size
     *
     * - Parameter document:            The document from which to retrieve the page data
     * - Parameter pageNumber:          The document's page number
     * - Parameter size:                The size of the page to retrieve (e.g., large, medium)
     * - Parameter completion:          A completion callback, returning the requested page preview on success, or an error on failure
     */
    func documentPage(for document: Document,
                      pageNumber: Int,
                      size: Document.Page.Size,
                      completion: @escaping CompletionResult<Data>)

    /**
     *  Submits the analysis feedback for a given document.
     *
     * - Parameter document:            The document which the feedback will be updated to
     * - Parameter extractions:         The document's updated extractions
     * - Parameter completion:          A completion callback
     */
    func submitFeedback(for document: Document,
                        with extractions: [Extraction],
                        completion: @escaping CompletionResult<Void>)
    
    /**
     * Logs an error event.
     *
     * - Parameter errorEvent:          The error event details
     */
    func log(errorEvent: ErrorEvent,
             completion: @escaping CompletionResult<Void>)
}

protocol V2DocumentService: AnyObject {
    func createDocument(fileName: String?,
                        docType: Document.DocType?,
                        type: Document.TypeV2,
                        metadata: Document.Metadata?,
                        completion: @escaping CompletionResult<Document>)
}

protocol V1DocumentService: AnyObject {
    func createDocument(with data: Data,
                        fileName: String?,
                        docType: Document.DocType?,
                        metadata: Document.Metadata?,
                        completion: @escaping CompletionResult<Document>)
}

extension DocumentService {
    
    func documents(resourceHandler: ResourceDataHandler<APIResource<DocumentList>>,
                   limit: Int?,
                   offset: Int?,
                   completion: @escaping CompletionResult<[Document]>) {
        let resource = APIResource<DocumentList>(method: .documents(limit: limit, offset: offset),
                                                 apiDomain: apiDomain,
                                                 httpMethod: .get)
        resourceHandler(resource, { result in
            switch result {
            case .success(let documentList):
                completion(.success(documentList.documents))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func deleteDocument(resourceHandler: ResourceDataHandler<APIResource<String>>,
                        with id: String,
                        completion: @escaping CompletionResult<String>) {
        let resource = APIResource<String>(method: .document(id: id),
                                           apiDomain: apiDomain,
                                           httpMethod: .delete)
        
        resourceHandler(resource, { result in
            switch result {
            case .success(let string):
                completion(.success(string))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func extractions(resourceHandler: @escaping CancellableResourceDataHandler<APIResource<ExtractionsContainer>>,
                     documentResourceHandler: @escaping CancellableResourceDataHandler<APIResource<Document>>,
                     for document: Document,
                     cancellationToken: CancellationToken?,
                     completion: @escaping CompletionResult<ExtractionResult>) {
        poll(resourceHandler: documentResourceHandler,
             document: document,
             cancellationToken: cancellationToken) { result in
                switch result {
                case .success:
                    let resource = APIResource<ExtractionsContainer>(method: .extractions(forDocumentId: document.id),
                                                                     apiDomain: self.apiDomain,
                                                                     httpMethod: .get)
                    
                    resourceHandler(resource, cancellationToken, { result in
                        switch result {
                        case .success(let extractionsContainer):
                            completion(.success(ExtractionResult(extractionsContainer: extractionsContainer)))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    })
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }
    
    func fetchDocument(resourceHandler: CancellableResourceDataHandler<APIResource<Document>>,
                       with id: String,
                       cancellationToken: CancellationToken? = nil,
                       completion: @escaping CompletionResult<Document>) {
        let resource = APIResource<Document>(method: .document(id: id),
                                             apiDomain: apiDomain,
                                             httpMethod: .get)
        
        resourceHandler(resource, cancellationToken, { result in
            guard !(cancellationToken?.isCancelled ?? false) else {
                completion(.failure(.requestCancelled))
                return
            }
            switch result {
            case .success(let document):
                completion(.success(document))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func layout(resourceHandler: ResourceDataHandler<APIResource<Document.Layout>>,
                for document: Document,
                completion: @escaping CompletionResult<Document.Layout>) {
        let resource = APIResource<Document.Layout>(method: .layout(forDocumentId: document.id),
                                                    apiDomain: apiDomain,
                                                    httpMethod: .get)
        
        resourceHandler(resource, { result in
            switch result {
            case .success(let documentLayout):
                completion(.success(documentLayout))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func pages(resourceHandler: ResourceDataHandler<APIResource<[Document.Page]>>,
               in document: Document,
               completion: @escaping CompletionResult<[Document.Page]>) {
        let resource = APIResource<[Document.Page]>(method: .pages(forDocumentId: document.id),
                                                    apiDomain: apiDomain,
                                                    httpMethod: .get)
        
        resourceHandler(resource, { result in
            switch result {
            case .success(let pages):
                completion(.success(pages))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }

    func pages(resourceHandler: ResourceDataHandler<APIResource<[Document.Page]>>,
               for documentId: String,
               completion: @escaping CompletionResult<[Document.Page]>) {
        let resource = APIResource<[Document.Page]>(method: .pages(forDocumentId: documentId),
                                                    apiDomain: apiDomain,
                                                    httpMethod: .get)

        resourceHandler(resource, { result in
            switch result {
                case .success(let pages):
                    completion(.success(pages))
                case .failure(let error):
                    completion(.failure(error))
            }
        })
    }


    func pagePreview(resourceHandler: @escaping ResourceDataHandler<APIResource<Data>>,
                     in document: Document,
                     pageNumber: Int,
                     size: Document.Page.Size?,
                     completion: @escaping CompletionResult<Data>) {
        guard document.sourceClassification != .composite else {
            preconditionFailure("Composite documents does not have a page preview. " +
                "Fetch each partial page preview instead")
        }
        
        guard pageNumber > 0 else {
            preconditionFailure("The page number starts at 1")
        }
        
        let resource = APIResource<Data>(method: .page(forDocumentId: document.id,
                                                       number: pageNumber,
                                                       size: size),
                                         apiDomain: self.apiDomain,
                                         httpMethod: .get)
        
        resourceHandler(resource) { result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                if case .notFound = error {
                    print("Document \(document.id) page not found")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.pagePreview(resourceHandler: resourceHandler,
                                         in: document,
                                         pageNumber: pageNumber,
                                         size: size,
                                         completion: completion)
                    }
                } else {
                    completion(.failure(error))
                }
            }
            
        }
    }
    
    func preview(resourceHandler: @escaping ResourceDataHandler<APIResource<Data>>,
                 with documentId: String,
                 pageNumber: Int,
                 completion: @escaping CompletionResult<Data>) {
        let resource = APIResource<Data>(method: .pagePreview(forDocumentId: documentId,
                                                              number: pageNumber),
                                         apiDomain: self.apiDomain,
                                         httpMethod: .get)
        resourceHandler(resource) { result in
            switch result {
            case let .success(data):
                completion(.success(data))
            case let .failure(error):
                if case .notFound = error {
                    print("Document \(documentId) page not found")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.preview(resourceHandler: resourceHandler,
                                     with: documentId,
                                     pageNumber: pageNumber,
                                     completion: completion)
                    }
                } else {
                    completion(.failure(error))
                }
            }
        }
    }

    func documentPage(resourceHandler: @escaping ResourceDataHandler<APIResource<Data>>,
                      in document: Document,
                      pageNumber: Int,
                      size: Document.Page.Size,
                      completion: @escaping CompletionResult<Data>) {
        guard pageNumber > 0 else {
            preconditionFailure("The page number starts at 1")
        }

        let resource = APIResource<Data>(method: .documentPage(forDocumentId: document.id,
                                                               number: pageNumber,
                                                               size: .medium),
                                         apiDomain: apiDomain,
                                         httpMethod: .get)

        resourceHandler(resource) { result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                    completion(.failure(error))
            }
        }
    }

    func documentPage(resourceHandler: @escaping ResourceDataHandler<APIResource<Data>>,
                      in documentId: String,
                      pageNumber: Int,
                      size: Document.Page.Size,
                      completion: @escaping CompletionResult<Data>) {
        guard pageNumber > 0 else {
            preconditionFailure("The page number starts at 1")
        }

        let resource = APIResource<Data>(method: .documentPage(forDocumentId: documentId,
                                                               number: pageNumber,
                                                               size: .medium),
                                         apiDomain: apiDomain,
                                         httpMethod: .get)

        resourceHandler(resource) { result in
            switch result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }

    func submitFeedback(resourceHandler: ResourceDataHandler<APIResource<String>>,
                        for document: Document,
                        with extractions: [Extraction],
                        completion: @escaping CompletionResult<Void>) {
        guard let json = try? JSONEncoder().encode(ExtractionsFeedback(feedback: extractions)) else {
            assertionFailure("The extractions provided cannot be encoded")
            return
        }
        
        let resource = APIResource<String>(method: .feedback(forDocumentId: document.id),
                                           apiDomain: apiDomain,
                                           httpMethod: .post,
                                           body: json)
        
        resourceHandler(resource, { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
            
        })
    }
    
    func submitFeedback(resourceHandler: ResourceDataHandler<APIResource<String>>,
                        for document: Document,
                        with extractions: [Extraction],
                        and compoundExtractions: [String: [[Extraction]]],
                        completion: @escaping CompletionResult<Void>) {
        guard let json = try? JSONEncoder().encode(
            CompoundExtractionsFeedback(extractions: extractions, compoundExtractions: compoundExtractions)
            ) else {
                assertionFailure("The extractions provided cannot be encoded")
                return
        }
        
        let resource = APIResource<String>(method: .feedback(forDocumentId: document.id),
                                           apiDomain: apiDomain,
                                           httpMethod: .post,
                                           body: json)
        
        resourceHandler(resource, { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
            
        })
    }
    
    func log(resourceHandler: ResourceDataHandler<APIResource<String>>,
             errorEvent: ErrorEvent,
             completion: @escaping CompletionResult<Void>) {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let json = try? encoder.encode(errorEvent) else {
            assertionFailure("The error event provided cannot be encoded")
            return
        }
        
        let resource = APIResource<String>(method: .logErrorEvent,
                                           apiDomain: apiDomain,
                                           httpMethod: .post,
                                           body: json)
        
        resourceHandler(resource) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Fileprivate

fileprivate extension DocumentService {
    func poll(resourceHandler: @escaping CancellableResourceDataHandler<APIResource<Document>>,
              document: Document,
              cancellationToken: CancellationToken?,
              completion: @escaping CompletionResult<Void>) {
        fetchDocument(resourceHandler: resourceHandler,
                      with: document.id,
                      cancellationToken: cancellationToken) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let document):
                if document.progress != .pending {
                    completion(.success(()))
                } else {
                    DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                        self.poll(resourceHandler: resourceHandler,
                                 document: document,
                                 cancellationToken: cancellationToken,
                                 completion: completion)
                        }
                    }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
