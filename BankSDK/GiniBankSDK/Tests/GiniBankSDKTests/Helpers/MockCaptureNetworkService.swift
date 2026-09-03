//
//  MockCaptureNetworkService.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
@testable import GiniBankAPILibrary
@testable import GiniCaptureSDK

/**
 Minimal `GiniCaptureNetworkService` stub for BankSDK tests that need to
 instantiate `GiniBankNetworkingScreenApiCoordinator` via the public init
 without hitting the network.
 */
final class MockCaptureNetworkService: GiniCaptureNetworkService {

    func upload(document: GiniCaptureDocument,
                metadata: Document.Metadata?,
                completion: @escaping UploadDocumentCompletion) {
        // This method will remain empty; no implementation is needed.
    }

    func analyse(partialDocuments: [PartialDocumentInfo],
                 metadata: Document.Metadata?,
                 cancellationToken: CancellationToken,
                 completion: @escaping (Result<(document: Document, extractionResult: ExtractionResult), GiniError>) -> Void) {
        // This method will remain empty; no implementation is needed.
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
                      completion: @escaping (Result<Void, GiniError>) -> Void) {
        // This method will remain empty; no implementation is needed.
    }

    func log(errorEvent: ErrorEvent, completion: @escaping (Result<Void, GiniError>) -> Void) {
        // This method will remain empty; no implementation is needed.
    }
}
