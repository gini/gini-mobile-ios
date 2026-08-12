//
//  DocumentServiceMock.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import GiniCaptureSDK
import GiniBankAPILibrary
@testable import GiniBankSDK

/**
 A mock that conforms to `DocumentServiceProtocol` and captures the arguments
 passed to `sendFeedback(with:updatedCompoundExtractions:)`.
 */
final class DocumentServiceMock: DocumentServiceProtocol {

    // MARK: - Captured values

    private(set) var capturedFlatExtractions: [Extraction]?
    private(set) var capturedCompoundExtractions: [String: [[Extraction]]]?
    private(set) var sendFeedbackCallCount = 0

    // MARK: - DocumentServiceProtocol stubs

    var document: Document?
    var metadata: Document.Metadata?
    var analysisCancellationToken: CancellationToken?

    func sendFeedback(with updatedExtractions: [Extraction],
                      updatedCompoundExtractions: [String: [[Extraction]]]?) {
        sendFeedbackCallCount += 1
        capturedFlatExtractions = updatedExtractions
        capturedCompoundExtractions = updatedCompoundExtractions
    }

    func cancelAnalysis() {
        // This method will remain empty; no implementation is needed.
    }

    func remove(document: GiniCaptureDocument) {
        // This method will remain empty; no implementation is needed.
    }

    func resetToInitialState() {
        // This method will remain empty; no implementation is needed.
    }

    func startAnalysis(completion: @escaping AnalysisCompletion) {
        // This method will remain empty; no implementation is needed.
    }

    func sortDocuments(withSameOrderAs documents: [GiniCaptureDocument]) {
        // This method will remain empty; no implementation is needed.
    }

    func upload(document: GiniCaptureDocument, completion: UploadDocumentCompletion?) {
        // This method will remain empty; no implementation is needed.
    }

    func update(imageDocument: GiniImageDocument) {
        // This method will remain empty; no implementation is needed.
    }

    func log(errorEvent: ErrorEvent) {
        // This method will remain empty; no implementation is needed.
    }

    func layout(completion: @escaping DocumentLayoutCompletion) {
        // This method will remain empty; no implementation is needed.
    }

    func pages(completion: @escaping DocumentPagsCompletion) {
        // This method will remain empty; no implementation is needed.
    }

    func documentPage(pageNumber: Int,
                      size: Document.Page.Size,
                      completion: @escaping DocumentPagePreviewCompletion) {
        // This method will remain empty; no implementation is needed.
    }
}
