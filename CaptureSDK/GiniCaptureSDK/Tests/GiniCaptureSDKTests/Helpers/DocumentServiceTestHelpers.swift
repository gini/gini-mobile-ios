//
//  DocumentServiceTestHelpers.swift
//  GiniCaptureSDK
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
@testable import GiniCaptureSDK
@testable import GiniBankAPILibrary

// MARK: - Shared type

/**
 Convenience tuple pairing a `DocumentService` under test with its mock network layer.
 */
typealias DocumentServiceSUT = (service: GiniCaptureSDK.DocumentService,
                                mock: MockCaptureNetworkService)

// MARK: - Shared constants

/**
 The fully-qualified header key `X-Document-Metadata-product-tag`.
 */
let productTagHeaderKey = Document.Metadata.headerKeyPrefix + Document.Metadata.productTagHeaderKey

// MARK: - Factory functions

/**
 Creates a `DocumentService` backed by a fresh `MockCaptureNetworkService`.

 - Parameters:
    - metadata: Optional base metadata to pass into the service.
 - Returns: A `DocumentServiceSUT` tuple ready for use in a test.
 */
func makeDocumentService(metadata: Document.Metadata? = nil) -> DocumentServiceSUT {
    let mock = MockCaptureNetworkService()
    let service = GiniCaptureSDK.DocumentService(giniCaptureNetworkService: mock, metadata: metadata)
    return (service, mock)
}

/**
 Creates a `DocumentService` that already has one partial document recorded,
 which is required so `startAnalysis()` has something to pass to `analyse()`.

 The captured metadata from the seeding upload is cleared via `resetCaptures()`
 so that assertions in `startAnalysis()` tests are fully isolated.

 - Parameters:
    - metadata: Optional base metadata to pass into the service.
 - Returns: A `DocumentServiceSUT` tuple with a pre-seeded partial document.
 */
func makeDocumentServiceWithPartialDoc(metadata: Document.Metadata? = nil) -> DocumentServiceSUT {
    let mock = MockCaptureNetworkService()
    let service = GiniCaptureSDK.DocumentService(giniCaptureNetworkService: mock, metadata: metadata)

    // Upload a document so partialDocuments is non-empty.
    service.upload(document: makeImageDocument(), completion: nil)
    // Reset captured metadata so startAnalysis() result is isolated.
    mock.resetCaptures()

    return (service, mock)
}

/**
 Builds a minimal `GiniImageDocument` from a bundled JPEG fixture.

 Falls back to constructing one directly if the bundle resource lookup fails.
 */
func makeImageDocument() -> GiniImageDocument {
    let builder = GiniCaptureDocumentBuilder(documentSource: .external)
    return (builder.build(with: makeInvoiceData(), fileName: "test.jpg") as? GiniImageDocument)
        ?? GiniImageDocument(data: makeInvoiceData(),
                             imageSource: .external,
                             imageImportMethod: .openWith,
                             deviceOrientation: nil)
}

/**
 Builds a `GiniImageDocument` whose `uploadMetadata` is `nil`.
 Uses the external source path, which skips camera metadata population.
 */
func makeDocumentWithoutUploadMetadata() -> GiniImageDocument {
    makeImageDocument()
}

/**
 Builds a `GiniImageDocument` with a populated `Document.UploadMetadata`,
 simulating a document captured from the camera.
 */
func makeDocumentWithUploadMetadata() -> GiniImageDocument {
    let uploadMetadata = Document.UploadMetadata(
        interfaceOrientation: .portrait,
        documentSource: .camera,
        importMethod: nil
    )
    return GiniImageDocument(data: makeInvoiceData(),
                             imageSource: .camera,
                             deviceOrientation: .portrait,
                             uploadMetadata: uploadMetadata)
}

// MARK: - Private

private func makeInvoiceData() -> Data {
    GiniCaptureTestsHelper.fileData(named: "invoice", fileExtension: "jpg") ?? Data()
}
