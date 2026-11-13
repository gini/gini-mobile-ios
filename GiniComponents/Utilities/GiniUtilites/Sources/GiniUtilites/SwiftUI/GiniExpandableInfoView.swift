//
//  GiniExpandableInfoView.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI
import UIKit

private enum Constants {
    static let iconSize: CGFloat = 24
    static let headerSpacing: CGFloat = 12
    static let verticalSpacing: CGFloat = 12
    static let contentPadding: CGFloat = 16
    static let animationDuration: Double = 0.2
}

/**
 A card that starts compact and expands to reveal caller-supplied detail
 on tap. The header is a `Button` showing the view model's icon and title
 with a trailing chevron; activating it toggles the externally-owned
 `isExpanded` binding. Designed to drop into a vertical `ScrollView`,
 announce state changes to VoiceOver, scale with Dynamic Type, honor
 Reduce Motion, and remain reachable through Full Keyboard Access and
 Switch Control via the real `Button`.

 State ownership is always external — the parent view owns a
 `@State private var isExpanded: Bool`, mirroring SwiftUI's own
 `DisclosureGroup(isExpanded:)` shape. Only the header toggles the card;
 the expanded content is plain, individually-navigable SwiftUI content.
 */
public struct GiniExpandableInfoView<ExpandedContent: View>: View {

    private let viewModel: GiniExpandableInfoViewModel
    private let expandedContent: () -> ExpandedContent

    @Binding private var isExpanded: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /**
     Creates the expandable info card.

     - Parameters:
       - viewModel: Display configuration (icon, title, color scheme, font, a11y values).
       - isExpanded: External binding that owns the expanded/collapsed state.
       - expandedContent: View builder that produces the content revealed when the card is expanded.
     */
    public init(viewModel: GiniExpandableInfoViewModel,
                isExpanded: Binding<Bool>,
                @ViewBuilder expandedContent: @escaping () -> ExpandedContent) {
        self.viewModel = viewModel
        self._isExpanded = isExpanded
        self.expandedContent = expandedContent
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Constants.verticalSpacing) {
            headerButton
            if isExpanded {
                expandedContent()
                    // Align the expanded content's leading edge with the title's,
                    // not the icon's — matches the Figma disclosure pattern.
                    .padding(.leading, Constants.iconSize + Constants.headerSpacing)
                    .transition(.opacity)
            }
        }
        .padding(Constants.contentPadding)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(viewModel.colorScheme.container.background.swiftUIColor())
        .animation(reduceMotion ? nil : .easeInOut(duration: Constants.animationDuration),
                   value: isExpanded)
        .accessibilityElement(children: .contain)
    }

    private var headerButton: some View {
        Button(action: { isExpanded.toggle() }) {
            HStack(spacing: Constants.headerSpacing) {
                Image(uiImage: viewModel.icon)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.iconSize, height: Constants.iconSize)
                    .accessibility(hidden: true)

                Text(viewModel.title)
                    .font(Font(giniFont: viewModel.titleFont))
                    .foregroundStyle(viewModel.colorScheme.text.primary.swiftUIColor())
                    .frame(maxWidth: .infinity, alignment: .leading)

                chevron
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(viewModel.title))
        .accessibilityValue(Text(isExpanded
                                 ? viewModel.expandedAccessibilityValue
                                 : viewModel.collapsedAccessibilityValue))
    }

    private var chevron: some View {
        // Reduce Motion: swap the glyph instead of rotating, so the control
        // conveys state without any interpolated motion (WCAG 2.3.3).
        Image(systemName: chevronSymbolName)
            .imageScale(.medium)
            .foregroundStyle(viewModel.colorScheme.content.navigation.swiftUIColor())
            .rotationEffect(.degrees(chevronRotationDegrees))
            .accessibility(hidden: true)
    }

    private var chevronSymbolName: String {
        guard reduceMotion else { return "chevron.down" }
        return isExpanded ? "chevron.up" : "chevron.down"
    }

    private var chevronRotationDegrees: Double {
        guard !reduceMotion else { return 0 }
        return isExpanded ? 180 : 0
    }
}
