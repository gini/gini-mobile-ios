//
//  DocumentServiceProtocol.swift
//  GiniCapture
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import GiniBankAPILibrary

public typealias UploadDocumentCompletion = (Result<Document, GiniError>) -> Void
public typealias AnalysisCompletion = (Result<ExtractionResult, GiniError>) -> Void
public typealias DocumentLayoutCompletion = (Result<Document.Layout, GiniError>) -> Void
public typealias DocumentPagePreviewCompletion = (Result<Data, GiniError>) -> Void
public typealias DocumentPagsCompletion = (Result<[Document.Page], GiniError>) -> Void

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

    func layout(completion: @escaping DocumentLayoutCompletion)
    func pages(completion: @escaping DocumentPagsCompletion)
    func documentPage(pageNumber: Int,
                      size: Document.Page.Size,
                      completion: @escaping DocumentPagePreviewCompletion)
}
