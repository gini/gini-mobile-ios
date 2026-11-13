//
//  GiniExpandableInfoViewModelTests.swift
//  GiniUtilitesTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import UIKit
@testable import GiniUtilites

@Suite("GiniExpandableInfoViewModel — init round-trips its inputs")
@MainActor
struct GiniExpandableInfoViewModelTests {

    /**
     Confirms the memberwise init stores every parameter into the matching
     `let` property. Catches a regression where a parameter is accidentally
     dropped or wired to the wrong field — the component's entire display
     surface flows through these six values.
     */
    @Test
    func init_storesAllProperties() {
        let icon = UIImage()
        let title = "Fraud warning"
        let titleFont = UIFont.systemFont(ofSize: 17)
        let expandedValue = "Expanded"
        let collapsedValue = "Collapsed"
        let sentinel = GiniColor(lightModeColor: .red, darkModeColor: .blue)
        let scheme = Self.makeColorScheme(withSentinel: sentinel)

        let viewModel = GiniExpandableInfoViewModel(icon: icon,
                                                    title: title,
                                                    colorScheme: scheme,
                                                    titleFont: titleFont,
                                                    expandedAccessibilityValue: expandedValue,
                                                    collapsedAccessibilityValue: collapsedValue)

        #expect(viewModel.icon === icon)
        #expect(viewModel.title == title)
        #expect(viewModel.titleFont === titleFont)
        #expect(viewModel.expandedAccessibilityValue == expandedValue)
        #expect(viewModel.collapsedAccessibilityValue == collapsedValue)
        #expect(viewModel.colorScheme.content.navigation === sentinel)
    }

    /**
     Builds a `GiniColorScheme` whose nested tokens all point at the same
     sentinel `GiniColor` so the round-trip test can verify the scheme
     survived the init by checking a single token's reference identity.
     */
    private static func makeColorScheme(withSentinel sentinel: GiniColor) -> GiniColorScheme {
        GiniColorScheme(background: .init(primary: sentinel,
                                          secondary: sentinel),
                        actionSheet: .init(buttonBackground: sentinel,
                                           cancelButtonBackground: sentinel),
                        alert: .init(background: sentinel,
                                     divider: sentinel),
                        navigationBar: .init(background: sentinel,
                                             action: sentinel,
                                             navigation: sentinel),
                        content: .init(navigation: sentinel,
                                       text: sentinel),
                        bottomBar: .init(background: sentinel,
                                         border: sentinel),
                        container: .init(background: sentinel),
                        placeholder: .init(background: sentinel,
                                           tint: sentinel),
                        text: .init(primary: sentinel,
                                    secondary: sentinel,
                                    tertiary: sentinel,
                                    accent: sentinel,
                                    success: sentinel,
                                    error: sentinel),
                        icon: .init(primary: sentinel,
                                    secondary: sentinel),
                        pageController: .init(selected: sentinel,
                                              unselected: sentinel),
                        error: .init(background: sentinel,
                                     icon: sentinel),
                        message: .init(backgroundSuccess: sentinel,
                                       contentSuccess: sentinel,
                                       backgroundWarning: sentinel,
                                       contentWarning: sentinel,
                                       backgroundError: sentinel,
                                       contentError: sentinel),
                        badge: .init(background: sentinel,
                                     content: sentinel),
                        button: .init(background: sentinel,
                                      backgroundLoading: sentinel,
                                      content: sentinel),
                        buttonOutlined: .init(background: sentinel,
                                              content: sentinel),
                        textField: .init(background: sentinel,
                                         border: sentinel,
                                         focusedText: sentinel,
                                         unfocusedText: sentinel,
                                         disabledText: sentinel,
                                         errorText: sentinel,
                                         labelFocused: sentinel,
                                         labelUnfocused: sentinel,
                                         labelDisabled: sentinel,
                                         labelError: sentinel,
                                         supportingFocused: sentinel,
                                         supportingUnfocused: sentinel,
                                         supportingDisabled: sentinel,
                                         supportingError: sentinel,
                                         trailingFocused: sentinel,
                                         cursorEnabled: sentinel,
                                         cursorError: sentinel),
                        toggle: .init(thumb: sentinel,
                                      trackOn: sentinel,
                                      trackOff: sentinel,
                                      disabledTrack: sentinel),
                        inputAccessoryView: .init(background: sentinel,
                                                  tintColor: sentinel,
                                                  disabledTintColor: sentinel))
    }
}
