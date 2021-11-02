//
//  ComponentAPIDocumentServiceProtocol.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 3/29/18.
//

import Foundation
import GiniCaptureSDK
import GiniBankAPILibrary

enum CustomAnalysisError: GiniCaptureError {
    case analysisFailed
    var message: String {
        switch self {
        case .analysisFailed:
            return NSLocalizedString("analysisFailedErrorMessage", comment: "analysis failed error message")
        }
    }
}

typealias ComponentAPIUploadDocumentCompletion = (Result<Document, GiniError>) -> Void
typealias ComponentAPIAnalysisCompletion = (Result<[Extraction], GiniError>) -> Void

protocol ComponentAPIDocumentServiceProtocol: AnyObject {
    
    var document: Document? { get set }
    var analysisCancellationToken: CancellationToken? { get set }
    
    func cancelAnalysis()
    func remove(document: GiniCaptureDocument)
    func resetToInitialState()
    func sendFeedback(with updatedExtractions: [Extraction])
    func startAnalysis(completion: @escaping ComponentAPIAnalysisCompletion)
    func sortDocuments(withSameOrderAs documents: [GiniCaptureDocument])
    func upload(document: GiniCaptureDocument,
                completion: ComponentAPIUploadDocumentCompletion?)
    func update(imageDocument: GiniImageDocument)
}
