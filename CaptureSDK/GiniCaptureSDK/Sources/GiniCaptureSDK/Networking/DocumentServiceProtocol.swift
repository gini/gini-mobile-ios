//
//  DocumentServiceProtocol.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 3/29/18.
//

import Foundation
import GiniBankAPILibrary

public typealias UploadDocumentCompletion = (Result<Document, GiniError>) -> Void
public typealias AnalysisCompletion = (Result<ExtractionResult, GiniError>) -> Void

public protocol DocumentServiceProtocol: AnyObject {
    
    var document: Document? { get set }
    var metadata: Document.Metadata? { get }
    var analysisCancellationToken: CancellationToken? { get set }
    
    func cancelAnalysis()
    func remove(document: GiniCaptureDocument)
    func resetToInitialState()
    func sendFeedback(with updatedExtractions: [Extraction])
    func startAnalysis(completion: @escaping AnalysisCompletion)
    func sortDocuments(withSameOrderAs documents: [GiniCaptureDocument])
    func upload(document: GiniCaptureDocument,
                completion: UploadDocumentCompletion?)
    func update(imageDocument: GiniImageDocument)
    func log(errorEvent: ErrorEvent)
}

extension DocumentServiceProtocol {
    
    func handleResults(completion: @escaping AnalysisCompletion) -> (CompletionResult<ExtractionResult>) {
        return { result in
            switch result {
            case .success(let extractionResult):
                Log(message: "Finished analysis process with no errors", event: .success)
                completion(.success(extractionResult))
            case .failure(let error):
                switch error {
                case .requestCancelled:
                    Log(message: "Cancelled analysis process", event: .error)
                default:
                    Log(message: "Finished analysis process with error: \(error)", event: .error)
                    completion(.failure(error))
                }
            }
        }
        
    }
}
