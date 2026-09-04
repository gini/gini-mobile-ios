//
//  DocumentAnalysisHelper.swift
//  Example Swift
//
//  Created by Nadya Karaban on 28.02.21.
//

import GiniCaptureSDK
import GiniBankAPILibrary

typealias UploadDocumentCompletion = (Result<Document, GiniError>) -> Void
typealias AnalysisCompletion = (Result<ExtractionResult, GiniError>) -> Void

protocol DocumentAnalysisHelper: AnyObject {

    var analysisCancellationToken: CancellationToken? { get set }
    var pay5Parameters: [String] { get }

    func cancelAnalysis()
    func remove(document: GiniCaptureDocument)
    func resetToInitialState()
    func sendFeedback(with: [Extraction])
    func startAnalysis(completion: @escaping AnalysisCompletion)
    func sortDocuments(withSameOrderAs documents: [GiniCaptureDocument])
    func upload(document: GiniCaptureDocument,
                completion: UploadDocumentCompletion?)
    func update(imageDocument: GiniImageDocument)
}

extension DocumentAnalysisHelper {
    func handleResults(completion: @escaping AnalysisCompletion) -> (CompletionResult<ExtractionResult>){
        return { result in
            switch result {
            case .success(let extractionResult):
                print("✅ Finished analysis process with no errors")
                completion(.success(extractionResult))

            case .failure(let error):
                self.handleAnalysisError(error)
            }
        }
    }

    private func handleAnalysisError(_ error: GiniError) {
           switch error {
           case .requestCancelled:
               print("❌ Cancelled analysis process")
           default:
               print("❌ Finished analysis process with error: \(error)")
           }
       }
}
