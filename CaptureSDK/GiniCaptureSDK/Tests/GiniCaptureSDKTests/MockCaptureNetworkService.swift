//
//  MockCaptureNetworkService.swift
//  GiniCaptureSDK
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
@testable import GiniCaptureSDK
@testable import GiniBankAPILibrary

/**
 Minimal test double for `GiniCaptureNetworkService`.

 Captures the `metadata` argument passed to `upload()` and `analyse()` so that
 test suites can assert on the headers injected by higher-level services without
 making real network calls.
 */
final class MockCaptureNetworkService: GiniCaptureNetworkService {

    // MARK: - Captured values

    /** The `Document.Metadata` last received by `upload()`. */
    var capturedUploadMetadata: Document.Metadata?

    /** The `Document.Metadata` last received by `analyse()`. */
    var capturedAnalyseMetadata: Document.Metadata?

    // MARK: - Helpers

    /** Clears both captured metadata values, useful between arrange steps of a test. */
    func resetCaptures() {
        capturedUploadMetadata = nil
        capturedAnalyseMetadata = nil
    }

    // MARK: - GiniCaptureNetworkService

    func upload(document: GiniCaptureDocument,
                metadata: Document.Metadata?,
                completion: @escaping UploadDocumentCompletion) {
        capturedUploadMetadata = metadata
        // Return a stub document so DocumentService can record it in partialDocuments.
        let url = URL(string: "https://pay-api.gini.net/documents/stub-id")!
        let links = Document.Links(giniAPIDocumentURL: url)
        let stubDoc = Document(creationDate: Date(),
                               id: "stub-id",
                               name: "Partial-stub",
                               links: links,
                               sourceClassification: .scanned)
        completion(.success(stubDoc))
    }

    func analyse(partialDocuments: [PartialDocumentInfo],
                 metadata: Document.Metadata?,
                 cancellationToken: CancellationToken,
                 completion: @escaping (Result<(document: Document, extractionResult: ExtractionResult), GiniError>) -> Void) {
        capturedAnalyseMetadata = metadata
        // Never calls completion — tests only inspect metadata.
    }

    func delete(document: Document, completion: @escaping (Result<String, GiniError>) -> Void) {
        // This method will remain empty; no implementation is needed.
    }

    func cleanup() {
        // This method will remain empty; no implementation is needed.
    }
    func sendFeedback(document: Document,
                      updatedExtractions: [Extraction],
                      updatedCompoundExtractions: [String: [[Extraction]]]?,
                      completion: @escaping (Result<Void, GiniError>) -> Void) {
        // This method will remain empty; no implementation is needed.
    }
    func sendFeedback(documentId: String,
                      updatedExtractions: [Extraction],
                      updatedCompoundExtractions: [String: [[Extraction]]]?,
                      completion: @escaping (Result<Void, GiniError>) -> Void) {}
    func log(errorEvent: ErrorEvent, completion: @escaping (Result<Void, GiniError>) -> Void) {
        // This method will remain empty; no implementation is needed.
    }
}
