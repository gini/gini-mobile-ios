//
//  DocumentService.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 2/14/18.
//

import UIKit
import GiniBankAPILibrary
import GiniUtilites
/**
 Static variable for synchronization to prevent the display of multiple error screens at the same time.
*/

var errorOccurred = false

public var originalDocumentName: String?

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
        let documentMetadata: Document.Metadata? = {
            guard let uploadMetadata = document.uploadMetadata else {
                return metadata
            }
            guard var metadata else {
                return Document.Metadata(uploadMetadata: uploadMetadata)
            }
            metadata.addUploadMetadata(uploadMetadata)
            return metadata
        }()

        captureNetworkService.upload(document: document, metadata: documentMetadata) { result in
            switch result {
            case .success(let createdDocument):
                self.updatePartialDocuments(for: document, with: createdDocument)
                completion?(.success(createdDocument))
            case .failure(let error):
                DispatchQueue.main.async {
                    guard !errorOccurred else { return }
                    errorOccurred = true
                    DispatchQueue.global().async {
                        completion?(.failure(error))
                    }
                }
            }
        }
    }

    private func updatePartialDocuments(for document: GiniCaptureDocument, with createdDocument: Document) {
        // Scanning a QR code takes priority, even if the user has already taken some pictures.
        // All the pages that have already been scanned should be discarded and keep the document generated after scanning the QR code.
        // The composite document should be created just with the document generated after scanning the QR cod
        if document.type == .qrcode && partialDocuments.isNotEmpty {
            partialDocuments.removeAll()
        }
        let partialDocumentInfo = PartialDocumentInfo(document: createdDocument.links.document, rotationDelta: 0)
        partialDocuments[document.id] = PartialDocument(info: partialDocumentInfo,
                                                        document: createdDocument,
                                                        order: partialDocuments.count)
    }

    public func startAnalysis(completion: @escaping AnalysisCompletion) {
        let partialDocumentsInfoSorted = partialDocuments
            .lazy
            .map { $0.value }
            .sorted()
            .map { $0.info }
        self.analysisCancellationToken = CancellationToken()
        captureNetworkService.analyse(partialDocuments: partialDocumentsInfoSorted,
                                      metadata: metadata,
                                      cancellationToken: analysisCancellationToken!) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success((createdDocument, extractionResult)):
                self.document = createdDocument
                completion(.success(extractionResult))
            case let .failure(error):
                DispatchQueue.main.async {
                    guard !errorOccurred else { return }
                    errorOccurred = true
                    DispatchQueue.global().async {
                        completion(.failure(error))
                    }
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
        // Cleanup the local cached PDF file name
        originalDocumentName = nil
    }
    
    public func update(imageDocument: GiniImageDocument) {
        partialDocuments[imageDocument.id]?.info.rotationDelta = imageDocument.rotationDelta
    }
    
    public func sendFeedback(with updatedExtractions: [Extraction], updatedCompoundExtractions: [String: [[Extraction]]]?) {
        Log(message: "Sending feedback", event: "💬")
        guard let documentId = document?.id else {
            Log("Cannot send feedback: no document", event: .error)
            return
        }
        attemptFeedback(documentId: documentId,
                        updatedExtractions: updatedExtractions,
                        updatedCompoundExtractions: updatedCompoundExtractions,
                        retryCount: 0)
    }
    
    public func sendSkontoFeedback(with updatedExtractions: [Extraction],
                                   updatedCompoundExtractions: [String: [[Extraction]]]?,
                                   retryCount: Int) {
        Log(message: "Sending feedback", event: "💬")
        guard let documentId = document?.id else {
            Log("Cannot send feedback: no document", event: .error)
            return
        }
        attemptFeedback(documentId: documentId,
                        updatedExtractions: updatedExtractions,
                        updatedCompoundExtractions: updatedCompoundExtractions,
                        retryCount: retryCount)
    }

    private func attemptFeedback(documentId: String,
                                 updatedExtractions: [Extraction],
                                 updatedCompoundExtractions: [String: [[Extraction]]]?,
                                 retryCount: Int) {
        captureNetworkService.sendFeedback(documentId: documentId,
                                           updatedExtractions: updatedExtractions,
                                           updatedCompoundExtractions: updatedCompoundExtractions) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                Log(message: "Feedback sent with \(updatedExtractions.count) extractions and \(updatedCompoundExtractions?.count ?? 0) compound extractions",
                    event: "🚀")
            case .failure(let error):
                self.handleFeedbackFailure(documentId: documentId,
                                           updatedExtractions: updatedExtractions,
                                           updatedCompoundExtractions: updatedCompoundExtractions,
                                           error: error,
                                           retryCount: retryCount)
            }
        }
    }

    private func handleFeedbackFailure(documentId: String,
                                       updatedExtractions: [Extraction],
                                       updatedCompoundExtractions: [String: [[Extraction]]]?,
                                       error: Error,
                                       retryCount: Int) {
        if retryCount > 0 {
            Log("Retrying feedback due to error: \(error). Remaining retries: \(retryCount - 1)", event: .warning)
            DispatchQueue.global().asyncAfter(deadline: .now() + 5) { [weak self] in
                self?.attemptFeedback(documentId: documentId,
                                      updatedExtractions: updatedExtractions,
                                      updatedCompoundExtractions: updatedCompoundExtractions,
                                      retryCount: retryCount - 1)
            }
        } else {
            handleFeedbackError(documentId: documentId, error: error)
        }
    }

    private func handleFeedbackError(documentId: String, error: Error) {
        let message = "Error sending feedback for document with id: \(documentId) error: \(error)"
        Log(message, event: .error)
        let errorLog = ErrorLog(description: message, error: error)
        GiniConfiguration.shared.errorLogger.handleErrorLog(error: errorLog)
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
                Log("Error event sent to Gini", event: .success)
                break
            case .failure(let error):
                Log("Failed to send error event to Gini: \(error)", event: .error)
                break
            }
        }
    }

    public func layout(completion: @escaping DocumentLayoutCompletion) {
        guard let document = document else {
            Log("Cannot get document layout: no document", event: .error)
            return
        }
        captureNetworkService.layout(for: document) { result in
            switch result {
                case .success(let documentLayout):
                    completion(.success(documentLayout))
                case .failure(let error):
                    let message = "Failed to get layout for document with id: \(document.id) error: \(error)"
                    Log(message, event: .error)
                    completion(.failure(error))
            }
        }
    }

    public func pages(completion: @escaping DocumentPagsCompletion) {
        guard let document = document else {
            Log("Cannot get document pages", event: .error)
            return
        }
        captureNetworkService.pages(for: document) { result in
            switch result {
                case let .success(pages):
                    completion(.success(pages))
                case let .failure(error):
                    let message = "Failed to get pages for document with id: \(document.id) error: \(error)"
                    Log(message, event: .error)
                    completion(.failure(error))
            }
        }
    }

    public func documentPage(pageNumber: Int,
                             size: Document.Page.Size,
                             completion: @escaping DocumentPagePreviewCompletion){
        guard let document = document else {
            Log("Cannot get document page", event: .error)
            return
        }
        captureNetworkService.documentPage(for: document,
                                           pageNumber: pageNumber,
                                           size: size) { result in
            switch result {
            case .success(let pageData):
                completion(.success(pageData))
            case .failure(let error):
                let message = "Failed to get page for document with id: \(document.id) error: \(error)"
                Log(message, event: .error)
                completion(.failure(error))
            }
        }
    }
}
