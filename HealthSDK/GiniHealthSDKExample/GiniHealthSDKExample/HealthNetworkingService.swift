//
//  HealthNetworkingService.swift
//  GiniHealthSDKExample
//
//  Created by Nadya Karaban on 23.05.23.
//

import Foundation
import GiniHealthAPILibrary
import GiniBankAPILibrary
import GiniCaptureSDK

class HealthNetworkingService: GiniCaptureNetworkService {
    
    private func mapDocumentToGiniHealthAPI(doc: GiniBankAPILibrary.Document) -> GiniHealthAPILibrary.Document {
        let links = GiniHealthAPILibrary.Document.Links.init(giniAPIDocumentURL: doc.links.document)

        return GiniHealthAPILibrary.Document(creationDate: doc.creationDate, id: doc.id, name: doc.id, links: links, sourceClassification: GiniHealthAPILibrary.Document.SourceClassification(rawValue:  doc.sourceClassification.rawValue) ?? .scanned )
    }
    
    private func mapDocumentToGiniBankAPI(doc: GiniHealthAPILibrary.Document) -> GiniBankAPILibrary.Document {
        let links = GiniBankAPILibrary.Document.Links.init(giniAPIDocumentURL: doc.links.document)

        return GiniBankAPILibrary.Document(creationDate: doc.creationDate, id: doc.id, name: doc.name, links: links, sourceClassification: GiniBankAPILibrary.Document.SourceClassification(rawValue: doc.sourceClassification.rawValue) ?? .scanned)
    }
    
    private func mapPartialDocumentsInfoToGiniHealthAPI(partialDocuments: [GiniBankAPILibrary.PartialDocumentInfo]) -> [GiniHealthAPILibrary.PartialDocumentInfo] {
        var healthPartialDocuments: [GiniHealthAPILibrary.PartialDocumentInfo] = []
        for doc in partialDocuments{
            healthPartialDocuments.append(GiniHealthAPILibrary.PartialDocumentInfo(document: doc.document))
        }
        return healthPartialDocuments
    }
    
    private func mapCancelationTokenToGiniHealthAPI(token: GiniBankAPILibrary.CancellationToken) -> GiniHealthAPILibrary.CancellationToken {
        return GiniHealthAPILibrary.CancellationToken()
    }
    
    private func mapExtractionToGiniHealthAPI(extraction: GiniBankAPILibrary.Extraction) -> GiniHealthAPILibrary.Extraction {
        return GiniHealthAPILibrary.Extraction(box: nil, candidates: extraction.candidates, entity: extraction.entity, value: extraction.value, name: extraction.name)
    }
    
    private func mapExtractionsToGiniHealthAPI(extractions: [GiniBankAPILibrary.Extraction]) -> [GiniHealthAPILibrary.Extraction] {
        var healthExtractions: [GiniHealthAPILibrary.Extraction] = []
        for extraction in extractions {
            healthExtractions.append(GiniHealthAPILibrary.Extraction(box: nil, candidates: extraction.candidates, entity: extraction.entity, value: extraction.value, name: extraction.name))
        }
        return healthExtractions
    }
    
    private func mapExtractionsToGiniBankAPI(extractions: [GiniHealthAPILibrary.Extraction]) -> [GiniBankAPILibrary.Extraction] {
        var bankExtractions: [GiniBankAPILibrary.Extraction] = []
        for extraction in extractions {
            bankExtractions.append(GiniBankAPILibrary.Extraction(box: nil, candidates: extraction.candidates, entity: extraction.entity, value: extraction.value, name: extraction.name))
        }
        return bankExtractions
    }
    
    private func mapExtractionResultToGiniHealthAPI(result: GiniBankAPILibrary.ExtractionResult) -> GiniHealthAPILibrary.ExtractionResult {
        return GiniHealthAPILibrary.ExtractionResult(extractions: mapExtractionsToGiniHealthAPI(extractions: result.extractions), payment: [mapExtractionsToGiniHealthAPI(extractions: result.extractions)], lineItems: [mapExtractionsToGiniHealthAPI(extractions: result.extractions)])
    }
    
    private func mapExtractionResultToGiniBankAPI(result: GiniHealthAPILibrary.ExtractionResult) -> GiniBankAPILibrary.ExtractionResult {
        return GiniBankAPILibrary.ExtractionResult(extractions: mapExtractionsToGiniBankAPI(extractions: result.extractions), lineItems: [mapExtractionsToGiniBankAPI(extractions: result.extractions)], returnReasons: nil, candidates: ["" : [Extraction.Candidate.init(box: nil, entity: "", value: "")]])
    }
    
    private var documentService: GiniHealthAPILibrary.DefaultDocumentService
    
    public init(lib: GiniHealthAPI) {
        self.documentService = lib.documentService()
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
    
    func cleanup() {}
    
    func analyse(partialDocuments: [GiniBankAPILibrary.PartialDocumentInfo],
                 metadata: GiniBankAPILibrary.Document.Metadata?,
                 cancellationToken: GiniBankAPILibrary.CancellationToken,
                 completion: @escaping (Result<(document: GiniBankAPILibrary.Document, extractionResult: GiniBankAPILibrary.ExtractionResult), GiniBankAPILibrary.GiniError>) -> Void) {
        
        let fileName = "Composite-\(NSDate().timeIntervalSince1970)"

        documentService
            .createDocument(fileName: fileName,
                            docType: nil,
                            type: .composite(CompositeDocumentInfo(partialDocuments: mapPartialDocumentsInfoToGiniHealthAPI(partialDocuments: partialDocuments))),
                            metadata: nil) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .success(createdDocument):
                    self.documentService
                        .extractions(for: createdDocument,
                                     cancellationToken: GiniHealthAPILibrary.CancellationToken()) { [weak self] result in
                            guard self != nil else { return }
                            switch result {
                            case let .success(extractionResult):
                                if let doc = self?.mapDocumentToGiniBankAPI(doc: createdDocument),
                                   let result = self?.mapExtractionResultToGiniBankAPI(result: extractionResult){
                                    completion(.success((doc, result)))
                                } else {
                                    completion(.failure(.parseError(message: "")))
                                 }
                            case let .failure(error):
                                switch error {
                                case .requestCancelled: break
                                default: break
                                }
                                completion(.failure(.unknown(response: error.response, data: error.data)))
                            }
                        }
                case let .failure(error):
                    completion(.failure(.unknown(response: error.response, data: error.data)))
                }
            }
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
    }
    
    func sendFeedback(document: GiniBankAPILibrary.Document,
                      updatedExtractions: [GiniBankAPILibrary.Extraction],
                      updatedCompoundExtractions: [String : [[GiniBankAPILibrary.Extraction]]]?,
                      completion: @escaping (Result<Void, GiniBankAPILibrary.GiniError>) -> Void) {
    }
}
