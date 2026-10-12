//
//  GiniImageDocumentAcceptedTypesTests.swift
//  GiniCaptureSDK_Tests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import MobileCoreServices
@testable import GiniCaptureSDK

/**
 Guards the UTI whitelist that `DocumentPickerCoordinator` feeds into
 `UIDocumentPickerViewController(documentTypes:)`. Files.app greys out any
 type not in this list, so a regression here silently blocks HEIC / HEIF
 selection on the Files-app import path — the exact PP-2298 gap.
 */
@Suite("GiniImageDocument.acceptedImageTypes")
struct GiniImageDocumentAcceptedTypesTests {

    @Test("Whitelists the classic bitmap formats served by the backend")
    func acceptedImageTypesIncludesJPEGPNGGIFTIFF() {
        let types = GiniImageDocument.acceptedImageTypes
        #expect(types.contains(kUTTypeJPEG as String))
        #expect(types.contains(kUTTypePNG as String))
        #expect(types.contains(kUTTypeGIF as String))
        #expect(types.contains(kUTTypeTIFF as String))
    }

    @Test("Includes HEIC UTI so Files.app surfaces .heic files as selectable")
    func acceptedImageTypesIncludesHEIC() {
        #expect(GiniImageDocument.acceptedImageTypes.contains("public.heic"),
                "Regression from PP-2298 — Files.app greys out HEIC files if this UTI is missing")
    }

    @Test("Includes HEIF UTI so Files.app surfaces .heif files as selectable")
    func acceptedImageTypesIncludesHEIF() {
        #expect(GiniImageDocument.acceptedImageTypes.contains("public.heif"),
                "Regression from PP-2298 — Files.app greys out HEIF files if this UTI is missing")
    }
}
