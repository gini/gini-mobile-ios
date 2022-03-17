//
//  ComponentAPIDocumentsService.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 2/14/18.
//

import UIKit
import GiniCaptureSDK
import GiniHealthAPILibrary
import GiniHealthSDK

final class ComponentAPIDocumentsService: ComponentAPIDocumentServiceProtocol {
    
    var partialDocuments: [String: PartialDocument] = [:]
    var document: Document?
    var analysisCancellationToken: CancellationToken?
    var metadata: Document.Metadata?
    var documentService: DefaultDocumentService
    var apiLib: GiniHealthAPI
    var healthSDK: GiniHealth
    
    lazy var configuration: GiniHealthConfiguration = {
        let configuration = GiniHealthConfiguration()
        // Font configuration
        let regularFont = UIFont(name: "Avenir", size: 15) ?? UIFont.systemFont(ofSize: 15)
        let boldFont = UIFont(name: "Avenir Heavy", size: 14) ?? UIFont.systemFont(ofSize: 15)
        configuration.customFont = GiniFont(regular: regularFont, bold: boldFont, light: regularFont, thin: regularFont)
        // Pay button configuration
        configuration.payButtonTitleFont = boldFont
        configuration.payButtonDisabledTextColor = GiniColor(lightModeColor: .white, darkModeColor: .white)
        
        // Page indicator color configuration
        configuration.currentPageIndicatorTintColor = GiniColor(lightModeColor: .systemBlue, darkModeColor: .systemBlue)
        configuration.pageIndicatorTintColor = GiniColor(lightModeColor: .darkGray, darkModeColor: .darkGray)
        return configuration
    }()
    
    init(lib: GiniHealthAPI, documentMetadata: Document.Metadata?) {
        self.metadata = documentMetadata
        self.apiLib = lib
        self.healthSDK = GiniHealth(with: lib)
        self.documentService = healthSDK.documentService
    }
    
    func startAnalysis(completion: @escaping ComponentAPIAnalysisBusinessSDKCompletion) {
        let partialDocumentsInfoSorted = partialDocuments
            .lazy
            .map { $0.value }
            .sorted()
            .map { $0.info }
        self.fetchExtractions(for: partialDocumentsInfoSorted, completion: completion)
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
            case .failure(let error):
                print("❌ Error sending feedback for document with id: \(document.id) error: \(error)")
            }
        }
    }
    
    func sortDocuments(withSameOrderAs documents: [GiniCaptureDocument]) {
        for index in 0..<documents.count {
            let id = documents[index].id
            partialDocuments[id]?.order = index
        }
    }
    
    func upload(document: GiniCaptureDocument,
                completion: ComponentAPIUploadDocumentCompletion?) {
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
                                        case .success(let createdDocument):
                                            print("📄 Created document with id: \(createdDocument.id) " +
                                                "for vision document \(document.id)")
                                            completion(.success(createdDocument))
                                        case .failure(let error):
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
            case .failure(let error):
                print("❌ Error deleting \(document.sourceClassification.rawValue) document with id \(document.id):" +
                    " \(error)")
            }
        }
    }
    
    fileprivate func fetchExtractions(for documents: [PartialDocumentInfo],
                                      completion: @escaping ComponentAPIAnalysisBusinessSDKCompletion) {
        print(" 📑 Creating composite document...")
        let fileName = "Composite-\(NSDate().timeIntervalSince1970)"

        documentService
            .createDocument(fileName: fileName,
                            docType: nil,
                            type: .composite(CompositeDocumentInfo(partialDocuments: documents)),
                            metadata: metadata) { [weak self] result in
                                guard let self = self else { return }
                                switch result {
                                case .success(let createdDocument):
                                    print("🔎 Starting analysis for composite document with id \(createdDocument.id)")
// MARK: GiniHealth SDK

// Call from Business SDK getExtractions for document ID
                                    self.getDataForReviewScreen(for: createdDocument, completion:completion)
                                case .failure(let error):
                                    print("❌ Composite document creation failed: \(error)")
                                    completion(nil, .failure(.apiError(error)))
                                }
        }

    }

    
    
    fileprivate func getDataForReviewScreen(for document: Document, completion: @escaping ComponentAPIAnalysisBusinessSDKCompletion){
        self.healthSDK.setConfiguration(configuration)
        self.healthSDK.setDocumentForReview(documentId: document.id) { result in
            switch result {
            case .success(let extractions):
                print("✅ Finished analysis process with no errors")
                completion(document, .success(extractions))
            case .failure(let error):
                completion(document, .failure(error))
            }
        }
    }
}
