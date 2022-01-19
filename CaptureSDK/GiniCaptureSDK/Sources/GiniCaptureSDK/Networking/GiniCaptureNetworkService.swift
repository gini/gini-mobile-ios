//
//  GiniCaptureNetworkService.swift
//  
//
//  Created by Alpár Szotyori on 12.01.22.
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
                 completion: @escaping (Result<(document: Document,extractionResult: ExtractionResult), GiniError>) -> Void)
    func upload(document: GiniCaptureDocument,
                metadata: Document.Metadata?,
                completion: @escaping UploadDocumentCompletion)
    func sendFeedback(document: Document,
                      updatedExtractions: [Extraction],
                      completion: @escaping (Result<Void, GiniError>) -> Void)
    func log(errorEvent: ErrorEvent,
             completion: @escaping (Result<Void, GiniError>) -> Void)
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
                completion(.failure(error))
                let message = "Error deleting \(document.sourceClassification.rawValue) document with" +
                    " id: \(document.id)"
                Log(message: message,event: .error)
                let errorLog = ErrorLog(description: message, error: error)
                GiniConfiguration.shared.errorLogger.handleErrorLog(error: errorLog)
            }
        }
    }
    
    func cleanup() {}
    
    func analyse(partialDocuments: [PartialDocumentInfo],
                 metadata: Document.Metadata?,
                 cancellationToken: CancellationToken,
                 completion: @escaping (Result<(document:Document,extractionResult: ExtractionResult), GiniError>) -> Void) {
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
                    self.documentService
                        .extractions(for: createdDocument,
                                     cancellationToken: cancellationToken) { [weak self] result in
                            guard self != nil else { return }
                            switch result {
                            case let .success(extractionResult):
                                Log(message: "Finished analysis process with no errors", event: .success)
                                completion(.success((createdDocument, extractionResult)))
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
                case let .failure(error):
                    let message = "Composite document creation failed"
                    Log(message: message, event: .error)
                    let errorLog = ErrorLog(description: message, error: error)
                    GiniConfiguration.shared.errorLogger.handleErrorLog(error: errorLog)
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
                let message = "Document creation failed"
                Log(message: message, event: .error)
                let errorLog = ErrorLog(description: message, error: error)
                GiniConfiguration.shared.errorLogger.handleErrorLog(error: errorLog)
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
                      completion: @escaping (Result<Void, GiniError>) -> Void) {
        documentService.submitFeedback(for: document, with: updatedExtractions) { result in
            completion(result)
        }
    }
}
