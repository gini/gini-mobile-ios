//
//  GiniCaptureNetworkService.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import GiniBankAPILibrary

public protocol GiniCaptureNetworkService: AnyObject  {
    func delete(document: Document,
                completion: @escaping (Result<String, GiniError>) -> Void)
    func cleanup()
    
    func analyse(partialDocuments: [PartialDocumentInfo],
                 metadata: Document.Metadata?,
                 cancellationToken: CancellationToken,
                 completion: @escaping (Result<(document: Document, extractionResult: ExtractionResult), GiniError>) -> Void)
    func upload(document: GiniCaptureDocument,
                metadata: Document.Metadata?,
                completion: @escaping UploadDocumentCompletion)
    func sendFeedback(document: Document,
                      updatedExtractions: [Extraction],
                      updatedCompoundExtractions: [String: [[Extraction]]]?,
                      completion: @escaping (Result<Void, GiniError>) -> Void)
    func log(errorEvent: ErrorEvent,
             completion: @escaping (Result<Void, GiniError>) -> Void)

    func layout(for document: Document,
                completion: @escaping DocumentLayoutCompletion)
    func pages(for document: Document, completion: @escaping DocumentPagsCompletion)
    func documentPage(for document: Document,
                      pageNumber: Int,
                      size: GiniBankAPILibrary.Document.Page.Size,
                      completion: @escaping DocumentPagePreviewCompletion)
}

/// Extension for `GiniCaptureNetworkService` protocol to provide default implementations
public extension GiniCaptureNetworkService {

    /**
     *  Retrieves the layout of a given document
     *
     * - Parameter document:            The document for which the layout is requested
     * - Parameter completion:          A completion callback, returning the requested document layout on success
     */
    func layout(for document: Document,
                completion: @escaping DocumentLayoutCompletion) {
        // Default implementation is empty
    }

    /**
     *  Retrieves the pages of a given document
     *
     * - Parameter document:            The document from which to retrieve the pages
     * - Parameter completion:          A completion callback, returning the requested document layout on success
     */
    func pages(for document: Document, completion: @escaping DocumentPagsCompletion) {
        // Default implementation is empty
    }

    /**
     *  Retrieves the page data of a document for a specified page number and size
     *
     * - Parameter document:            The document from which to retrieve the page data
     * - Parameter pageNumber:          The page number within the document to retrieve
     * - Parameter size:                The size of the page to retrieve (e.g., large, medium)
     * - Parameter completion:          A completion callback that returns a `Result<Data, GiniError>`, with the requested page data on success, or an error on failure
    */
    func documentPage(for document: Document,
                      pageNumber: Int,
                      size: Document.Page.Size,
                      completion: @escaping DocumentPagePreviewCompletion) {
        // Default implementation is empty
    }
}

class DefaultCaptureNetworkService: GiniCaptureNetworkService {

    var documentService: DefaultDocumentService
    
    public init(lib: GiniBankAPI) {
        self.documentService = lib.documentService()
    }
    
    func delete(document: Document, completion: @escaping (Result<String, GiniError>) -> Void) {
        documentService.delete(document) { result in
            switch result {
            case .success(let result):
                completion(.success(result))
                Log(message: "Deleted \(document.sourceClassification.rawValue) document with id: \(document.id)",
                    event: "🗑")
            case .failure(let error):
                let message = "Error deleting \(document.sourceClassification.rawValue) document with" +
                    " id: \(document.id)"
                self.logError(message: message, error: error)
                completion(.failure(error))
            }
        }
    }
    
    func cleanup() {}
    
    func analyse(partialDocuments: [PartialDocumentInfo],
                 metadata: Document.Metadata?,
                 cancellationToken: CancellationToken,
                 completion: @escaping (Result<(document: Document, extractionResult: ExtractionResult), GiniError>) -> Void) {
        Log(message: "Creating composite document...", event: "📑")
        let fileName = "Composite-\(NSDate().timeIntervalSince1970)"

        documentService
            .createDocument(fileName: fileName,
                            docType: nil,
                            type: .composite(CompositeDocumentInfo(partialDocuments: partialDocuments)),
                            metadata: metadata) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .success(createdDocument):
                    Log(message: "Starting analysis for composite document \(createdDocument.id)",
                        event: "🔎")
                        self.startExtraction(for: createdDocument,
                                             cancellationToken: cancellationToken,
                                             completion: completion)
                case let .failure(error):
                    self.logError(message: "Composite document creation failed with error: \(error)", 
                                     error: error)
                    completion(.failure(error))
                }
            }
    }
    
    func upload(document: GiniCaptureDocument,
                metadata: Document.Metadata?,
                completion: @escaping UploadDocumentCompletion) {
        Log(message: "Creating document...", event: "📝")

        let fileName = "Partial-\(NSDate().timeIntervalSince1970)"

        documentService.createDocument(fileName: fileName,
                                       docType: nil,
                                       type: .partial(document.data),
                                       metadata: metadata) { result in
            switch result {
            case let .success(createdDocument):
                Log(message: "Created document with id: \(createdDocument.id) " +
                    "for vision document \(document.id)", event: "📄")
                completion(.success(createdDocument))
            case let .failure(error):
                self.logError(message: "Document creation failed with error: \(error)", error: error)
                completion(.failure(error))
            }
        }
    }
    
    func log(errorEvent: ErrorEvent,
             completion: @escaping (Result<Void, GiniError>) -> Void) {
        documentService.log(errorEvent: errorEvent) { result in
            completion(result)
        }
    }
    
    func sendFeedback(document: Document,
                      updatedExtractions: [Extraction],
                      updatedCompoundExtractions: [String: [[Extraction]]]?,
                      completion: @escaping (Result<Void, GiniError>) -> Void) {
        if let updatedCompoundExtractions = updatedCompoundExtractions {
            documentService.submitFeedback(for: document, with: updatedExtractions, and: updatedCompoundExtractions) { result in
                completion(result)
            }
        } else {
            documentService.submitFeedback(for: document, with: updatedExtractions) { result in
                completion(result)
            }
        }
    }

    func layout(for document: Document, completion: @escaping DocumentLayoutCompletion) {
        Log(message: "Getting layout for document with id: \(document.id) ", event: "📝")
        documentService.layout(for: document) { result in
            switch result {
            case let .success(layout):
                completion(.success(layout))
            case let .failure(error):
                self.logError(message: "Document layout retrieval encountered an error: \(error)",
                              error: error)
                completion(.failure(error))
            }
        }
    }

    func pages(for document: Document, completion: @escaping (Result<[Document.Page], GiniError>) -> Void) {
        Log(message: "Getting pages for document with id: \(document.id) ", event: "📝")
        documentService.pages(in: document) { result in
            switch result {
                case let .success(pages):
                    completion(.success(pages))
                case let .failure(error):
                    self.logError(message: "Document pages retrieval encountered an error: \(error)",
                                  error: error)
                    completion(.failure(error))
            }
        }
    }

    func documentPage(for document: Document,
                      pageNumber: Int,
                      size: GiniBankAPILibrary.Document.Page.Size,
                      completion: @escaping DocumentPagePreviewCompletion) {
        Log(message: "Getting page for document with id: \(document.id) ", event: "📝")
        documentService.documentPage(for: document,
                                     pageNumber: pageNumber,
                                     size: size) { result in
            switch result {
            case let .success(pageData):
                completion(.success(pageData))
            case let .failure(error):
                self.logError(message: "Document page retrieval encountered an error: \(error)",
                              error: error)
                completion(.failure(error))
            }
        }
    }

    // MARK: - Private helper methods

    private func startExtraction(for document: Document,
                                 cancellationToken: CancellationToken,
                                 completion: @escaping (Result<(document: Document, 
                                                                extractionResult: ExtractionResult), GiniError>) -> Void) {
        documentService
            .extractions(for: document,
                         cancellationToken: cancellationToken) { result in
                switch result {
                case let .success(extractionResult):
                    Log(message: "Finished analysis process with no errors", event: .success)
                    completion(.success((document, extractionResult)))
                case let .failure(error):
                    if error == .requestCancelled {
                        Log(message: "Cancelled analysis process", event: .error)
                    } else {
                        Log(message: "Finished analysis process with error: \(error)", event: .error)
                    }
                    completion(.failure(error))
                }
            }
    }

    private func logError(message: String, error: GiniError) {
        Log(message: message, event: .error)
        let errorLog = ErrorLog(description: message, error: error)
        GiniConfiguration.shared.errorLogger.handleErrorLog(error: errorLog)
    }
}
