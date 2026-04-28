//
//  GiniProductTagTests.swift
//  GiniCaptureSDK
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
@testable import GiniCaptureSDK

@Suite("GiniProductTag")
struct GiniProductTagTests {

    // MARK: - Raw Value

    @Test("rawValue returns correct string for sepaExtractions")
    func sepaExtractionsRawValue() {
        #expect(GiniProductTag.sepaExtractions.rawValue == "sepaExtractions")
    }

    @Test("rawValue returns correct string for cxExtractions")
    func cxExtractionsRawValue() {
        #expect(GiniProductTag.cxExtractions.rawValue == "cxExtractions")
    }

    @Test("rawValue returns correct string for autoDetectExtractions")
    func autoDetectExtractionsRawValue() {
        #expect(GiniProductTag.autoDetectExtractions.rawValue == "autoDetectExtractions")
    }

    @Test("rawValue returns the custom string for otherGiniProductTag")
    func otherGiniProductTagRawValue() {
        let customTag = GiniProductTag.otherProductTag("customPipeline")
        #expect(customTag.rawValue == "customPipeline")
    }

    // MARK: - Equatable

    @Test("Same cases are equal")
    func sameCasesAreEqual() {
        #expect(GiniProductTag.sepaExtractions == GiniProductTag.sepaExtractions)
        #expect(GiniProductTag.cxExtractions == GiniProductTag.cxExtractions)
        #expect(GiniProductTag.autoDetectExtractions == GiniProductTag.autoDetectExtractions)
        #expect(GiniProductTag.otherProductTag("test") == GiniProductTag.otherProductTag("test"))
    }

    @Test("Different cases are not equal")
    func differentCasesAreNotEqual() {
        #expect(GiniProductTag.sepaExtractions != GiniProductTag.cxExtractions)
        #expect(GiniProductTag.cxExtractions != GiniProductTag.autoDetectExtractions)
        #expect(GiniProductTag.otherProductTag("a") != GiniProductTag.otherProductTag("b"))
        #expect(GiniProductTag.sepaExtractions != GiniProductTag.otherProductTag("sepaExtractions"))
    }

    // MARK: - Default Configuration Value

    @Test("GiniConfiguration defaults GiniProductTag to sepaExtractions")
    func defaultGiniProductTag() {
        let configuration = GiniConfiguration()
        #expect(configuration.productTag == .sepaExtractions)
    }

    @Test("GiniConfiguration GiniProductTag can be changed")
    func setGiniProductTag() {
        let configuration = GiniConfiguration()

        configuration.productTag = .cxExtractions
        #expect(configuration.productTag == .cxExtractions)

        configuration.productTag = .otherProductTag("custom")
        #expect(configuration.productTag == .otherProductTag("custom"))

        configuration.productTag = nil
        #expect(configuration.productTag == nil)
    }
}
