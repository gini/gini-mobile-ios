//
//  DocumentServiceProductTagTests.swift
//  GiniCaptureSDK
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import Foundation
@testable import GiniCaptureSDK
@testable import GiniBankAPILibrary

// MARK: - Tests

/**
 Tests that `DocumentService` correctly injects the `X-Document-Metadata-product-tag` header
 into every document submission.

 **Why `.serialized`?**
 Swift Testing runs suite tests concurrently by default. All tests here mutate
 `GiniConfiguration.shared.productTag`, which is a shared singleton. Without serialization,
 two tests running in parallel could overwrite each other's `productTag` value and observe
 the wrong header, causing false failures. `.serialized` forces the tests to execute
 sequentially within this suite, eliminating the race condition.
 */
@Suite("DocumentService — product-tag header injection", .serialized)
struct DocumentServiceProductTagTests {

    // MARK: upload() — single file / file import

    @Test("upload() sends sepaExtractions tag when productTag is .sepaExtractions")
    func uploadSendsSEPATag() {
        
        /// `defer` resets the singleton to its default value after the test body exits,
        /// even if an assertion fails mid-way. This guarantees every subsequent test starts
        /// from a clean, known state regardless of execution order.

        defer { GiniConfiguration.shared.productTag = .sepaExtractions }
        GiniConfiguration.shared.productTag = .sepaExtractions
        let (service, mock) = makeDocumentService()

        service.upload(document: makeImageDocument(), completion: nil)

        #expect(
            mock.capturedUploadMetadata?.headers[productTagHeaderKey] == "sepaExtractions",
            "upload() must set X-Document-Metadata-product-tag to 'sepaExtractions' when productTag is .sepaExtractions"
        )
    }

    @Test("upload() sends cxExtractions tag when productTag is .cxExtractions")
    func uploadSendsCXTag() {
        defer { GiniConfiguration.shared.productTag = .sepaExtractions }
        GiniConfiguration.shared.productTag = .cxExtractions
        let (service, mock) = makeDocumentService()

        service.upload(document: makeImageDocument(), completion: nil)

        #expect(
            mock.capturedUploadMetadata?.headers[productTagHeaderKey] == "cxExtractions",
            "upload() must set X-Document-Metadata-product-tag to 'cxExtractions' when productTag is .cxExtractions"
        )
    }

    @Test("upload() sends autoDetectExtractions tag when productTag is .autoDetectExtractions")
    func uploadSendsAutoDetectTag() {
        defer { GiniConfiguration.shared.productTag = .sepaExtractions }
        GiniConfiguration.shared.productTag = .autoDetectExtractions
        let (service, mock) = makeDocumentService()

        service.upload(document: makeImageDocument(), completion: nil)

        #expect(
            mock.capturedUploadMetadata?.headers[productTagHeaderKey] == "autoDetectExtractions",
            "upload() must set X-Document-Metadata-product-tag to 'autoDetectExtractions' when productTag is .autoDetectExtractions"
        )
    }

    @Test("upload() defaults to sepaExtractions when productTag is nil")
    func uploadDefaultsToSEPAWhenTagIsNil() {
        defer { GiniConfiguration.shared.productTag = .sepaExtractions }
        GiniConfiguration.shared.productTag = nil
        let (service, mock) = makeDocumentService()

        service.upload(document: makeImageDocument(), completion: nil)

        #expect(
            mock.capturedUploadMetadata?.headers[productTagHeaderKey] == "sepaExtractions",
            "upload() must default X-Document-Metadata-product-tag to 'sepaExtractions' when productTag is nil"
        )
    }

    @Test("upload() preserves pre-set metadata headers alongside the product tag")
    func uploadPreservesExistingMetadataHeaders() {
        defer { GiniConfiguration.shared.productTag = .sepaExtractions }
        GiniConfiguration.shared.productTag = .cxExtractions
        let baseMetadata = Document.Metadata(branchId: "my-branch")
        let (service, mock) = makeDocumentService(metadata: baseMetadata)

        service.upload(document: makeImageDocument(), completion: nil)

        let headers = mock.capturedUploadMetadata?.headers ?? [:]
        #expect(
            headers[productTagHeaderKey] == "cxExtractions",
            "upload() must include the product-tag header even when extra base metadata is provided"
        )
        let branchKey = Document.Metadata.headerKeyPrefix + Document.Metadata.branchIdHeaderKey
        #expect(
            headers[branchKey] == "my-branch",
            "upload() must not overwrite pre-existing branchId header when adding the product-tag"
        )
    }

    // MARK: startAnalysis() — composite document POST

    @Test("startAnalysis() sends sepaExtractions tag when productTag is .sepaExtractions")
    func analyseSendsSEPATag() {
        defer { GiniConfiguration.shared.productTag = .sepaExtractions }
        GiniConfiguration.shared.productTag = .sepaExtractions
        let (service, mock) = makeDocumentServiceWithPartialDoc()

        service.startAnalysis { _ in }

        #expect(
            mock.capturedAnalyseMetadata?.headers[productTagHeaderKey] == "sepaExtractions",
            "startAnalysis() must set X-Document-Metadata-product-tag to 'sepaExtractions' on the composite document POST"
        )
    }

    @Test("startAnalysis() sends cxExtractions tag when productTag is .cxExtractions")
    func analyseSendsCXTag() {
        defer { GiniConfiguration.shared.productTag = .sepaExtractions }
        GiniConfiguration.shared.productTag = .cxExtractions
        let (service, mock) = makeDocumentServiceWithPartialDoc()

        service.startAnalysis { _ in }

        #expect(
            mock.capturedAnalyseMetadata?.headers[productTagHeaderKey] == "cxExtractions",
            "startAnalysis() must set X-Document-Metadata-product-tag to 'cxExtractions' on the composite document POST"
        )
    }

    @Test("startAnalysis() sends autoDetectExtractions tag when productTag is .autoDetectExtractions")
    func analyseSendsAutoDetectTag() {
        defer { GiniConfiguration.shared.productTag = .sepaExtractions }
        GiniConfiguration.shared.productTag = .autoDetectExtractions
        let (service, mock) = makeDocumentServiceWithPartialDoc()

        service.startAnalysis { _ in }

        #expect(
            mock.capturedAnalyseMetadata?.headers[productTagHeaderKey] == "autoDetectExtractions",
            "startAnalysis() must set X-Document-Metadata-product-tag to 'autoDetectExtractions' on the composite document POST"
        )
    }

    @Test("startAnalysis() defaults to sepaExtractions when productTag is nil")
    func analyseDefaultsToSEPAWhenTagIsNil() {
        defer { GiniConfiguration.shared.productTag = .sepaExtractions }
        GiniConfiguration.shared.productTag = nil
        let (service, mock) = makeDocumentServiceWithPartialDoc()

        service.startAnalysis { _ in }

        #expect(
            mock.capturedAnalyseMetadata?.headers[productTagHeaderKey] == "sepaExtractions",
            "startAnalysis() must default X-Document-Metadata-product-tag to 'sepaExtractions' when productTag is nil"
        )
    }
}
