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
    func sendFeedback(with updatedExtractions: [Extraction], updatedCompoundExtractions: [String: [[Extraction]]]?)
    func startAnalysis(completion: @escaping AnalysisCompletion)
    func sortDocuments(withSameOrderAs documents: [GiniCaptureDocument])
    func upload(document: GiniCaptureDocument,
                completion: UploadDocumentCompletion?)
    func update(imageDocument: GiniImageDocument)
    func log(errorEvent: ErrorEvent)
}
