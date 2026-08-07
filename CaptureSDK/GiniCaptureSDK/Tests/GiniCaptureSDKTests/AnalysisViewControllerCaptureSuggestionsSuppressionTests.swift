//
//  AnalysisViewControllerCaptureSuggestionsSuppressionTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import UIKit
@testable import GiniCaptureSDK

@Suite("AnalysisViewController capture suggestions suppression")
struct AnalysisViewControllerCaptureSuggestionsSuppressionTests {

    // MARK: - Fixture

    @MainActor private func makeSUT() -> AnalysisViewController {
        let image = GiniCaptureTestsHelper.loadImage(named: "invoice")
        let data = image.jpegData(compressionQuality: 0.2) ?? Data()
        let document = GiniImageDocument(data: data, imageSource: .external)
        return AnalysisViewController(document: document,
                                      giniConfiguration: GiniConfiguration())
    }

    // MARK: - Contract

    @Test("Suppression flag defaults to false")
    @MainActor func flagDefaultsToFalse() {
        let sut = makeSUT()
        #expect(!sut.shouldSuppressCaptureSuggestions,
                "shouldSuppressCaptureSuggestions must default to false so existing analysis screens keep showing suggestions")
    }

    @Test("Suppression flag is externally settable")
    @MainActor func flagIsExternallySettable() {
        let sut = makeSUT()
        sut.shouldSuppressCaptureSuggestions = true
        #expect(sut.shouldSuppressCaptureSuggestions,
                "shouldSuppressCaptureSuggestions must be internal-settable so a coordinator can toggle it before presenting a modal")
    }

    @Test("removeCaptureSuggestions is callable from outside and safe on empty state")
    @MainActor func removeIsCallableFromOutside() {
        let sut = makeSUT()
        _ = sut.view

        // Must not crash even when no suggestion view is currently attached.
        sut.removeCaptureSuggestions()

        #expect(!containsCaptureSuggestions(sut.view),
                "removeCaptureSuggestions must leave the view hierarchy clean")
    }

    @Test("Setting the flag before viewDidLoad prevents suggestions from being attached")
    @MainActor func flagPreventsAttachment() {
        let sut = makeSUT()
        sut.shouldSuppressCaptureSuggestions = true

        _ = sut.view // triggers viewDidLoad

        #expect(!containsCaptureSuggestions(sut.view),
                "With shouldSuppressCaptureSuggestions = true, showCaptureSuggestions must early-return and no CaptureSuggestionsView must be added")
    }

    // MARK: - Helpers

    @MainActor private func containsCaptureSuggestions(_ view: UIView) -> Bool {
        if view is CaptureSuggestionsView { return true }
        return view.subviews.contains { containsCaptureSuggestions($0) }
    }
}
