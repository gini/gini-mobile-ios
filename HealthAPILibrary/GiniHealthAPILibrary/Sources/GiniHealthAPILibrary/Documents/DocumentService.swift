//
//  DocumentService.swift
//  GiniHealthAPI
//
//  Created by Enrique del Pozo Gómez on 3/21/19.
//

import Foundation

typealias ResourceDataHandler<T: Resource> = (T, @escaping CompletionResult<T.ResponseType>) -> Void
typealias CancellableResourceDataHandler<T: Resource> = (T, CancellationToken?,
    @escaping CompletionResult<T.ResponseType>) -> Void

public protocol DocumentService: AnyObject {
    
    var apiDomain: APIDomain { get }
    var apiVersion: Int { get }

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
     * - Parameter id:                  The document's unique identifier
     * - Parameter completion:          A completion callback, returning the requested document layout on success
     */
    func layout(for document: Document,
                completion: @escaping CompletionResult<Document.Layout>)
    
    /**
     *  Retrieves the pages of a given document
     *
     * - Parameter id:                  The document's unique identifier
     * - Parameter completion:          A completion callback, returning the requested document layout on success
     */
    func pages(in document: Document,
               completion: @escaping CompletionResult<[Document.Page]>)
    
    
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
     * Returns the data from the downloaded file via url
     *
     * - Parameter urlString:          The url of the file
     * - Parameter completion:          A completion callback with data
     */
    
    func file(urlString: String, completion: @escaping CompletionResult<Data>)

    /**
     *  Deletes a batch of documents
     *
     * - Parameter documentIds:         An array of document ids to be deleted
     * - Parameter completion:          An action for deleting a batch of documents. Result is a value that represents either a success or a failure, including an associated value in each case.
                                        In success it includes a success message
                                        In case of failure error from the server side.
     */
    func deleteDocuments(_ documentIds: [String], completion: @escaping CompletionResult<String>)
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
                                                 apiVersion: apiVersion,
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
                                           apiVersion: apiVersion,
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

    func deleteDocuments(resourceHandler: ResourceDataHandler<APIResource<String>>,
                         with ids: [String],
                         completion: @escaping CompletionResult<String>) {
        guard let json = try? JSONEncoder().encode(ids) else {
            assertionFailure("The document ids provided cannot be encoded")
            return
        }

        let resource = APIResource<String>(method: .documents(limit: nil, offset: nil),
                                           apiDomain: apiDomain,
                                           apiVersion: apiVersion,
                                           httpMethod: .delete,
                                           body: json)

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
            self.handlePollResult(result, document: document, resourceHandler: resourceHandler, cancellationToken: cancellationToken, completion: completion)
            
        }
    }

    private func handlePollResult(_ result: Result<Void, GiniError>,
                                  document: Document,
                                  resourceHandler: @escaping CancellableResourceDataHandler<APIResource<ExtractionsContainer>>,
                                  cancellationToken: CancellationToken?,
                                  completion: @escaping CompletionResult<ExtractionResult>) {
        switch result {
        case .success:
            let resource = APIResource<ExtractionsContainer>(method: .extractions(forDocumentId: document.id),
                                                             apiDomain: self.apiDomain,
                                                             apiVersion: self.apiVersion,
                                                             httpMethod: .get)
            
            resourceHandler(resource, cancellationToken, { result in
                self.handleExtractionsResult(result, completion: completion)
            })
        case .failure(let error):
            completion(.failure(error))
        }
        
    }
    private func handleExtractionsResult(_ result: Result<ExtractionsContainer, GiniError>,
                                         completion: @escaping CompletionResult<ExtractionResult>) {
        switch result {
        case .success(let extractionsContainer):
            completion(.success(ExtractionResult(extractionsContainer: extractionsContainer)))
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
    func fetchDocument(resourceHandler: CancellableResourceDataHandler<APIResource<Document>>,
                       with id: String,
                       cancellationToken: CancellationToken? = nil,
                       completion: @escaping CompletionResult<Document>) {
        let resource = APIResource<Document>(method: .document(id: id),
                                             apiDomain: apiDomain,
                                             apiVersion: apiVersion,
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
                                                    apiVersion: apiVersion,
                                                    httpMethod: .get)
        
        resourceHandler(resource, { result in
            switch result {
            case .success(let document):
                completion(.success(document))
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
                                                    apiVersion: apiVersion,
                                                    httpMethod: .get)
        
        resourceHandler(resource, { result in
            switch result {
            case .success(let document):
                completion(.success(document))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func pages(resourceHandler: ResourceDataHandler<APIResource<[Document.Page]>>,
               documentId: String,
               completion: @escaping CompletionResult<[Document.Page]>) {
        let resource = APIResource<[Document.Page]>(method: .pages(forDocumentId: documentId),
                                                    apiDomain: apiDomain,
                                                    apiVersion: apiVersion,
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
    
    func preview(resourceHandler: @escaping ResourceDataHandler<APIResource<[Document.Page]>>,
                 with documentId: String,
                 pageNumber: Int,
                 completion: @escaping CompletionResult<Data>) {
        let resource = APIResource<[Document.Page]>(method: .pages(forDocumentId: documentId),
                                                    apiDomain: self.apiDomain,
                                                    apiVersion: self.apiVersion,
                                                    httpMethod: .get)
        resourceHandler(resource) { result in
            switch result {
            case let .success(pages):
                self.handlePreviewPages(pages, pageNumber: pageNumber, completion: completion)
            
            case let .failure(error):
                self.retryPreviewIfNeeded(error: error, resourceHandler: resourceHandler, documentId: documentId, pageNumber: pageNumber, completion: completion)
            }
        }
    }
    
    private func handlePreviewPages(_ pages: [Document.Page],
                                    pageNumber: Int,
                                    completion: @escaping CompletionResult<Data>) {
        
        let page = pages.first {
            $0.number == pageNumber
        }
        if let page = page, page.images.count > 0 {
            let urlString = self.urlStringForHighestResolutionPreview(page: page)
            let url = "https://" + self.apiDomain.domainString + urlString
            self.file(urlString: url) { result in
                self.handleFileResult(result, completion: completion)
            }
        } else {
            completion(.failure(.notFound()))
        }
    }

    private func retryPreviewIfNeeded(error: GiniError,
                                      resourceHandler: @escaping ResourceDataHandler<APIResource<[Document.Page]>>,
                                      documentId: String,
                                      pageNumber: Int,
                                      completion: @escaping CompletionResult<Data>) {
        
        if case .notFound = error {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.preview(resourceHandler: resourceHandler,
                             with: documentId,
                             pageNumber: pageNumber,
                             completion: completion)
            }
        }
    }

    private func handleFileResult(_ result: Result<Data, GiniError>,
                                  completion: @escaping CompletionResult<Data>) {
        completion(result)
    }
    
    func urlStringForHighestResolutionPreview(page: Document.Page) -> String {
        let topBoundaryResolutionArea = 4000000
        var imageWithHighestResolution = page.images[0]
        var maxResolutionArea = 0
        var counter = 0

        for i in 0 ..< (page.images.count) {
            let imageResolutionArea = self.sizeFromString(sizeString: page.images[i].size.rawValue)

            if imageResolutionArea < topBoundaryResolutionArea {
                imageWithHighestResolution = page.images[i]
                maxResolutionArea = self.sizeFromString(sizeString: page.images[i].size.rawValue)
                counter = i
                break
            }
        }

        while counter < page.images.count {
            let imageResolutionArea = self.sizeFromString(sizeString: page.images[counter].size.rawValue )
            if imageResolutionArea > maxResolutionArea && imageResolutionArea < topBoundaryResolutionArea {
                maxResolutionArea = imageResolutionArea
                imageWithHighestResolution = page.images[counter]
            }
            counter = counter + 1
        }
        return imageWithHighestResolution.url.absoluteString
    }
    
    func file(urlString: String,
                          resourceHandler: ResourceDataHandler<APIResource<Data>>,
                          completion: @escaping CompletionResult<Data>) {
        var resource = APIResource<Data>(method: .file(urlString: urlString), 
                                         apiDomain: apiDomain,
                                         apiVersion: apiVersion,
                                         httpMethod: .get)
        resource.fullUrlString = urlString
        resourceHandler(resource) { result in
            switch result {
            case let .success(data):
                completion(.success(data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private func sizeFromString(sizeString: String) -> Int {
        let resolutionArray = sizeString.components(separatedBy: "x")
        let width = Int(resolutionArray[0]) ?? 0
        let height = Int(resolutionArray[1]) ?? 0
        return width * height
    }
    
    private func submitFeedback(resourceHandler: ResourceDataHandler<APIResource<String>>,
                                documentId: String,
                                extractions: [Extraction],
                                compoundExtractions: [String: [[Extraction]]]? = nil,
                                completion: @escaping CompletionResult<Void>) {
        let feedbackData: Encodable
        if let compoundExtractions = compoundExtractions {
            feedbackData = CompoundExtractionsFeedback(extractions: extractions, compoundExtractions: compoundExtractions)
        } else {
            feedbackData = ExtractionsFeedback(feedback: extractions)
        }
        
        guard let json = try? JSONEncoder().encode(feedbackData) else {
            assertionFailure("The extractions provided cannot be encoded")
            return
        }
        
        let resource = APIResource<String>(method: .feedback(forDocumentId: documentId),
                                           apiDomain: apiDomain,
                                           apiVersion: apiVersion,
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
    
    func submitFeedback(resourceHandler: ResourceDataHandler<APIResource<String>>,
                        for document: Document,
                        with extractions: [Extraction],
                        completion: @escaping CompletionResult<Void>) {
        submitFeedback(resourceHandler: resourceHandler,
                       documentId: document.id,
                       extractions: extractions,
                       completion: completion)
    }
    
    func submitFeedback(resourceHandler: ResourceDataHandler<APIResource<String>>,
                        for document: Document,
                        with extractions: [Extraction],
                        and compoundExtractions: [String: [[Extraction]]],
                        completion: @escaping CompletionResult<Void>) {
        submitFeedback(resourceHandler: resourceHandler,
                       documentId: document.id,
                       extractions: extractions,
                       compoundExtractions: compoundExtractions,
                       completion: completion)
    }
    
    func submitFeedback(resourceHandler: ResourceDataHandler<APIResource<String>>,
                        documentId: String,
                        with extractions: [Extraction],
                        completion: @escaping CompletionResult<Void>) {
        submitFeedback(resourceHandler: resourceHandler,
                       documentId: documentId,
                       extractions: extractions,
                       completion: completion)
    }
    
    func submitFeedback(resourceHandler: ResourceDataHandler<APIResource<String>>,
                        documentId: String,
                        with extractions: [Extraction],
                        and compoundExtractions: [String: [[Extraction]]],
                        completion: @escaping CompletionResult<Void>) {
        submitFeedback(resourceHandler: resourceHandler,
                       documentId: documentId,
                       extractions: extractions,
                       compoundExtractions: compoundExtractions,
                       completion: completion)
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
            case let .success(document):
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
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
