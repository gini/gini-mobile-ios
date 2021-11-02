//
//  ComponentAPIDocumentsService.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 2/14/18.
//

import GiniBankAPILibrary
import GiniCaptureSDK
import UIKit

final class ComponentAPIDocumentsService: ComponentAPIDocumentServiceProtocol {
    var partialDocuments: [String: PartialDocument] = [:]
    var document: Document?
    var analysisCancellationToken: CancellationToken?
    var metadata: Document.Metadata?
    var documentService: DefaultDocumentService

    init(lib: GiniBankAPI, documentMetadata: Document.Metadata?) {
        metadata = documentMetadata
        documentService = lib.documentService()
    }

    func startAnalysis(completion: @escaping ComponentAPIAnalysisCompletion) {
        let partialDocumentsInfoSorted = partialDocuments
            .lazy
            .map { $0.value }
            .sorted()
            .map { $0.info }

        fetchExtractions(for: partialDocumentsInfoSorted, completion: completion)
    }

    func cancelAnalysis() {
        if let compositeDocument = document {
            delete(compositeDocument)
        }

        analysisCancellationToken?.cancel()
        analysisCancellationToken = nil
        document = nil
    }

    func remove(document: GiniCaptureDocument) {
        if let index = partialDocuments.index(forKey: document.id) {
            if let document = partialDocuments[document.id]?
                .document {
                delete(document)
            }
            partialDocuments.remove(at: index)
        }
    }

    func resetToInitialState() {
        partialDocuments.removeAll()
        analysisCancellationToken = nil
        document = nil
    }

    func update(imageDocument: GiniImageDocument) {
        partialDocuments[imageDocument.id]?.info.rotationDelta = imageDocument.rotationDelta
    }

    func sendFeedback(with updatedExtractions: [Extraction]) {
        guard let document = document else { return }
        documentService.submitFeedback(for: document, with: updatedExtractions) { result in
            switch result {
            case .success:
                print("🚀 Feedback sent with \(updatedExtractions.count) extractions")
            case let .failure(error):
                print("❌ Error sending feedback for document with id: \(document.id) error: \(error)")
            }
        }
    }

    func sortDocuments(withSameOrderAs documents: [GiniCaptureDocument]) {
        for index in 0 ..< documents.count {
            let id = documents[index].id
            partialDocuments[id]?.order = index
        }
    }

    func upload(document: GiniCaptureDocument,
                completion: ComponentAPIUploadDocumentCompletion?) {
        partialDocuments[document.id] =
            PartialDocument(info: PartialDocumentInfo(document: nil, rotationDelta: 0),
                            document: nil,
                            order: partialDocuments.count)
        let fileName = "Partial-\(NSDate().timeIntervalSince1970)"

        createDocument(from: document, fileName: fileName) { result in
            switch result {
            case let .success(createdDocument):
                self.partialDocuments[document.id]?.document = createdDocument
                self.partialDocuments[document.id]?.info.document = createdDocument.links.document

                completion?(.success(createdDocument))
            case let .failure(error):
                completion?(.failure(error))
            }
        }
    }
}

// MARK: - File private methods

extension ComponentAPIDocumentsService {
    fileprivate func createDocument(from document: GiniCaptureDocument,
                                    fileName: String,
                                    docType: Document.DocType? = nil,
                                    completion: @escaping ComponentAPIUploadDocumentCompletion) {
        print("📝 Creating document...")

        documentService.createDocument(fileName: fileName,
                                       docType: docType,
                                       type: .partial(document.data),
                                       metadata: metadata) { result in
            switch result {
            case let .success(createdDocument):
                print("📄 Created document with id: \(createdDocument.id) " +
                    "for vision document \(document.id)")
                completion(.success(createdDocument))
            case let .failure(error):
                print("❌ Document creation failed: \(error)")

                completion(.failure(error))
            }
        }
    }

    func delete(_ document: Document) {
        documentService.delete(document) { result in
            switch result {
            case .success:
                print("🗑 Deleted \(document.sourceClassification.rawValue) document with id: \(document.id)")
            case let .failure(error):
                print("❌ Error deleting \(document.sourceClassification.rawValue) document with id \(document.id):" +
                    " \(error)")
            }
        }
    }

    fileprivate func fetchExtractions(for documents: [PartialDocumentInfo],
                                      completion: @escaping ComponentAPIAnalysisCompletion) {
        print(" 📑 Creating composite document...")
        let fileName = "Composite-\(NSDate().timeIntervalSince1970)"

        documentService
            .createDocument(fileName: fileName,
                            docType: nil,
                            type: .composite(CompositeDocumentInfo(partialDocuments: documents)),
                            metadata: metadata) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .success(createdDocument):
                    print("🔎 Starting analysis for composite document with id \(createdDocument.id)")

                    self.analysisCancellationToken = CancellationToken()
                    self.documentService
                        .extractions(for: createdDocument,
                                     cancellationToken: self.analysisCancellationToken!,
                                     completion: self.handleResults(completion: completion))
                case let .failure(error):
                    print("❌ Composite document creation failed: \(error)")
                    completion(.failure(error))
                }
            }
    }

    func handleResults(completion: @escaping ComponentAPIAnalysisCompletion) -> (CompletionResult<ExtractionResult>) {
        return { result in
            switch result {
            case let .success(extractionResult):
                print("✅ Finished analysis process with no errors")
                completion(.success(extractionResult.extractions))
            case let .failure(error):
                switch error {
                case .requestCancelled:
                    print("❌ Cancelled analysis process")
                default:
                    print("❌ Finished analysis process with error: \(error)")
                    completion(.failure(error))
                }
            }
        }
    }
}
