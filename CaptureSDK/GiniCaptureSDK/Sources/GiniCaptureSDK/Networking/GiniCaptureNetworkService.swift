//
//  File.swift
//  
//
//  Created by Alpár Szotyori on 12.01.22.
//

import Foundation
import GiniBankAPILibrary

public protocol GiniCaptureNetworkService {
    func delete(document: GiniCaptureDocument)
    func cleanup()
    func analyse(partialDocuments: [PartialDocumentInfo], metadata: Document.Metadata?, completion: @escaping AnalysisCompletion)
    func upload(document: GiniCaptureDocument,
                metadata: Document.Metadata?,
                completion: @escaping UploadDocumentCompletion)
}

class DefaultCaptureNetworkService: GiniCaptureNetworkService {
    
    var documentService: DefaultDocumentService
    
    public init(lib: GiniBankAPI) {
        self.documentService = lib.documentService()
    }
    
    func delete(document: GiniCaptureDocument) {
        
    }
    
    func cleanup() {
        
    }
    
    func analyse(partialDocuments: [PartialDocumentInfo], metadata: Document.Metadata?, completion: @escaping AnalysisCompletion) {
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
                    let analysisCancellationToken = CancellationToken()
                    self.documentService
                        .extractions(for: createdDocument,
                                     cancellationToken: analysisCancellationToken) { [weak self] result in
                            guard self != nil else { return }
                            switch result {
                            case let .success(extractionResult):
                                completion(.success(extractionResult))
                            case let .failure(error):
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
    
    func upload(document: GiniCaptureDocument, metadata: Document.Metadata?, completion: @escaping UploadDocumentCompletion) {
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
}
