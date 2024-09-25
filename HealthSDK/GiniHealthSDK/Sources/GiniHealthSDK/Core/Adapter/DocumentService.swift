//
//  DefaultDocumentService.swift
//  GiniHealthSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import GiniHealthAPILibrary

/// The default document service. By default interacts with the `APIDomain.default` api.
public final class DefaultDocumentService {

    private let docService: GiniHealthAPILibrary.DefaultDocumentService

    init(docService: GiniHealthAPILibrary.DefaultDocumentService) {
        self.docService = docService
        self.docService.apiDomain = .default
        self.docService.apiVersion = GiniHealth.Constants.defaultVersionAPI
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
        docService.createDocument(fileName: fileName,
                                  docType: GiniHealthAPILibrary.Document.DocType(rawValue: docType?.rawValue ?? ""),
                                  type: type.toHealthType(),
                                  metadata: metadata?.healthMeta,
                                  completion: { result in
            switch result {
            case .success(let document):
                completion(.success(Document(healthDocument: document)))
            case .failure(let error):
                completion(.failure(GiniError.decorator(error)))
            }
        })

    }

    /**
     *  Deletes a document
     *
     * - Parameter document:            Document to be deleted
     * - Parameter completion:          A completion callback
     */
    public func delete(_ document: Document, completion: @escaping CompletionResult<String>) {
        docService.delete(document.toHealthDocument(),
                          completion: { result in
            switch result {
            case .success(let item):
                completion(.success(item))
            case .failure(let error):
                completion(.failure(GiniError.decorator(error)))
            }
        })
    }

    /**
     *  Fetches the user documents, with the possibility to retrieve them paginated
     *
     * - Parameter limit:               Limit of documents to retrieve
     * - Parameter offset:              Document's offset
     * - Parameter completion:          A completion callback, returning the document list on success
     */
    public func documents(limit: Int?, offset: Int?, completion: @escaping CompletionResult<[Document]>) {
        docService.documents(limit: limit,
                             offset: offset,
                             completion: { result in
            switch result {
            case .success(let documents):
                completion(.success(documents.compactMap { Document(healthDocument: $0) }))
            case .failure(let error):
                completion(.failure(GiniError.decorator(error)))
            }
        })
    }

    /**
     *  Retrieves a document for a given document id
     *
     * - Parameter id:                  The document's unique identifier
     * - Parameter completion:          A completion callback, returning the requested document on success
     */
    public func fetchDocument(with id: String, completion: @escaping CompletionResult<Document>) {
        docService.fetchDocument(with: id,
                                 completion: { result in
            switch result {
            case .success(let item):
                completion(.success(Document(healthDocument: item)))
            case .failure(let error):
                completion(.failure(GiniError.decorator(error)))
            }
        })
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
        docService.extractions(for: document.toHealthDocument(),
                               cancellationToken: cancellationToken.healthToken,
                               completion: { result in
            switch result {
            case .success(let healthExtractionResult):
                completion(.success(ExtractionResult(healthExtractionResult: healthExtractionResult)))
            case .failure(let error):
                completion(.failure(GiniError.decorator(error)))
            }
        })
    }

    /**
     *  Retrieves the layout of a given document
     *
     * - Parameter id:                  The document's unique identifier
     * - Parameter completion:          A completion callback, returning the requested document layout on success
     */
    public func layout(for document: Document, completion: @escaping CompletionResult<Document.Layout>) {
        docService.layout(for: document.toHealthDocument(),
                          completion: { result in
            switch result {
            case .success(let item):
                completion(.success(Document.Layout(healthLayout: item)))
            case .failure(let error):
                completion(.failure(GiniError.decorator(error)))
            }
        })
    }

    /**
     *  Retrieves the pages of a given document
     *
     * - Parameter id:                  The document's unique identifier
     * - Parameter completion:          A completion callback, returning the requested document layout on success
     */
    public func pages(in document: Document, completion: @escaping CompletionResult<[Document.Page]>) {
        docService.pages(in: document.toHealthDocument(),
                        completion: { result in
           switch result {
           case .success(let pages):
               completion(.success(pages.compactMap { Document.Page(healthPage: $0) }))
           case .failure(let error):
               completion(.failure(GiniError.decorator(error)))
           }
       })
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
        let healthExtractions = extractions.map { $0.toHealthExtraction() }
        docService.submitFeedback(for: document.toHealthDocument(),
                                  with: healthExtractions,
                                  completion: { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(GiniError.decorator(error)))
            }
        })
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
        let healthExtractions = extractions.map { $0.toHealthExtraction() }
        let healthCompoundExtractions = compoundExtractions.mapValues { mapCompoundExtraction($0) }
        docService.submitFeedback(for: document.toHealthDocument(),
                                  with: healthExtractions,
                                  and: healthCompoundExtractions,
                                  completion: { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(GiniError.decorator(error)))
            }
        })
    }

    private func mapCompoundExtraction(_ compoundExtraction: [[Extraction]]) -> [[GiniHealthAPILibrary.Extraction]] {
        return compoundExtraction.map { $0.map { $0.toHealthExtraction() } }
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
        docService.preview(for: documentId,
                           pageNumber: pageNumber,
                           completion: { result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(GiniError.decorator(error)))
            }
        })
    }

    public func file(urlString: String, completion: @escaping CompletionResult<Data>){
        docService.file(urlString: urlString,
                        completion: { result in
                switch result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(GiniError.decorator(error)))
                }
            })
    }
}
