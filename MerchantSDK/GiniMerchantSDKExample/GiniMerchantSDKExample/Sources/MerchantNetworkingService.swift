//
//  MerchantNetworkingService.swift
//
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import GiniBankAPILibrary
import GiniCaptureSDK
import GiniMerchantSDK

class MerchantNetworkingService: GiniCaptureNetworkService {
    typealias GiniBankAPIAnalysisCompletion = (Result<(document: GiniBankAPILibrary.Document, extractionResult: GiniBankAPILibrary.ExtractionResult), GiniBankAPILibrary.GiniError>) -> Void
    
    private func mapDocumentToGiniHealthAPI(doc: GiniBankAPILibrary.Document) -> GiniMerchantSDK.Document {
        let links = GiniMerchantSDK.Document.Links.init(giniAPIDocumentURL: doc.links.document)
        let sourceClassification = GiniMerchantSDK.Document.SourceClassification(rawValue: doc.sourceClassification.rawValue) ?? .scanned
        
        return GiniMerchantSDK.Document(creationDate: doc.creationDate,
                                        id: doc.id,
                                        name: doc.name,
                                        links: links,
                                        sourceClassification: sourceClassification,
                                        expirationDate: nil)
    }
    
    private func mapDocumentToGiniBankAPI(doc: GiniMerchantSDK.Document) -> GiniBankAPILibrary.Document {
        let links = GiniBankAPILibrary.Document.Links.init(giniAPIDocumentURL: doc.links.document)
        let sourceClassification = GiniBankAPILibrary.Document.SourceClassification(rawValue: doc.sourceClassification.rawValue) ?? .scanned
        return GiniBankAPILibrary.Document(creationDate: doc.creationDate,
                                           id: doc.id,
                                           name: doc.name,
                                           links: links,
                                           sourceClassification: sourceClassification)
    }
    
    private func mapPartialDocumentsInfoToGiniHealthAPI(partialDocuments: [GiniBankAPILibrary.PartialDocumentInfo]) -> [GiniMerchantSDK.PartialDocumentInfo] {
        var healthPartialDocuments: [GiniMerchantSDK.PartialDocumentInfo] = []
        for doc in partialDocuments {
            healthPartialDocuments.append(GiniMerchantSDK.PartialDocumentInfo(document: doc.document))
        }
        return healthPartialDocuments
    }
    
    private func mapExtractionsToGiniBankAPI(extractions: [GiniMerchantSDK.Extraction]) -> [GiniBankAPILibrary.Extraction] {
        var bankExtractions: [GiniBankAPILibrary.Extraction] = []
        for extraction in extractions {
            bankExtractions.append(GiniBankAPILibrary.Extraction(box: nil,
                                                                 candidates: extraction.candidates,
                                                                 entity: extraction.entity,
                                                                 value: extraction.value,
                                                                 name: extraction.name))
        }
        return bankExtractions
    }
    
    private func mapExtractionResultToGiniBankAPI(result: GiniMerchantSDK.ExtractionResult) -> GiniBankAPILibrary.ExtractionResult {
        let extractions = mapExtractionsToGiniBankAPI(extractions: result.extractions)
        let lineItems = [extractions]
        let candidates = ["" : [GiniBankAPILibrary.Extraction.Candidate.init(box: nil, entity: "", value: "")]]
        return GiniBankAPILibrary.ExtractionResult(extractions: extractions,
                                                   lineItems: lineItems,
                                                   returnReasons: nil,
                                                   candidates: candidates)
    }
    
    private var documentService: GiniMerchantSDK.DefaultDocumentService
    
    public init(documentService: GiniMerchantSDK.DefaultDocumentService) {
        self.documentService = documentService
    }
    
    func delete(document: GiniBankAPILibrary.Document, completion: @escaping (Result<String, GiniBankAPILibrary.GiniError>) -> Void) {
        documentService.delete(mapDocumentToGiniHealthAPI(doc: document)) { result in
            switch result {
            case .success(let result):
                completion(.success(result))
            case .failure(let error):
                completion(.failure(.unknown(response: error.response, data: error.data)))
            }
        }
    }
    
    func cleanup() {
        // This method will remain empty; no implementation is needed.
    }

    func analyse(partialDocuments: [GiniBankAPILibrary.PartialDocumentInfo],
                 metadata: GiniBankAPILibrary.Document.Metadata?,
                 cancellationToken: GiniBankAPILibrary.CancellationToken,
                 completion: @escaping GiniBankAPIAnalysisCompletion) {

        let fileName = "Composite-\(NSDate().timeIntervalSince1970)"
        let partialDocs = mapPartialDocumentsInfoToGiniHealthAPI(partialDocuments: partialDocuments)

        documentService.createDocument(fileName: fileName,
                                       docType: nil,
                                       type: .composite(CompositeDocumentInfo(partialDocuments: partialDocs)),
                                       metadata: nil) { [weak self] result in
            guard let self = self else { return }
            switch result {
                case let .success(createdDocument):
                    self.fetchExtractionsAndComplete(for: createdDocument, completion: completion)
                case let .failure(error):
                    completion(.failure(.unknown(response: error.response, data: error.data)))
            }
        }
    }

    private func fetchExtractionsAndComplete(for document: GiniMerchantSDK.Document,
                                             completion: @escaping GiniBankAPIAnalysisCompletion) {
        documentService.extractions(for: document,
                                    cancellationToken: GiniMerchantSDK.CancellationToken()) { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success(let extractionResult):
                    self.handleExtractionSuccess(document: document,
                                                 extractionResult: extractionResult,
                                                 completion: completion)
                case .failure(let error):
                    completion(.failure(.unknown(response: error.response, data: error.data)))
            }
        }
    }

    private func handleExtractionSuccess(document: GiniMerchantSDK.Document,
                                         extractionResult: GiniMerchantSDK.ExtractionResult,
                                         completion: @escaping GiniBankAPIAnalysisCompletion) {
        let mappedDocument = mapDocumentToGiniBankAPI(doc: document)
        let mappedResult = mapExtractionResultToGiniBankAPI(result: extractionResult)

        completion(.success((mappedDocument, mappedResult)))
    }

    func upload(document: GiniCaptureSDK.GiniCaptureDocument,
                metadata: GiniBankAPILibrary.Document.Metadata?,
                completion: @escaping GiniCaptureSDK.UploadDocumentCompletion) {
        let fileName = "Partial-\(NSDate().timeIntervalSince1970)"
        
        documentService.createDocument(fileName: fileName,
                                       docType: nil,
                                       type: .partial(document.data),
                                       metadata: nil) { result in
            switch result {
            case let .success(createdDocument):
                completion(.success(self.mapDocumentToGiniBankAPI(doc: createdDocument)))
            case let .failure(error):
                completion(.failure(.unknown(response: error.response, data: error.data)))
            }
        }
    }
    
    func log(errorEvent: ErrorEvent,
             completion: @escaping (Result<Void, GiniBankAPILibrary.GiniError>) -> Void) {
        // This method will remain empty; no implementation is needed.
    }
    
    func sendFeedback(document: GiniBankAPILibrary.Document,
                      updatedExtractions: [GiniBankAPILibrary.Extraction],
                      updatedCompoundExtractions: [String : [[GiniBankAPILibrary.Extraction]]]?,
                      completion: @escaping (Result<Void, GiniBankAPILibrary.GiniError>) -> Void) {
        // This method will remain empty; no implementation is needed.
    }
}
