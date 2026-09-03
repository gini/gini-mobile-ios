//
//  DefaultDocumentService.swift
//  GiniHealthAPI
//
//  Created by Enrique del Pozo Gómez on 3/22/19.
//

import Foundation
import UIKit

typealias DefaultDocumentServiceProtocol = DocumentService & V2DocumentService

/// The default document service. By default interacts with the `APIDomain.default` api.
public final class DefaultDocumentService: DefaultDocumentServiceProtocol {
    
    let sessionManager: SessionManagerProtocol
    
    public var apiDomain: APIDomain
    public var apiVersion: Int

    init(sessionManager: SessionManagerProtocol, apiDomain: APIDomain = .default, apiVersion: Int) {
        self.sessionManager = sessionManager
        self.apiDomain = apiDomain
        self.apiVersion = apiVersion
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
                                                                            mimeSubType: .json,
                                                                            documentType: type),
                                                    apiDomain: apiDomain, 
                                                    apiVersion: apiVersion,
                                                    httpMethod: .post,
                                                    additionalHeaders: metadata?.headers ?? [:],
                                                    body: try? JSONEncoder().encode(compositeDocumentInfo))
            sessionManager.data(resource: resource, completion: completionResult)
        case .partial(let data):
            let resource = APIResource<String>.init(method: .createDocument(fileName: fileName,
                                                                            docType: docType,
                                                                            mimeSubType: .json,
                                                                            documentType: type),
                                                    apiDomain: apiDomain, 
                                                    apiVersion: apiVersion,
                                                    httpMethod: .post,
                                                    additionalHeaders: metadata?.headers ?? [:])
            guard let processedData = processDataIfNeeded(data: data) else {
                completion(.failure(.parseError(message: "Couldn't process data received.", response: nil, data: nil)))
                return
            }
            sessionManager.upload(resource: resource, data: processedData, completion: completionResult)
        }
    }

    func processDataIfNeeded(data: Data) -> Data? {
        // Check if data received is image. Otherwise, pass back the data
        guard data.isImage() else {
            return data
        }
        // Check if image should be compressed
        guard data.isImageSizeBiggerThan(maximumSizeInMB: Constants.maximumImageSizeInMB) else {
            return data
        }
        // Compress image to needed size
        guard let compressedData = compressImageToMax(imageData: data, mb: Constants.maximumImageSizeInMB) else {
            return data
        }
        return compressedData
    }

    private func compressImageToMax(imageData: Data, mb: Double) -> Data? {
        let maxFileSize: Double = mb * 1024 * 1024 // 10 MB in bytes
        let image = UIImage(data: imageData)
        guard let initialData = image?.jpegData(compressionQuality: 1.0) else { return nil }
        let initialSize = Double(initialData.count)
        if initialSize <= maxFileSize {
            return initialData // Already below given MB
        }
        // Calculate the required compression quality so that image size will be under given MB
        let compressionQuality: CGFloat = CGFloat(maxFileSize / initialSize)
        let compressedImageData = image?.jpegData(compressionQuality: compressionQuality)
        return compressedImageData
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
     * Submits the analysis feedback for a given document ID.
     *
     * - Parameter documentId:      The ID of the document for which feedback should be sent.
     * - Parameter extractions:     The document's updated extractions.
     * - Parameter completion:      A completion callback.
     */
    public func submitFeedback(for documentId: String,
                               with extractions: [Extraction],
                               completion: @escaping CompletionResult<Void>) {
        submitFeedback(resourceHandler: sessionManager.data,
                       documentId: documentId,
                       with: extractions,
                       completion: completion)
    }

    /**
     * Submits the analysis feedback with compound extractions (e.g., "line items") for a given document ID.
     *
     * - Parameter documentId:          The ID of the document for which feedback should be sent.
     * - Parameter extractions:         The document's updated extractions.
     * - Parameter compoundExtractions: The document's updated compound extractions.
     * - Parameter completion:          A completion callback.
     */
    public func submitFeedback(for documentId: String,
                               with extractions: [Extraction],
                               and compoundExtractions: [String: [[Extraction]]],
                               completion: @escaping CompletionResult<Void>) {
        submitFeedback(resourceHandler: sessionManager.data,
                       documentId: documentId,
                       with: extractions,
                       and: compoundExtractions,
                       completion: completion)
    }

    /**
     * Submits the analysis feedback for a given document.
     *
     * - Parameter document:        The document for which feedback should be sent.
     * - Parameter extractions:     The document's updated extractions.
     * - Parameter completion:      A completion callback.
     */
    public func submitFeedback(for document: Document,
                               with extractions: [Extraction],
                               completion: @escaping CompletionResult<Void>) {
        submitFeedback(
            resourceHandler: sessionManager.data,
            documentId: document.id,
            with: extractions,
            completion: completion)
    }

    /**
     * Submits the analysis feedback with compound extractions (e.g., "line items") for a given document.
     *
     * - Parameter document:            The document for which feedback should be sent.
     * - Parameter extractions:         The document's updated extractions.
     * - Parameter compoundExtractions: The document's updated compound extractions.
     * - Parameter completion:          A completion callback.
     */
    public func submitFeedback(for document: Document,
                               with extractions: [Extraction],
                               and compoundExtractions: [String: [[Extraction]]],
                               completion: @escaping CompletionResult<Void>) {
        submitFeedback(resourceHandler: sessionManager.data,
                       documentId: document.id,
                       with: extractions,
                       and: compoundExtractions,
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
    
    public func file(urlString: String, completion: @escaping CompletionResult<Data>){
        file(urlString: urlString, resourceHandler: sessionManager.download, completion: completion)
    }

    /**
     *  Deletes a batch of documents
     *
     * - Parameter documentIds:         An array of document ids to be deleted
     * - Parameter completion:          An action for deleting a batch of documents. Result is a value that represents either a success or a failure, including an associated value in each case.
                                        In success it includes a success message
                                        In case of failure error from the server side.
     */
    public func deleteDocuments(_ documentIds: [String], completion: @escaping CompletionResult<String>) {
        deleteDocuments(resourceHandler: sessionManager.data, with: documentIds, completion: completion)
    }
}

extension DefaultDocumentService {
    enum Constants {
        static let maximumImageSizeInMB = 10.0
    }
}
