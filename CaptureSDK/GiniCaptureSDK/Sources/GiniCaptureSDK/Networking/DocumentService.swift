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
    
    var defaultCaptureNetworkService: DefaultCaptureNetworkService
    
    public init(lib: GiniBankAPI, metadata: Document.Metadata?) {
        self.metadata = metadata
        self.documentService = lib.documentService()
        self.defaultCaptureNetworkService = DefaultCaptureNetworkService(lib: lib)
    }
    
    public func upload(document: GiniCaptureDocument,
                completion: UploadDocumentCompletion?) {
        self.partialDocuments[document.id] =
            PartialDocument(info: (PartialDocumentInfo(document: nil, rotationDelta: 0)),
                            document: nil,
                            order: self.partialDocuments.count)
        
        defaultCaptureNetworkService.upload(document: document, metadata: metadata) { result in
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
    
    public func startAnalysis(completion: @escaping AnalysisCompletion) {
        let partialDocumentsInfoSorted = partialDocuments
            .lazy
            .map { $0.value }
            .sorted()
            .map { $0.info }
        
        defaultCaptureNetworkService.analyse(partialDocuments: partialDocumentsInfoSorted, metadata: metadata, completion: completion)
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
}
