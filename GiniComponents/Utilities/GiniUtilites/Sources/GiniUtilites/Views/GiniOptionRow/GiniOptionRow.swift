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
public struct GiniOptionRow: View {

    /** Visual state of the leading radio indicator (only used by the `.radio` variant). */
    public enum RadioButtonState: Hashable {
        /** Default, tappable, not selected. */
        case unselected
        /** Chosen by the user; leading circle is filled with the accent tint. */
        case selected
        /** Warning variant; leading circle and footer are tinted error-red. */
        case error
    }

    /**
     Row variant — a radio row with a leading indicator, or a plain
     informational row with no indicator.
     */
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

    /** Default `contentPadding` applied to every edge of the row. 12pt all
     around matches the Figma spec for info rows that stand alone on a
     surface; call sites that need a flush edge (e.g. a row sitting inside
     a section whose header is already at 0pt) pass `EdgeInsets` with the
     relevant side zeroed out. */
    public static let defaultContentPadding: EdgeInsets = EdgeInsets(top: 12,
                                                                     leading: 12,
                                                                     bottom: 12,
                                                                     trailing: 12)

    let title: String
    let content: String
    let spellsOutContent: Bool
    let footer: String?
    let variant: Variant
    let giniColorScheme: GiniColorScheme
    let background: GiniColor?
    let fonts: FontConfiguration
    let contentPadding: EdgeInsets
    let accessibilityValueWhenError: String?
    let onTap: (() -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /**
     Creates a selectable info row.

     - Parameters:
       - title: Small label above the content (e.g. "Printed on the document"). Already localized.
       - content: Primary value shown to the user (e.g. an IBAN). Already localized.
       - spellsOutContent: When `true`, the content segment of the VoiceOver label is read character-by-character instead of as a word — set this for fields where a one-character substitution matters (IBANs, account numbers, confirmation codes). Visual rendering is unaffected.
       - footer: Optional warning line shown below the content, tinted error-red. Already localized.
       - variant: `.radio(RadioButtonState)` for a selectable row with a leading circle, or `.informational` for a non-radio display row.
       - giniColorScheme: Design-system token source. Pass the host SDK's scheme (e.g. `UIColor.giniBankColorScheme()`).
       - background: Optional background color for the row. Typically `nil` for radio rows (parent sheet owns the surface) and a semantic token for informational rows that need to stand alone.
       - fonts: Font bundle for the three text lines. See `FontConfiguration` for SDK-specific resolution examples. Defaults to system fonts.
       - contentPadding: Insets applied around the row's content. Defaults to `defaultContentPadding` (12pt on every edge); callers can zero individual edges to let the row sit flush with sibling content on that side.
       - accessibilityValueWhenError: Optional already-localized string VoiceOver announces as the accessibility value when the row is in `.radio(.error)`. The red radio icon is the visual signal of the state; this string makes that signal non-visual too (WCAG 1.4.1). Frame it as a prompt rather than an error (e.g. "Select an IBAN to continue") — the state is a validation hint, not a failure.
       - onTap: Invoked when the user taps the row. Pass `nil` for a non-interactive row (common for `.informational`).
     */
    public init(title: String,
                content: String,
                spellsOutContent: Bool = false,
                footer: String? = nil,
                variant: Variant,
                giniColorScheme: GiniColorScheme,
                background: GiniColor? = nil,
                fonts: FontConfiguration = .init(),
                contentPadding: EdgeInsets = Self.defaultContentPadding,
                accessibilityValueWhenError: String? = nil,
                onTap: (() -> Void)? = nil) {
        self.title = title
        self.content = content
        self.spellsOutContent = spellsOutContent
        self.footer = footer
        self.variant = variant
        self.giniColorScheme = giniColorScheme
        self.background = background
        self.fonts = fonts
        self.contentPadding = contentPadding
        self.accessibilityValueWhenError = accessibilityValueWhenError
        self.onTap = onTap
    }

    public var body: some View {
        rowContent
            .animation(reduceMotion ? nil : .easeInOut(duration: Constants.animationDuration),
                       value: variant)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text(GiniOptionRowAccessibility.makeLabel(title: title,
                                                                          content: content,
                                                                          footer: footer,
                                                                          spellsOutContent: spellsOutContent)))
            .accessibilityAddTraits(variant.isSelected ? .isSelected : [])
            .accessibilityValue(errorStateAccessibilityValue)
    }

    /**
     Accessibility value applied to the row. When the row is in `.radio(.error)`
     and the caller supplied `accessibilityValueWhenError`, that string is read
     by VoiceOver so the state is non-visual. Otherwise an empty `Text` is
     applied, which VoiceOver silently ignores.
     */
    private var errorStateAccessibilityValue: Text {
        guard case .radio(.error) = variant,
              let value = accessibilityValueWhenError else {
            return Text(verbatim: "")
        }
        return Text(value)
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
                Self.stateIcon(for: state)
                    .font(.title3)
                    .frame(width: Constants.iconSize, height: Constants.iconSize)
            }
            textStack
            Spacer(minLength: 0)
        }
        .padding(contentPadding)
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
        giniColorScheme.text.label.swiftUIColor()
    }

    private var contentColor: Color {
        giniColorScheme.text.primary.swiftUIColor()
    }

    private var footerColor: Color {
        giniColorScheme.text.error.swiftUIColor()
    }

    private var titleFont: Font {
        fonts.title.map { Font(giniFont: $0) } ?? .caption
    }

    private var contentFont: Font {
        fonts.content.map { Font(giniFont: $0) } ?? .body
    }

    private var footerFont: Font {
        fonts.footer.map { Font(giniFont: $0) } ?? .footnote
    }

    /**
     Visual icon for the row's radio state. All three assets ship with
     "original" rendering intent in `GiniIcons.xcassets`, so the PDFs
     carry their own colors — no tinting or scheme input is needed.
     */
    static func stateIcon(for state: RadioButtonState) -> some View {
        Image(uiImage: icon(for: state).image ?? UIImage())
            .resizable()
    }

    private static func icon(for state: RadioButtonState) -> GiniIcons {
        switch state {
        case .unselected: .radioUnselected
        case .selected:   .radioSelected
        case .error:      .radioError
        }
    }

    enum Constants {
        static let horizontalSpacing: CGFloat = 12
        static let verticalSpacing: CGFloat = 6
        static let contentPadding: CGFloat = 12
        static let iconSize: CGFloat = 24
        static let cornerRadius: CGFloat = 12
        static let animationDuration: Double = 0.2
    }
}

/**
 Pure-string helpers for `GiniOptionRow`.
 */
enum GiniOptionRowAccessibility {

    /**
     Builds the combined VoiceOver label from the caller-provided (already
     localized) strings. When `spellsOutContent` is `true`, the content segment
     carries `accessibilitySpeechSpellsOutCharacters = true` so VoiceOver reads
     it character-by-character — intended for IBANs and similar fields where a
     one-character substitution is a security signal. Title and footer are
     always read as words.
     */
    static func makeLabel(title: String,
                          content: String,
                          footer: String?,
                          spellsOutContent: Bool = false) -> AttributedString {
        var contentSegment = AttributedString(content)
        if spellsOutContent {
            contentSegment.accessibilitySpeechSpellsOutCharacters = true
        }
        var label = AttributedString(title)
        label.append(AttributedString(", "))
        label.append(contentSegment)
        if let footer {
            label.append(AttributedString(", "))
            label.append(AttributedString(footer))
        }
        return label
    }
}

// MARK: - Variant convenience

extension GiniOptionRow.Variant {

    /** `true` for `.radio(.selected)` only. */
    var isSelected: Bool {
        if case .radio(.selected) = self { return true }
        return false
    }
}

#if DEBUG
// MARK: - Preview

#Preview("All variants — light") {
    GiniOptionRowPreviewCatalog()
        .padding()
}

#Preview("All variants — dark") {
    GiniOptionRowPreviewCatalog()
        .padding()
        .preferredColorScheme(.dark)
}

#Preview("Dynamic Type — AX3") {
    GiniOptionRowPreviewCatalog()
        .padding()
        .environment(\.sizeCategory, .accessibilityExtraLarge)
}
#endif
