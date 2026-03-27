//
//  DocumentMetadataBuildTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import Foundation
@testable import GiniCaptureSDK
@testable import GiniBankAPILibrary

// MARK: - Document.Metadata.build — branch coverage

/**
 Tests for `Document.Metadata.build(merging:for:productTagValue:)`.

 Covers all four branches of the method:
 1. No `uploadMetadata`, no `base` — creates fresh metadata with tag.
 2. No `uploadMetadata`, `base` present — adds tag to base, preserving existing headers.
 3. `uploadMetadata` present, no `base` — creates metadata from upload info and adds tag.
 4. Both present — merges upload info into base, then adds tag.
 */
@Suite("Document.Metadata.build — all branches")
struct DocumentMetadataBuildTests {

    private let tag = "cxExtractions"
    private let tagKey = Document.Metadata.headerKeyPrefix + Document.Metadata.productTagHeaderKey
    private let branchKey = Document.Metadata.headerKeyPrefix + Document.Metadata.branchIdHeaderKey

    // MARK: Branch 1: no uploadMetadata, no base

    @Test("build sets product tag on fresh Metadata when base is nil and document has no uploadMetadata")
    func buildWithNilBaseAndNoUploadMetadata() {
        let result = Document.Metadata.build(merging: nil,
                                             for: makeDocumentWithoutUploadMetadata(),
                                             productTagValue: tag)
        #expect(result.headers[tagKey] == tag)
    }

    // MARK: Branch 2: no uploadMetadata, base present

    @Test("build adds product tag to base Metadata and preserves existing headers")
    func buildWithBaseAndNoUploadMetadata() {
        let result = Document.Metadata.build(merging: Document.Metadata(branchId: "my-branch"),
                                             for: makeDocumentWithoutUploadMetadata(),
                                             productTagValue: tag)
        #expect(result.headers[tagKey] == tag)
        #expect(result.headers[branchKey] == "my-branch")
    }

    // MARK: Branch 3: uploadMetadata present, no base

    @Test("build creates Metadata from uploadMetadata and sets product tag when base is nil")
    func buildWithNilBaseAndUploadMetadata() {
        let result = Document.Metadata.build(merging: nil,
                                             for: makeDocumentWithUploadMetadata(),
                                             productTagValue: tag)
        #expect(result.headers[tagKey] == tag)
        #expect(result.hasUploadMetadata())
    }

    // MARK: Branch 4: uploadMetadata present, base present

    @Test("build merges uploadMetadata into base and sets product tag when both are present")
    func buildWithBaseAndUploadMetadata() {
        let result = Document.Metadata.build(merging: Document.Metadata(branchId: "my-branch"),
                                             for: makeDocumentWithUploadMetadata(),
                                             productTagValue: tag)
        #expect(result.headers[tagKey] == tag)
        #expect(result.headers[branchKey] == "my-branch")
        #expect(result.hasUploadMetadata())
    }
}

