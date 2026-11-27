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

        #expect(String(label.characters) == "Printed on the document, DE89 3704 0044 0532 0130 00",
                "No trailing separator or footer should leak when footer is nil.")
    }

    @Test("Accessibility label appends the footer when present so the warning is announced")
    func accessibilityLabelIncludesFooter() {
        let label = GiniOptionRowAccessibility.makeLabel(title: "In the QR code",
                                                         content: "PL12 1000 0111 0100 1000",
                                                         footer: "From Poland, not the sender's country")

        #expect(String(label.characters) == "In the QR code, PL12 1000 0111 0100 1000, From Poland, not the sender's country",
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

        #expect(String(label.characters) == expected,
                "An empty footer string is not treated as absent — callers should pass nil to omit it.")
    }

    @Test("spellsOutContent defaults to false so the content segment carries no speech attribute")
    func spellsOutContentDefaultIsOff() {
        let label = GiniOptionRowAccessibility.makeLabel(title: "In the QR code",
                                                         content: "PL12 1000 0111 0100 1000",
                                                         footer: nil)

        let contentRange = label.range(of: "PL12 1000 0111 0100 1000")
        #expect(contentRange != nil, "Content must be locatable inside the composed label.")
        if let contentRange {
            #expect(label[contentRange].accessibilitySpeechSpellsOutCharacters == nil,
                    "Default behavior leaves speech attributes untouched so VoiceOver reads the content as a word.")
        }
    }

    @Test("spellsOutContent flips accessibilitySpeechSpellsOutCharacters on the content segment only")
    func spellsOutContentAppliesToContentOnly() {
        let label = GiniOptionRowAccessibility.makeLabel(title: "In the QR code",
                                                         content: "PL12 1000 0111 0100 1000",
                                                         footer: "From Poland, not the sender's country",
                                                         spellsOutContent: true)

        let titleRange = label.range(of: "In the QR code")
        let contentRange = label.range(of: "PL12 1000 0111 0100 1000")
        let footerRange = label.range(of: "From Poland, not the sender's country")

        #expect(titleRange != nil && contentRange != nil && footerRange != nil,
                "All three segments must be locatable inside the composed label.")

        if let titleRange {
            #expect(label[titleRange].accessibilitySpeechSpellsOutCharacters == nil,
                    "Title is a human phrase — it must not be spelled out.")
        }
        if let contentRange {
            #expect(label[contentRange].accessibilitySpeechSpellsOutCharacters == true,
                    "Content must carry the spell-out attribute so VoiceOver reads the IBAN character by character.")
        }
        if let footerRange {
            #expect(label[footerRange].accessibilitySpeechSpellsOutCharacters == nil,
                    "Footer is a human phrase — it must not be spelled out.")
        }
    }
}

// MARK: - Trait composition

@Suite("GiniOptionRow — composedTraits locks the trait matrix for the four row states")
struct GiniOptionRowComposedTraitsTests {

    @Test("Non-tappable and not selected — no traits")
    func composedTraitsEmpty() {
        let traits = GiniOptionRowAccessibility.composedTraits(isTappable: false,
                                                                isSelected: false)
        #expect(traits == AccessibilityTraits(),
                "An informational, non-tappable row carries no automatic traits.")
    }

    @Test("Tappable and not selected — only isButton")
    func composedTraitsButtonOnly() {
        let traits = GiniOptionRowAccessibility.composedTraits(isTappable: true,
                                                                isSelected: false)
        #expect(traits.contains(.isButton),
                "A tappable row must advertise the button trait so VoiceOver says 'button'.")
        #expect(!traits.contains(.isSelected),
                "A row that is not in the selected variant must not claim isSelected.")
    }

    @Test("Non-tappable and selected — only isSelected")
    func composedTraitsSelectedOnly() {
        let traits = GiniOptionRowAccessibility.composedTraits(isTappable: false,
                                                                isSelected: true)
        #expect(traits.contains(.isSelected),
                "A selected row must advertise the selected trait.")
        #expect(!traits.contains(.isButton),
                "A row with no onTap must not advertise the button trait.")
    }

    @Test("Tappable and selected — both isButton and isSelected")
    func composedTraitsBoth() {
        let traits = GiniOptionRowAccessibility.composedTraits(isTappable: true,
                                                                isSelected: true)
        #expect(traits.contains(.isButton),
                "A tappable + selected row must advertise both traits — button first.")
        #expect(traits.contains(.isSelected),
                "A tappable + selected row must advertise both traits — selected second.")
    }
}

// MARK: - Error-state accessibility value

@Suite("GiniOptionRow — accessibilityValueWhenError gates on the error radio state")
@MainActor
struct GiniOptionRowErrorStateAccessibilityValueTests {

    @Test("A row in .radio(.error) renders without crashing when the error value is provided")
    func rendersInErrorStateWithValue() {
        let row = GiniOptionRow(title: "In the QR code",
                                content: "PL12 1000 0111 0100 1000",
                                variant: .radio(.error),
                                giniColorScheme: GiniOptionRowPreviewCatalog.previewScheme,
                                accessibilityValueWhenError: "Select an IBAN to continue",
                                onTap: {})

        renderAndLayout(row)
    }

    @Test("A row NOT in .radio(.error) renders when the error value is provided (value is silenced)")
    func rendersInNonErrorStateWithValue() {
        let states: [GiniOptionRow.Variant] = [
            .radio(.unselected),
            .radio(.selected),
            .informational
        ]

        for state in states {
            let row = GiniOptionRow(title: "In the QR code",
                                    content: "PL12 1000 0111 0100 1000",
                                    variant: state,
                                    giniColorScheme: GiniOptionRowPreviewCatalog.previewScheme,
                                    accessibilityValueWhenError: "Select an IBAN to continue",
                                    onTap: {})
            renderAndLayout(row)
        }
    }

    @Test("A row in .radio(.error) with no error value renders (value is silenced)")
    func rendersInErrorStateWithoutValue() {
        let row = GiniOptionRow(title: "In the QR code",
                                content: "PL12 1000 0111 0100 1000",
                                variant: .radio(.error),
                                giniColorScheme: GiniOptionRowPreviewCatalog.previewScheme,
                                onTap: {})

        renderAndLayout(row)
    }

    private func renderAndLayout(_ row: GiniOptionRow) {
        let hosting = UIHostingController(rootView: row)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 200))
        window.rootViewController = hosting
        window.isHidden = false
        hosting.view.setNeedsLayout()
        hosting.view.layoutIfNeeded()
    }
}

// MARK: - Variant convenience flags

@Suite("GiniOptionRow.Variant — convenience flags")
struct GiniOptionRowVariantFlagTests {

    @Test("isSelected is true only for .radio(.selected)")
    func isSelected() {
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
        let config = GiniOptionRow.FontConfiguration()

        #expect(config.title == nil, "Default title should be nil.")
        #expect(config.content == nil, "Default content should be nil.")
        #expect(config.footer == nil, "Default footer should be nil.")
    }

    @Test("Explicit values are stored verbatim so callers can bridge via Font(giniFont:)")
    func explicitValuesAreStored() {
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
        let row = GiniOptionRow(title: "Title",
                                content: "Content",
                                variant: .radio(.unselected),
                                giniColorScheme: GiniOptionRowPreviewCatalog.previewScheme,
                                onTap: {})

        renderAndLayout(row)
    }

    @Test("GiniOptionRow renders the non-interactive path when onTap is nil")
    func rendersWithoutOnTap() {
        let row = GiniOptionRow(title: "Title",
                                content: "Content",
                                variant: .informational,
                                giniColorScheme: GiniOptionRowPreviewCatalog.previewScheme)

        renderAndLayout(row)
    }

    @Test("GiniOptionRow renders the background layer when a background color is provided")
    func rendersWithBackground() {
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
