//
//  GiniColorScheme.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

struct GiniColorScheme {
    struct Background {
        var primary: GiniColor
        var secondary: GiniColor
    }

    struct ActionSheet {
        var buttonBackground: GiniColor
        var cancelButtonBackground: GiniColor
    }

    struct Alert {
        var background: GiniColor
        var divider: GiniColor
    }

    struct NavigationBar {
        var background: GiniColor
        var action: GiniColor
        var navigation: GiniColor
    }

    struct Content {
        var navigation: GiniColor
        var text: GiniColor
    }

    struct BottomBar {
        var background: GiniColor
        var border: GiniColor
    }
    
    struct Container {
        var background: GiniColor
    }

    struct Placeholder {
        var background: GiniColor
        var tint: GiniColor
    }

    struct Text {
        var primary: GiniColor
        var secondary: GiniColor
        var tertiary: GiniColor
        var accent: GiniColor
        var success: GiniColor
        var error: GiniColor
    }

    struct Icon {
        var primary: GiniColor
        var secondary: GiniColor
    }

    struct PageController {
        var selected: GiniColor
        var unselected: GiniColor
    }

    struct Error {
        var background: GiniColor
        var icon: GiniColor
    }

    struct Message {
        var backgroundSuccess: GiniColor
        var contentSuccess: GiniColor
        var backgroundWarning: GiniColor
        var contentWarning: GiniColor
        var backgroundError: GiniColor
        var contentError: GiniColor
    }

    struct Badge {
        var background: GiniColor
        var content: GiniColor
    }

    struct Button {
        var background: GiniColor
        var backgroundLoading: GiniColor
        var content: GiniColor
    }

    struct ButtonOutlined {
        var background: GiniColor
        var content: GiniColor
    }

    struct TextField {
        var background: GiniColor
        var border: GiniColor
        var focusedText: GiniColor
        var unfocusedText: GiniColor
        var disabledText: GiniColor
        var errorText: GiniColor
        var labelFocused: GiniColor
        var labelUnfocused: GiniColor
        var labelDisabled: GiniColor
        var labelError: GiniColor
        var supportingFocused: GiniColor
        var supportingUnfocused: GiniColor
        var supportingDisabled: GiniColor
        var supportingError: GiniColor
        var trailingFocused: GiniColor
        var cursorEnabled: GiniColor
        var cursorError: GiniColor
    }

    struct Toggle {
        var thumb: GiniColor
        var trackOn: GiniColor
        var trackOff: GiniColor
        var disabledTrack: GiniColor
    }

    var background: Background
    var actionSheet: ActionSheet
    var alert: Alert
    var navigationBar: NavigationBar
    var content: Content
    var bottomBar: BottomBar
    var container: Container
    var placeholder: Placeholder
    var text: Text
    var icon: Icon
    var pageController: PageController
    var error: Error
    var message: Message
    var badge: Badge
    var button: Button
    var buttonOutlined: ButtonOutlined
    var textField: TextField
    var toggle: Toggle
}

extension UIColor {
    static func giniColorScheme() -> GiniColorScheme {
        return GiniColorScheme(
            background: GiniColorScheme.Background(
                primary: GiniColor(light: .GiniBank.light2, dark: .GiniBank.dark2),
                secondary: GiniColor(light: .GiniBank.light1, dark: .GiniBank.dark2)
            ),
            actionSheet: GiniColorScheme.ActionSheet(
                buttonBackground: GiniColor(
                    light: .GiniBank.light1.withAlphaComponent(0.72),
                    dark: .GiniBank.dark5.withAlphaComponent(0.5)),
                cancelButtonBackground: GiniColor(light: .GiniBank.light1, dark: .GiniBank.dark3)
            ),
            alert: GiniColorScheme.Alert(
                background: GiniColor(light: .GiniBank.light2.withAlphaComponent(0.8),
                              dark: .GiniBank.dark3.withAlphaComponent(0.8)),
                divider: GiniColor(light: .GiniBank.light6,
                                   dark: .GiniBank.dark4.withAlphaComponent(0.65))
            ),
            navigationBar: GiniColorScheme.NavigationBar(
                background: GiniColor(light: .GiniBank.light2, dark: .GiniBank.dark2),
                action: GiniColor(light: .GiniBank.accent1, dark: .GiniBank.accent1),
                navigation: GiniColor(light: .GiniBank.accent1, dark: .GiniBank.accent1)
            ),
            content: GiniColorScheme.Content(
                navigation: GiniColor(light: .GiniBank.accent1, dark: .GiniBank.accent1),
                text: GiniColor(light: .GiniBank.light1, dark: .GiniBank.light1)
            ),
            bottomBar: GiniColorScheme.BottomBar(
                background: GiniColor(light: .GiniBank.light1, dark: .GiniBank.dark3),
                border: GiniColor(light: .GiniBank.light3, dark: .GiniBank.dark4)
            ),
            container: GiniColorScheme.Container(
                background: GiniColor(light: .GiniBank.light1, dark: .GiniBank.dark3)
            ),
            placeholder: GiniColorScheme.Placeholder(
                background: GiniColor(light: .GiniBank.light2, dark: .GiniBank.dark4),
                tint: GiniColor(light: .GiniBank.dark7, dark: .GiniBank.light6)
            ),
            text: GiniColorScheme.Text(
                primary: GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1),
                secondary: GiniColor(light: .GiniBank.dark6, dark: .GiniBank.dark7),
                tertiary: GiniColor(light: .GiniBank.dark7, dark: .GiniBank.dark7),
                accent: GiniColor(light: .GiniBank.accent1, dark: .GiniBank.accent1),
                success: GiniColor(light: .GiniBank.success3, dark: .GiniBank.success3),
                error: GiniColor(light: .GiniBank.error3, dark: .GiniBank.error3)
            ),
            icon: GiniColorScheme.Icon(
                primary: GiniColor(light: .GiniBank.dark2, dark: .GiniBank.light1),
                secondary: GiniColor(light: .GiniBank.light4, dark: .GiniBank.dark6)
            ),
            pageController: GiniColorScheme.PageController(
                selected: GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1),
                unselected: GiniColor(light: .GiniBank.dark1.withAlphaComponent(0.3),
                                      dark: .GiniBank.light1.withAlphaComponent(0.3))
            ),
            error: GiniColorScheme.Error(
                background: GiniColor(light: .GiniBank.error4, dark: .GiniBank.error4),
                icon: GiniColor(light: .GiniBank.error3, dark: .GiniBank.error3)
            ),
            message: GiniColorScheme.Message(
                backgroundSuccess: GiniColor(light: .GiniBank.success5, dark: .GiniBank.success5),
                contentSuccess: GiniColor(light: .GiniBank.success2, dark: .GiniBank.success2),
                backgroundWarning: GiniColor(light: .GiniBank.warning5, dark: .GiniBank.warning5),
                contentWarning: GiniColor(light: .GiniBank.warning2, dark: .GiniBank.warning2),
                backgroundError: GiniColor(light: .GiniBank.error5, dark: .GiniBank.error5),
                contentError: GiniColor(light: .GiniBank.error2, dark: .GiniBank.error2)
            ),
            badge: GiniColorScheme.Badge(
                background: GiniColor(light: .GiniBank.success3, dark: .GiniBank.success3),
                content: GiniColor(light: .GiniBank.light1, dark: .GiniBank.light1)
            ),
            button: GiniColorScheme.Button(
                background: GiniColor(light: .GiniBank.accent1, dark: .GiniBank.accent1),
                backgroundLoading: GiniColor(light: .GiniBank.accent1.withAlphaComponent(0.24),
                                     dark: .GiniBank.accent1.withAlphaComponent(0.24)),
                content: GiniColor(light: .GiniBank.light1, dark: .GiniBank.light1)
            ),
            buttonOutlined: GiniColorScheme.ButtonOutlined(
                background: GiniColor(light: .GiniBank.light4, dark: .GiniBank.dark4),
                content: GiniColor(light: .GiniBank.dark6, dark: .GiniBank.light6)
            ),
            textField: GiniColorScheme.TextField(
                background: GiniColor(light: .GiniBank.light1, dark: .GiniBank.dark3),
                border: GiniColor(light: .GiniBank.light3, dark: .GiniBank.dark4),
                focusedText: GiniColor(light: .GiniBank.dark2, dark: .GiniBank.light1),
                unfocusedText: GiniColor(light: .GiniBank.dark2, dark: .GiniBank.light1),
                disabledText: GiniColor(light: .GiniBank.dark2, dark: .GiniBank.light1),
                errorText: GiniColor(light: .GiniBank.error3, dark: .GiniBank.error3),
                labelFocused: GiniColor(light: .GiniBank.dark6, dark: .GiniBank.dark6),
                labelUnfocused: GiniColor(light: .GiniBank.dark6, dark: .GiniBank.dark6),
                labelDisabled: GiniColor(light: .GiniBank.dark6, dark: .GiniBank.dark6),
                labelError: GiniColor(light: .GiniBank.error3, dark: .GiniBank.error3),
                supportingFocused: GiniColor(light: .GiniBank.dark6, dark: .GiniBank.dark6),
                supportingUnfocused: GiniColor(light: .GiniBank.dark6, dark: .GiniBank.dark6),
                supportingDisabled: GiniColor(light: .GiniBank.dark6, dark: .GiniBank.dark6),
                supportingError: GiniColor(light: .GiniBank.error3, dark: .GiniBank.error3),
                trailingFocused: GiniColor(light: .GiniBank.dark7, dark: .GiniBank.light6),
                cursorEnabled: GiniColor(light: .GiniBank.accent1, dark: .GiniBank.accent1),
                cursorError: GiniColor(light: .GiniBank.error3, dark: .GiniBank.error3)
            ),
            toggle: GiniColorScheme.Toggle(
                thumb: GiniColor(light: .GiniBank.light1, dark: .GiniBank.light1),
                trackOn: GiniColor(light: .GiniBank.accent1, dark: .GiniBank.accent1),
                trackOff: GiniColor(light: .GiniBank.light4, dark: .GiniBank.dark4),
                disabledTrack: GiniColor(light: .GiniBank.light4, dark: .GiniBank.dark4)
            )
        )
    }
}
