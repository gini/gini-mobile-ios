//
//  GiniOptionRow.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI
import UIKit

/**
 A radio-button-style selectable row that pairs a small title with a larger
 content value and an optional warning footer, with a leading state-colored
 circle — or, in the `.informational` variant, the same text layout without a
 leading indicator.

 Variants:
 - `.radio(RadioButtonState)` — leading circle whose symbol and tint are driven
   by one of three `RadioButtonState` cases (`unselected`, `selected`, `error`).
 - `.informational` — no circle; typically rendered with a background so the
   row reads as a standalone card instead of a selectable list entry.

 Colors are resolved against a `GiniColorScheme` passed by the caller so the
 row carries no SDK-specific color decisions. All copy is passed as
 pre-localized strings so the component carries no localization keys either.
 The background is optional and caller-supplied, so a Liquid Glass sheet on
 iOS 26+ can keep owning its surface without the row double-stacking glass.
 */
@available(iOS 16.0, *)
public struct GiniOptionRow: View {

    /// Visual state of the leading radio indicator (only used by the `.radio` variant).
    public enum RadioButtonState: Hashable {
        /// Default, tappable, not selected.
        case unselected
        /// Chosen by the user; leading circle is filled with the accent tint.
        case selected
        /// Warning variant; leading circle and footer are tinted error-red.
        case error
    }

    /// Row variant — a radio row with a leading indicator, or a plain
    /// informational row with no indicator.
    public enum Variant: Hashable {
        case radio(RadioButtonState)
        case informational
    }

    /**
     Fonts used by the three text lines (title, content, footer). Each is
     optional; `nil` falls back to a SwiftUI system font that respects Dynamic
     Type. Non-nil values are bridged to SwiftUI via `Font(giniFont:)`.

     Resolve values from the host SDK's configuration (do not hand-roll
     `UIFont.systemFont(ofSize:)` at the call site):

     - **CaptureSDK / BankSDK** — internal `textStyleFonts` dictionary on
       `GiniConfiguration` / `GiniBankConfiguration` (SDK-internal access only):
       ```swift
       GiniOptionRow.FontConfiguration(title: giniBankConfiguration.textStyleFonts[.captions1],
                                       content: giniBankConfiguration.textStyleFonts[.body1],
                                       footer: giniBankConfiguration.textStyleFonts[.captions2])
       ```

     - **HealthSDK** — public `GiniHealthConfiguration.font(for:)`, backed by
       the shared `FontProvider` (`GiniUtilites/Font/FontProvider.swift`):
       ```swift
       GiniOptionRow.FontConfiguration(title: giniHealthConfiguration.font(for: .captions1),
                                       content: giniHealthConfiguration.font(for: .body1),
                                       footer: giniHealthConfiguration.font(for: .captions2))
       ```

     An all-`nil` `FontConfiguration` (the init default) means "use SwiftUI
     system fonts for all three lines."
     */
    public struct FontConfiguration {
        public let title: UIFont?
        public let content: UIFont?
        public let footer: UIFont?

        public init(title: UIFont? = nil,
                    content: UIFont? = nil,
                    footer: UIFont? = nil) {
            self.title = title
            self.content = content
            self.footer = footer
        }
    }

    let title: String
    let content: String
    let footer: String?
    let variant: Variant
    let giniColorScheme: GiniColorScheme
    let background: GiniColor?
    let titleFont: Font
    let contentFont: Font
    let footerFont: Font
    let onTap: (() -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /**
     Creates a selectable info row.

     - Parameters:
       - title: Small label above the content (e.g. "Printed on the document"). Already localized.
       - content: Primary value shown to the user (e.g. an IBAN). Already localized.
       - footer: Optional warning line shown below the content, tinted error-red. Already localized.
       - variant: `.radio(RadioButtonState)` for a selectable row with a leading circle, or `.informational` for a non-radio display row.
       - giniColorScheme: Design-system token source. Pass the host SDK's scheme (e.g. `UIColor.giniBankColorScheme()`).
       - background: Optional background color for the row. Typically `nil` for radio rows (parent sheet owns the surface) and a semantic token for informational rows that need to stand alone.
       - fonts: Font bundle for the three text lines. See `FontConfiguration` for SDK-specific resolution examples. Defaults to system fonts.
       - onTap: Invoked when the user taps the row. Pass `nil` for a non-interactive row (common for `.informational`).
     */
    public init(title: String,
                content: String,
                footer: String? = nil,
                variant: Variant,
                giniColorScheme: GiniColorScheme,
                background: GiniColor? = nil,
                fonts: FontConfiguration = .init(),
                onTap: (() -> Void)? = nil) {
        self.title = title
        self.content = content
        self.footer = footer
        self.variant = variant
        self.giniColorScheme = giniColorScheme
        self.background = background
        self.titleFont = fonts.title.map { Font(giniFont: $0) } ?? .caption
        self.contentFont = fonts.content.map { Font(giniFont: $0) } ?? .body
        self.footerFont = fonts.footer.map { Font(giniFont: $0) } ?? .footnote
        self.onTap = onTap
    }

    public var body: some View {
        rowContent
            .animation(reduceMotion ? nil : .easeInOut(duration: Constants.animationDuration),
                       value: variant)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(GiniOptionRowAccessibility.makeLabel(title: title,
                                                                     content: content,
                                                                     footer: footer))
            .accessibilityAddTraits(variant.isSelected ? .isSelected : [])
    }

    @ViewBuilder
    private var rowContent: some View {
        if let onTap {
            Button(action: onTap) {
                rowLayout
            }
            .buttonStyle(.plain)
        } else {
            rowLayout
        }
    }

    private var rowLayout: some View {
        HStack(alignment: .center, spacing: Constants.horizontalSpacing) {
            if case .radio(let state) = variant {
                Self.stateIcon(for: state,
                               giniColorScheme: giniColorScheme)
                    .font(.title3)
                    .frame(width: Constants.iconSize, height: Constants.iconSize)
            }
            textStack
            Spacer(minLength: 0)
        }
        .padding(Constants.contentPadding)
        .background(backgroundLayer)
        .contentShape(Rectangle())
    }

    private var textStack: some View {
        VStack(alignment: .leading, spacing: Constants.verticalSpacing) {
            Text(title)
                .font(titleFont)
                .foregroundStyle(titleColor)
            Text(content)
                .font(contentFont)
                .foregroundStyle(contentColor)
            if let footer {
                Text(footer)
                    .font(footerFont)
                    .foregroundStyle(footerColor)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private var backgroundLayer: some View {
        if let background {
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .fill(background.swiftUIColor())
        }
    }

    // MARK: - Token resolution

    private var titleColor: Color {
        giniColorScheme.text.secondary.swiftUIColor()
    }

    private var contentColor: Color {
        giniColorScheme.text.primary.swiftUIColor()
    }

    private var footerColor: Color {
        giniColorScheme.text.error.swiftUIColor()
    }

    /// Visual icon for the row's radio state. Looks up a host-overridable asset
    /// via `preferredImage(named:)` (main-bundle-first, then `.module`); falls back
    /// to SF Symbol / custom shape when the asset is absent (expected until a
    /// designer exports the PDFs into the imagesets).
    @ViewBuilder
    static func stateIcon(for state: RadioButtonState,
                          giniColorScheme: GiniColorScheme) -> some View {
        switch state {
        case .unselected: unselectedIcon(giniColorScheme: giniColorScheme)
        case .selected:   selectedIcon(giniColorScheme: giniColorScheme)
        case .error:      errorIcon(giniColorScheme: giniColorScheme)
        }
    }

    @ViewBuilder
    private static func unselectedIcon(giniColorScheme: GiniColorScheme) -> some View {
        let tint = giniColorScheme.icon.secondary.swiftUIColor()
        if let uiImage = preferredImage(named: Icons.unselected) {
            Image(uiImage: uiImage).resizable().foregroundStyle(tint)
        } else {
            Image(systemName: "circle").foregroundStyle(tint)
        }
    }

    /**
     Selected asset ships with its own blue + white-interior colors
     ("original" rendering), so no `.foregroundStyle` tint on the asset path.
     */
    @ViewBuilder
    private static func selectedIcon(giniColorScheme: GiniColorScheme) -> some View {
        if let uiImage = preferredImage(named: Icons.selected) {
            Image(uiImage: uiImage).resizable()
        } else {
            Circle()
                .strokeBorder(giniColorScheme.text.accent.swiftUIColor(),
                              lineWidth: Constants.selectedStrokeWidth)
        }
    }

    /**
     Error asset ships with its own fill + stroke colors ("original"
     rendering), so no `.foregroundStyle` tint on the asset path.
     */
    @ViewBuilder
    private static func errorIcon(giniColorScheme: GiniColorScheme) -> some View {
        if let uiImage = preferredImage(named: Icons.error) {
            Image(uiImage: uiImage).resizable()
        } else {
            Circle()
                .fill(giniColorScheme.message.backgroundError.swiftUIColor())
                .overlay {
                    Circle()
                        .strokeBorder(giniColorScheme.message.contentError.swiftUIColor(),
                                      lineWidth: Constants.errorStrokeWidth)
                }
        }
    }

    /// Asset-name constants for the radio icons shipped in `GiniIcons.xcassets`.
    /// Host apps override by including an asset with the same name in their main bundle.
    enum Icons {
        static let unselected = "radio_unselected"
        static let selected = "radio_selected"
        static let error = "radio_error"
    }

    enum Constants {
        static let horizontalSpacing: CGFloat = 12
        static let verticalSpacing: CGFloat = 6
        static let contentPadding: CGFloat = 12
        static let iconSize: CGFloat = 24
        static let cornerRadius: CGFloat = 12
        static let animationDuration: Double = 0.2
        static let selectedStrokeWidth: CGFloat = 2.5
        static let errorStrokeWidth: CGFloat = 1.5
    }
}

/**
 Pure-string helpers for `GiniOptionRow`. Kept outside the `@available`-gated
 type so Swift Testing's `@Suite`/`@Test` macros can be applied directly — they
 cannot decorate `@available`-marked declarations.
 */
enum GiniOptionRowAccessibility {

    /// Builds the combined VoiceOver label from the caller-provided (already localized) strings.
    static func makeLabel(title: String,
                          content: String,
                          footer: String?) -> String {
        if let footer {
            return "\(title), \(content), \(footer)"
        }
        return "\(title), \(content)"
    }
}

// MARK: - Variant convenience

@available(iOS 16.0, *)
extension GiniOptionRow.Variant {

    /// `true` for `.radio(.selected)` only.
    var isSelected: Bool {
        if case .radio(.selected) = self { return true }
        return false
    }
}

#if DEBUG
// MARK: - Preview

@available(iOS 16.0, *)
#Preview("All variants — light") {
    GiniOptionRowPreviewCatalog()
        .padding()
}

@available(iOS 16.0, *)
#Preview("All variants — dark") {
    GiniOptionRowPreviewCatalog()
        .padding()
        .preferredColorScheme(.dark)
}

@available(iOS 16.0, *)
#Preview("Dynamic Type — AX3") {
    GiniOptionRowPreviewCatalog()
        .padding()
        .environment(\.sizeCategory, .accessibilityExtraLarge)
}
#endif
