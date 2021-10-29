//
//  DocumentService.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 2/14/18.
//

import UIKit
import GiniBankAPILibrary

public final class DocumentService: DocumentServiceProtocol {
    
    var partialDocuments: [String: PartialDocument] = [:]
    public var document: Document?
    public var analysisCancellationToken: CancellationToken?
    public var metadata: Document.Metadata?
    var documentService: DefaultDocumentService
    
    public init(lib: GiniBankAPI, metadata: Document.Metadata?) {
        self.metadata = metadata
        self.documentService = lib.documentService()
    }
    
    public func startAnalysis(completion: @escaping AnalysisCompletion) {
        let partialDocumentsInfoSorted = partialDocuments
            .lazy
            .map { $0.value }
            .sorted()
            .map { $0.info }
        
        self.fetchExtractions(for: partialDocumentsInfoSorted, completion: completion)
    }
    
    public func cancelAnalysis() {
        if let compositeDocument = document {
            delete(compositeDocument)
        }
        
        analysisCancellationToken?.cancel()
        analysisCancellationToken = nil
        document = nil
    }
    
    public func remove(document: GiniCaptureDocument) {
        if let index = partialDocuments.index(forKey: document.id) {
            if let document = partialDocuments[document.id]?
                .document {
                delete(document)
            }
            partialDocuments.remove(at: index)
        }
    }
    
    public func resetToInitialState() {
        partialDocuments.removeAll()
        analysisCancellationToken = nil
        document = nil
    }
    
    public func update(imageDocument: GiniImageDocument) {
        partialDocuments[imageDocument.id]?.info.rotationDelta = imageDocument.rotationDelta
    }
    
    public func sendFeedback(with updatedExtractions: [Extraction]) {
        Log(message: "Sending feedback", event: "💬")
        guard let document = document else {
            Log(message: "Cannot send feedback: no document", event: .error)
            return
        }
        documentService.submitFeedback(for: document, with: updatedExtractions) { result in
            switch result {
            case .success:
                Log(message: "Feedback sent with \(updatedExtractions.count) extractions",
                    event: "🚀")
            case .failure(let error):
                let message = "Error sending feedback for document with id: \(document.id) error: \(error)"
                Log(message: message, event: .error)
                let errorLog = ErrorLog(description: message, error: error)
                GiniConfiguration.shared.errorLogger.handleErrorLog(error: errorLog)
            }
            
        }
    }
    
    public func sortDocuments(withSameOrderAs documents: [GiniCaptureDocument]) {
        for index in 0..<documents.count {
            let id = documents[index].id
            partialDocuments[id]?.order = index
        }
    }
    
    public func upload(document: GiniCaptureDocument,
                completion: UploadDocumentCompletion?) {
        self.partialDocuments[document.id] =
            PartialDocument(info: (PartialDocumentInfo(document: nil, rotationDelta: 0)),
                            document: nil,
                            order: self.partialDocuments.count)
        let fileName = "Partial-\(NSDate().timeIntervalSince1970)"
        
        createDocument(from: document, fileName: fileName) { result in
            switch result {
            case .success(let createdDocument):
                self.partialDocuments[document.id]?.document = createdDocument
                self.partialDocuments[document.id]?.info.document = createdDocument.links.document
                
                completion?(.success(createdDocument))
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
    
    public func log(errorEvent: ErrorEvent) {
        documentService.log(errorEvent: errorEvent) { result in
            switch result {
            case .success:
                Log(message: "Error event sent to Gini", event: .success)
                break
            case .failure(let error):
                Log(message: "Failed to send error event to Gini: \(error)", event: .error)
                break
            }
        }
    }
    
}

// MARK: - File private methods

fileprivate extension DocumentService {
    func createDocument(from document: GiniCaptureDocument,
                        fileName: String,
                        docType: Document.DocType? = nil,
                        completion: @escaping UploadDocumentCompletion) {
        Log(message: "Creating document...", event: "📝")
        
        documentService.createDocument(fileName: fileName,
                                       docType: docType,
                                       type: .partial(document.data),
                                       metadata: metadata) { result in
                                        switch result {
                                        case .success(let createdDocument):
                                            Log(message: "Created document with id: \(createdDocument.id) " +
                                                "for vision document \(document.id)", event: "📄")
                                            completion(.success(createdDocument))
                                        case .failure(let error):
                                            let message = "Document creation failed"
                                            Log(message: message, event: .error)
                                            let errorLog = ErrorLog(description: message, error: error)
                                            GiniConfiguration.shared.errorLogger.handleErrorLog(error: errorLog)
                                            completion(.failure(error))
                                        }
        }
    }
    
    func delete(_ document: Document) {
        documentService.delete(document) { result in
            switch result {
            case .success:
                Log(message: "Deleted \(document.sourceClassification.rawValue) document with id: \(document.id)",
                    event: "🗑")
            case .failure(let error):
                let message = "Error deleting \(document.sourceClassification.rawValue) document with" +
                    " id: \(document.id)"
                Log(message: message,event: .error)
                let errorLog = ErrorLog(description: message, error: error)
                GiniConfiguration.shared.errorLogger.handleErrorLog(error: errorLog)
            }
        }
    }
    
    func fetchExtractions(for documents: [PartialDocumentInfo],
                          completion: @escaping AnalysisCompletion) {
        Log(message: "Creating composite document...", event: "📑")
        let fileName = "Composite-\(NSDate().timeIntervalSince1970)"
        
        documentService
            .createDocument(fileName: fileName,
                            docType: nil,
                            type: .composite(CompositeDocumentInfo(partialDocuments: documents)),
                            metadata: metadata) { [weak self] result in
                                guard let self = self else { return }
                                switch result {
                                case .success(let createdDocument):
                                    Log(message: "Starting analysis for composite document \(createdDocument.id)",
                                        event: "🔎")
                                    self.document = createdDocument
                                    self.analysisCancellationToken = CancellationToken()
                                    self.documentService
                                        .extractions(for: createdDocument,
                                                     cancellationToken: self.analysisCancellationToken!,
                                                     completion: self.handleResults(completion: completion))
                                case .failure(let error):
                                    let message = "Composite document creation failed"
                                    Log(message: message, event: .error)
                                    let errorLog = ErrorLog(description: message, error: error)
                                    GiniConfiguration.shared.errorLogger.handleErrorLog(error: errorLog)
                                    completion(.failure(error))
                                }
        }
        
    }
}
