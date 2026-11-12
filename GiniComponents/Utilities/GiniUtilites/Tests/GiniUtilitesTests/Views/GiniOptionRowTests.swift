//
//  GiniOptionRowTests.swift
//  GiniUtilitesTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import SwiftUI
import UIKit
@testable import GiniUtilites

@Suite("GiniOptionRow — accessibility label composition")
struct GiniOptionRowAccessibilityLabelTests {

    @Test("Accessibility label joins title and content when no footer is provided")
    func accessibilityLabelOmitsFooterWhenNil() {
        let label = GiniOptionRowAccessibility.makeLabel(title: "Printed on the document",
                                                         content: "DE89 3704 0044 0532 0130 00",
                                                         footer: nil)

        #expect(label == "Printed on the document, DE89 3704 0044 0532 0130 00",
                "No trailing separator or footer should leak when footer is nil.")
    }

    @Test("Accessibility label appends the footer when present so the warning is announced")
    func accessibilityLabelIncludesFooter() {
        let label = GiniOptionRowAccessibility.makeLabel(title: "In the QR code",
                                                         content: "PL12 1000 0111 0100 1000",
                                                         footer: "From Poland, not the sender's country")

        #expect(label == "In the QR code, PL12 1000 0111 0100 1000, From Poland, not the sender's country",
                "Footer must be included verbatim so VoiceOver reads the warning in one pass.")
    }

    @Test("Accessibility label passes an empty footer string through — callers must pre-filter",
          arguments: [
            ("", "Title, Content, "),
            ("Warning", "Title, Content, Warning")
          ])
    func accessibilityLabelPassesThroughEmptyFooter(footer: String,
                                                    expected: String) {
        let label = GiniOptionRowAccessibility.makeLabel(title: "Title",
                                                         content: "Content",
                                                         footer: footer)

        #expect(label == expected,
                "An empty footer string is not treated as absent — callers should pass nil to omit it.")
    }
}

// MARK: - Variant convenience flags
//
// Suites and tests below cannot be marked `@available(iOS 16.0, *)` because
// Swift Testing's `@Suite`/`@Test` macros refuse to decorate availability-
// gated declarations. Each test body wraps its iOS-16-only work in
// `if #available(iOS 16.0, *)` instead — on CI (iOS 26.2) the guard always
// succeeds; on hypothetical older runtimes the body is a no-op.

@Suite("GiniOptionRow.Variant — convenience flags")
struct GiniOptionRowVariantFlagTests {

    @Test("isSelected is true only for .radio(.selected)")
    func isSelected() {
        guard #available(iOS 16.0, *) else { return }

        #expect(GiniOptionRow.Variant.radio(.unselected).isSelected == false)
        #expect(GiniOptionRow.Variant.radio(.selected).isSelected == true,
                "Only .radio(.selected) should report selected — other radio states and informational never are.")
        #expect(GiniOptionRow.Variant.radio(.error).isSelected == false)
        #expect(GiniOptionRow.Variant.informational.isSelected == false)
    }
}

// MARK: - FontConfiguration init

@Suite("GiniOptionRow.FontConfiguration — init")
struct GiniOptionRowFontConfigurationTests {

    @Test("Default init stores nil for all three lines (system-font fallback at call sites)")
    func defaultInitIsAllNil() {
        guard #available(iOS 16.0, *) else { return }

        let config = GiniOptionRow.FontConfiguration()

        #expect(config.title == nil, "Default title should be nil.")
        #expect(config.content == nil, "Default content should be nil.")
        #expect(config.footer == nil, "Default footer should be nil.")
    }

    @Test("Explicit values are stored verbatim so callers can bridge via Font(giniFont:)")
    func explicitValuesAreStored() {
        guard #available(iOS 16.0, *) else { return }

        let titleFont = UIFont.systemFont(ofSize: 11)
        let contentFont = UIFont.systemFont(ofSize: 17)
        let footerFont = UIFont.systemFont(ofSize: 12)

        let config = GiniOptionRow.FontConfiguration(title: titleFont,
                                                     content: contentFont,
                                                     footer: footerFont)

        #expect(config.title == titleFont, "Title UIFont should be preserved.")
        #expect(config.content == contentFont, "Content UIFont should be preserved.")
        #expect(config.footer == footerFont, "Footer UIFont should be preserved.")
    }
}

// MARK: - State icon helpers

@Suite("GiniOptionRow — stateIcon branches execute for every RadioButtonState")
@MainActor
struct GiniOptionRowStateIconTests {

    @Test("stateIcon(for:) builds a view for every RadioButtonState")
    func stateIconBuildsForEveryState() {
        guard #available(iOS 16.0, *) else { return }

        let states: [GiniOptionRow.RadioButtonState] = [.unselected, .selected, .error]

        for state in states {
            let hosting = UIHostingController(rootView: GiniOptionRow.stateIcon(for: state))
            hosting.loadViewIfNeeded()
            hosting.view.setNeedsLayout()
            hosting.view.layoutIfNeeded()
        }
    }
}

// MARK: - Body rendering

/**
 Renders `GiniOptionRow` via `UIHostingController` so the view `body` (and the
 private computed properties it reads — `rowContent`, `rowLayout`, `textStack`,
 `backgroundLayer`, `titleColor`, `contentColor`, `footerColor`) actually
 executes. These tests cover the SwiftUI composition without a snapshot or
 reflection framework.
 */
@Suite("GiniOptionRow — body renders for every variant and option")
@MainActor
struct GiniOptionRowRenderingTests {

    @Test("GiniOptionRow renders without crashing for every Variant")
    func rendersAllVariants() {
        guard #available(iOS 16.0, *) else { return }

        let variants: [GiniOptionRow.Variant] = [
            .radio(.unselected),
            .radio(.selected),
            .radio(.error),
            .informational
        ]

        for variant in variants {
            let row = GiniOptionRow(title: "Printed on the document",
                                    content: "DE89 3704 0044 0532 0130 00",
                                    footer: "Warning footer",
                                    variant: variant,
                                    giniColorScheme: GiniOptionRowPreviewCatalog.previewScheme,
                                    onTap: {})
            renderAndLayout(row)
        }
    }

    @Test("GiniOptionRow renders the no-footer path when footer is nil")
    func rendersWithoutFooter() {
        guard #available(iOS 16.0, *) else { return }

        let row = GiniOptionRow(title: "Title",
                                content: "Content",
                                variant: .radio(.unselected),
                                giniColorScheme: GiniOptionRowPreviewCatalog.previewScheme,
                                onTap: {})

        renderAndLayout(row)
    }

    @Test("GiniOptionRow renders the non-interactive path when onTap is nil")
    func rendersWithoutOnTap() {
        guard #available(iOS 16.0, *) else { return }

        let row = GiniOptionRow(title: "Title",
                                content: "Content",
                                variant: .informational,
                                giniColorScheme: GiniOptionRowPreviewCatalog.previewScheme)

        renderAndLayout(row)
    }

    @Test("GiniOptionRow renders the background layer when a background color is provided")
    func rendersWithBackground() {
        guard #available(iOS 16.0, *) else { return }

        let background = GiniColor(lightModeColor: .secondarySystemBackground,
                                   darkModeColor: .secondarySystemBackground)

        let row = GiniOptionRow(title: "Title",
                                content: "Content",
                                variant: .informational,
                                giniColorScheme: GiniOptionRowPreviewCatalog.previewScheme,
                                background: background)

        renderAndLayout(row)
    }

    @Test("GiniOptionRow renders when the caller passes explicit UIFonts (exercises Font(giniFont:) bridging)")
    func rendersWithExplicitFonts() {
        guard #available(iOS 16.0, *) else { return }

        let fonts = GiniOptionRow.FontConfiguration(title: .systemFont(ofSize: 11),
                                                    content: .systemFont(ofSize: 17),
                                                    footer: .systemFont(ofSize: 12))

        let row = GiniOptionRow(title: "Title",
                                content: "Content",
                                footer: "Footer",
                                variant: .radio(.selected),
                                giniColorScheme: GiniOptionRowPreviewCatalog.previewScheme,
                                fonts: fonts,
                                onTap: {})

        renderAndLayout(row)
    }

    @available(iOS 16.0, *)
    private func renderAndLayout(_ row: GiniOptionRow) {
        let hosting = UIHostingController(rootView: row)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 200))
        window.rootViewController = hosting
        // Attaching to a visible window forces SwiftUI to evaluate `body`
        // and the chain of computed properties (`rowContent`, `rowLayout`,
        // `textStack`, `backgroundLayer`, `titleColor`, `contentColor`,
        // `footerColor`) — `loadViewIfNeeded()` alone leaves them unevaluated.
        window.isHidden = false
        hosting.view.setNeedsLayout()
        hosting.view.layoutIfNeeded()
    }
}

// MARK: - GiniIcons enum

@Suite("GiniIcons — asset-name raw values + .image resolution")
struct GiniIconsTests {

    @Test("Raw values are the exact names shipped in GiniIcons.xcassets")
    func rawValueMatchesAsset() {
        #expect(GiniIcons.radioUnselected.rawValue == "radio_unselected")
        #expect(GiniIcons.radioSelected.rawValue == "radio_selected")
        #expect(GiniIcons.radioError.rawValue == "radio_error")
    }

    @Test(".image resolves every case through the preferredImage chain and returns a non-nil UIImage from the module bundle",
          arguments: [GiniIcons.radioUnselected, .radioSelected, .radioError])
    func imageResolvesForEveryCase(icon: GiniIcons) {
        #expect(icon.image != nil,
                "Expected \(icon.rawValue) to load from the GiniUtilites .module bundle.")
    }
}

// MARK: - preferredImage(named:in:) free function

@Suite("preferredImage(named:in:) — host-override precedence chain")
struct PreferredImageTests {

    @Test("Returns the shipped PDF from the GiniUtilites module bundle when the host did not override",
          arguments: ["radio_unselected", "radio_selected", "radio_error"])
    func returnsModuleBundleImage(name: String) {
        let image = preferredImage(named: name)

        #expect(image != nil,
                "Expected the \(name) imageset to load from the GiniUtilites .module bundle.")
    }

    @Test("Returns nil when the asset is absent from every bundle in the chain")
    func returnsNilWhenAssetIsMissing() {
        let image = preferredImage(named: "this_asset_does_not_exist_anywhere")

        #expect(image == nil,
                "Missing asset should return nil after main → custom → module all miss.")
    }

    @Test("The non-nil-customBundle branch is executed when a custom bundle is provided")
    func customBundleBranchIsExecuted() {
        // Passing `Bundle.main` as the customBundle argument exercises the
        // `if let customBundle` branch. Bundle.main (the test host) doesn't
        // contain `radio_selected`, so the function falls through to the
        // GiniUtilites `.module` bundle and returns the shipped PDF —
        // covering the final fallback line in the same call.
        let image = preferredImage(named: "radio_selected", in: Bundle.main)

        #expect(image != nil,
                "When the main and custom bundles both miss, the function should fall through to the module bundle.")
    }
}
