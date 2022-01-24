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
    
    var captureNetworkService: GiniCaptureNetworkService
    
    public init(lib: GiniBankAPI, metadata: Document.Metadata?) {
        self.metadata = metadata
        self.captureNetworkService = DefaultCaptureNetworkService(lib: lib)
    }
    
    public init(giniCaptureNetworkService: GiniCaptureNetworkService, metadata: Document.Metadata?) {
        self.metadata = metadata
        self.captureNetworkService = giniCaptureNetworkService
    }
    
    public func upload(document: GiniCaptureDocument,
                completion: UploadDocumentCompletion?) {
        self.partialDocuments[document.id] =
            PartialDocument(info: (PartialDocumentInfo(document: nil, rotationDelta: 0)),
                            document: nil,
                            order: self.partialDocuments.count)
        captureNetworkService.upload(document: document, metadata: metadata) { result in
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
        self.analysisCancellationToken = CancellationToken()
        captureNetworkService.analyse(partialDocuments: partialDocumentsInfoSorted, metadata: metadata, cancellationToken: analysisCancellationToken!) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success((createdDocument, extractionResult)):
                self.document = createdDocument
                completion(.success(extractionResult))
            case let .failure(error):
                if error != .requestCancelled {
                    completion(.failure(error))
                }
            }
        }
    }
    
    public func cancelAnalysis() {
        if let compositeDocument = document {
            captureNetworkService.delete(document: compositeDocument) { result in
                switch result {
                case .success, .failure(_) :
                    break
                }
            }
        }
        analysisCancellationToken?.cancel()
        analysisCancellationToken = nil
        document = nil
    }
    
    public func remove(document: GiniCaptureDocument) {
        if let index = partialDocuments.index(forKey: document.id) {
            if let document = partialDocuments[document.id]?
                .document {
                captureNetworkService.delete(document: document) { result in
                    switch result {
                    case .success, .failure(_):
                        break
                    }
                }
            }
            partialDocuments.remove(at: index)
        }
    }
    
    public func resetToInitialState() {
        partialDocuments.removeAll()
        analysisCancellationToken = nil
        document = nil
        captureNetworkService.cleanup()
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
        captureNetworkService.sendFeedback(document: document, updatedExtractions: updatedExtractions) { result in
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
        captureNetworkService.log(errorEvent: errorEvent) { result in
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
