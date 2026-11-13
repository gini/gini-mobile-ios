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

    /** Image rendered on the leading edge of the header row. */
    public let icon: UIImage

    /** Title shown next to the icon in the header row. */
    public let title: String

    /** Color scheme the view resolves its background, title, and chevron tint from. */
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
       - title: Title shown next to the icon in the header row.
       - colorScheme: Color scheme the view resolves its tokens from.
       - titleFont: UIKit font used for the title; bridged into SwiftUI via `Font(giniFont:)`.
       - expandedAccessibilityValue: Already-localized VoiceOver value for the expanded state.
       - collapsedAccessibilityValue: Already-localized VoiceOver value for the collapsed state.
     */
    public init(icon: UIImage,
                title: String,
                colorScheme: GiniColorScheme,
                titleFont: UIFont,
                expandedAccessibilityValue: String,
                collapsedAccessibilityValue: String) {
        self.icon = icon
        self.title = title
        self.colorScheme = colorScheme
        self.titleFont = titleFont
        self.expandedAccessibilityValue = expandedAccessibilityValue
        self.collapsedAccessibilityValue = collapsedAccessibilityValue
    }
}
