//
//  GiniExpandableInfoViewModel.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import UIKit

/**
 Immutable display configuration for `GiniExpandableInfoView`.

 Carries the caller-owned display inputs — icon, title, color scheme,
 title font — plus the two already-localized accessibility values
 VoiceOver reads for the expanded/collapsed states. State ownership
 (`isExpanded`) stays external on the parent view via `@Binding`.
 */
public struct GiniExpandableInfoViewModel {

    /**
     Image rendered on the leading edge of the header row.
     Template-tinted from `iconTint` so a single PDF asset can flip color
     between light and dark mode via the scheme's `GiniColor` pair — same
     mechanism as the chevron.
     */
    public let icon: UIImage

    /**
     Icon tint color. Supplied directly by the caller so each screen can
     match the per-mode color from its Figma spec (e.g. the fraud card's
     `#006ECF` light / `#007FEE` dark Gini blue pair) without inventing a
     new scheme token for every use case.
     */
    public let iconTint: GiniColor

    /**
     Chevron glyph rendered on the trailing edge of the header row.
     Template-tinted from `colorScheme.text.primary` so it matches the
     title color and flips correctly between light and dark mode via the
     scheme's `GiniColor` pair.
     */
    public let chevronIcon: UIImage

    /** Title shown next to the icon in the header row. */
    public let title: String

    /**
     Card surface color. Supplied directly by the caller so each screen
     can match its own Figma spec (e.g. pale blue for the fraud warning,
     neutral grey for info variants) without inventing a new scheme
     token for every use case.
     */
    public let backgroundColor: GiniColor

    /** Color scheme the view resolves its title and chevron tint from. */
    public let colorScheme: GiniColorScheme

    /** Title font; bridged into SwiftUI via `Font(giniFont:)` so Dynamic Type propagates. */
    public let titleFont: UIFont

    /** Already-localized string VoiceOver announces as the accessibility value when the card is expanded. */
    public let expandedAccessibilityValue: String

    /** Already-localized string VoiceOver announces as the accessibility value when the card is collapsed. */
    public let collapsedAccessibilityValue: String

    /**
     Creates a configuration bundle for `GiniExpandableInfoView`.

     - Parameters:
       - icon: Image rendered on the leading edge of the header row.
       - iconTint: Icon tint color (per-screen Figma spec).
       - chevronIcon: Chevron glyph rendered on the trailing edge; template-tinted from the color scheme.
       - title: Title shown next to the icon in the header row.
       - backgroundColor: Card surface color (per-screen Figma spec).
       - colorScheme: Color scheme the view resolves its tokens from.
       - titleFont: UIKit font used for the title; bridged into SwiftUI via `Font(giniFont:)`.
       - expandedAccessibilityValue: Already-localized VoiceOver value for the expanded state.
       - collapsedAccessibilityValue: Already-localized VoiceOver value for the collapsed state.
     */
    public init(icon: UIImage,
                iconTint: GiniColor,
                chevronIcon: UIImage,
                title: String,
                backgroundColor: GiniColor,
                colorScheme: GiniColorScheme,
                titleFont: UIFont,
                expandedAccessibilityValue: String,
                collapsedAccessibilityValue: String) {
        self.icon = icon
        self.iconTint = iconTint
        self.chevronIcon = chevronIcon
        self.title = title
        self.backgroundColor = backgroundColor
        self.colorScheme = colorScheme
        self.titleFont = titleFont
        self.expandedAccessibilityValue = expandedAccessibilityValue
        self.collapsedAccessibilityValue = collapsedAccessibilityValue
    }
}
