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
                completion: @escaping (Result<Document.Layout, GiniError>) -> Void)

    func pagePreview(for document: Document,
                     pageNumber: Int,
                     size: Document.Page.Size,
                     completion: @escaping (Result<Data, GiniError>) -> Void)
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
                completion: @escaping CompletionResult<Document.Layout>) {
        // Default implementation is empty
    }
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
                     completion: @escaping CompletionResult<Data>) {
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
                self.handleError(message: message, error: error)
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
                    self.handleError(message: "Composite document creation failed with error: \(error)", 
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
                self.handleError(message: "Document creation failed with error: \(error)", error: error)
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
                    self.handleError(message: "Document layout retrieval encountered an error: \(error)", 
                                     error: error)
                    completion(.failure(error))
            }
        }
    }

    func pagePreview(for document: Document,
                     pageNumber: Int, 
                     size: GiniBankAPILibrary.Document.Page.Size,
                     completion: @escaping DocumentPagePreviewCompletion) {
        Log(message: "Getting page preview for document with id: \(document.id) ", event: "📝")
        documentService.pagePreview(for: document,
                                    pageNumber: pageNumber,
                                    size: size) { result in
            switch result {
                case let .success(pageData):
                    completion(.success(pageData))
                case let .failure(error):
                    self.handleError(message: "Document page preview retrieval encountered an error: \(error)", 
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
                        switch error {
                            case .requestCancelled:
                                Log(message: "Cancelled analysis process", event: .error)
                            default:
                                Log(message: "Finished analysis process with error: \(error)", event: .error)
                        }
                        completion(.failure(error))
                }
            }
    }

    private func handleError(message: String, error: GiniError) {
        Log(message: message, event: .error)
        let errorLog = ErrorLog(description: message, error: error)
        GiniConfiguration.shared.errorLogger.handleErrorLog(error: errorLog)
    }
}
