//
//  GiniColorScheme.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniUtilites

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
            background: createBackgroundColorScheme(),
            actionSheet: createActionSheetColorScheme(),
            alert: createAlertColorScheme(),
            navigationBar: createNavigationBarColorScheme(),
            content: createContentColorScheme(),
            bottomBar: createBottomBarColorScheme(),
            container: createContainerColorScheme(),
            placeholder: createPlaceholderColorScheme(),
            text: createTextColorScheme(),
            icon: createIconColorScheme(),
            pageController: createPageControllerColorScheme(),
            error: createErrorColorScheme(),
            message: createMessageColorScheme(),
            badge: createBadgeColorScheme(),
            button: createButtonColorScheme(),
            buttonOutlined: createButtonOutlinedColorScheme(),
            textField: createTextFieldColorScheme(),
            toggle: createToggleColorScheme()
        )
    }

    private static func createBackgroundColorScheme() -> GiniColorScheme.Background {
        return GiniColorScheme.Background(
            primary: GiniColor(lightModeColor: .GiniBank.light2, darkModeColor: .GiniBank.dark2),
            secondary: GiniColor(lightModeColor: .GiniBank.light1, darkModeColor: .GiniBank.dark2)
        )
    }

    private static func createActionSheetColorScheme() -> GiniColorScheme.ActionSheet {
        return GiniColorScheme.ActionSheet(
            buttonBackground: GiniColor(lightModeColor: .GiniBank.light1.withAlphaComponent(0.72), darkModeColor: .GiniBank.dark5.withAlphaComponent(0.5)),
            cancelButtonBackground: GiniColor(lightModeColor: .GiniBank.light1, darkModeColor: .GiniBank.dark3)
        )
    }

    private static func createAlertColorScheme() -> GiniColorScheme.Alert {
        return GiniColorScheme.Alert(
            background: GiniColor(lightModeColor: .GiniBank.light2.withAlphaComponent(0.8), darkModeColor: .GiniBank.dark3.withAlphaComponent(0.8)),
            divider: GiniColor(lightModeColor: .GiniBank.light6, darkModeColor: .GiniBank.dark4.withAlphaComponent(0.65))
        )
    }

    private static func createNavigationBarColorScheme() -> GiniColorScheme.NavigationBar {
        return GiniColorScheme.NavigationBar(
            background: GiniColor(lightModeColor: .GiniBank.light2, darkModeColor: .GiniBank.dark2),
            action: GiniColor(lightModeColor: .GiniBank.accent1, darkModeColor: .GiniBank.accent1),
            navigation: GiniColor(lightModeColor: .GiniBank.accent1, darkModeColor: .GiniBank.accent1)
        )
    }

    private static func createContentColorScheme() -> GiniColorScheme.Content {
        return GiniColorScheme.Content(
            navigation: GiniColor(lightModeColor: .GiniBank.accent1, darkModeColor: .GiniBank.accent1),
            text: GiniColor(lightModeColor: .GiniBank.light1, darkModeColor: .GiniBank.light1)
        )
    }

    private static func createBottomBarColorScheme() -> GiniColorScheme.BottomBar {
        return GiniColorScheme.BottomBar(
            background: GiniColor(lightModeColor: .GiniBank.light1, darkModeColor: .GiniBank.dark3),
            border: GiniColor(lightModeColor: .GiniBank.light3, darkModeColor: .GiniBank.dark4)
        )
    }

    private static func createContainerColorScheme() -> GiniColorScheme.Container {
        return GiniColorScheme.Container(
            background: GiniColor(lightModeColor: .GiniBank.light1, darkModeColor: .GiniBank.dark3)
        )
    }

    private static func createPlaceholderColorScheme() -> GiniColorScheme.Placeholder {
        return GiniColorScheme.Placeholder(
            background: GiniColor(lightModeColor: .GiniBank.light2, darkModeColor: .GiniBank.dark4),
            tint: GiniColor(lightModeColor: .GiniBank.dark7, darkModeColor: .GiniBank.light6)
        )
    }

    private static func createTextColorScheme() -> GiniColorScheme.Text {
        return GiniColorScheme.Text(
            primary: GiniColor(lightModeColor: .GiniBank.dark1, darkModeColor: .GiniBank.light1),
            secondary: GiniColor(lightModeColor: .GiniBank.dark6, darkModeColor: .GiniBank.dark7),
            tertiary: GiniColor(lightModeColor: .GiniBank.dark7, darkModeColor: .GiniBank.dark7),
            accent: GiniColor(lightModeColor: .GiniBank.accent1, darkModeColor: .GiniBank.accent1),
            success: GiniColor(lightModeColor: .GiniBank.success3, darkModeColor: .GiniBank.success3),
            error: GiniColor(lightModeColor: .GiniBank.error3, darkModeColor: .GiniBank.error3)
        )
    }

    private static func createIconColorScheme() -> GiniColorScheme.Icon {
        return GiniColorScheme.Icon(
            primary: GiniColor(lightModeColor: .GiniBank.dark2, darkModeColor: .GiniBank.light1),
            secondary: GiniColor(lightModeColor: .GiniBank.light4, darkModeColor: .GiniBank.dark6)
        )
    }

    private static func createPageControllerColorScheme() -> GiniColorScheme.PageController {
        return GiniColorScheme.PageController(
            selected: GiniColor(lightModeColor: .GiniBank.dark1, darkModeColor: .GiniBank.light1),
            unselected: GiniColor(lightModeColor: .GiniBank.dark1.withAlphaComponent(0.3), darkModeColor: .GiniBank.light1.withAlphaComponent(0.3))
        )
    }

    private static func createErrorColorScheme() -> GiniColorScheme.Error {
        return GiniColorScheme.Error(
            background: GiniColor(lightModeColor: .GiniBank.error4, darkModeColor: .GiniBank.error4),
            icon: GiniColor(lightModeColor: .GiniBank.error3, darkModeColor: .GiniBank.error3)
        )
    }

    private static func createMessageColorScheme() -> GiniColorScheme.Message {
        return GiniColorScheme.Message(
            backgroundSuccess: GiniColor(lightModeColor: .GiniBank.success5, darkModeColor: .GiniBank.success5),
            contentSuccess: GiniColor(lightModeColor: .GiniBank.success2, darkModeColor: .GiniBank.success2),
            backgroundWarning: GiniColor(lightModeColor: .GiniBank.warning5, darkModeColor: .GiniBank.warning5),
            contentWarning: GiniColor(lightModeColor: .GiniBank.warning2, darkModeColor: .GiniBank.warning2),
            backgroundError: GiniColor(lightModeColor: .GiniBank.error5, darkModeColor: .GiniBank.error5),
            contentError: GiniColor(lightModeColor: .GiniBank.error2, darkModeColor: .GiniBank.error2)
        )
    }

    private static func createBadgeColorScheme() -> GiniColorScheme.Badge {
        return GiniColorScheme.Badge(
            background: GiniColor(lightModeColor: .GiniBank.success3, darkModeColor: .GiniBank.success3),
            content: GiniColor(lightModeColor: .GiniBank.light1, darkModeColor: .GiniBank.light1)
        )
    }

    private static func createButtonColorScheme() -> GiniColorScheme.Button {
        return GiniColorScheme.Button(
            background: GiniColor(lightModeColor: .GiniBank.accent1, darkModeColor: .GiniBank.accent1),
            backgroundLoading: GiniColor(lightModeColor: .GiniBank.accent1.withAlphaComponent(0.24), darkModeColor: .GiniBank.accent1.withAlphaComponent(0.24)),
            content: GiniColor(lightModeColor: .GiniBank.light1, darkModeColor: .GiniBank.light1)
        )
    }

    private static func createButtonOutlinedColorScheme() -> GiniColorScheme.ButtonOutlined {
        return GiniColorScheme.ButtonOutlined(
            background: GiniColor(lightModeColor: .GiniBank.light4, darkModeColor: .GiniBank.dark4),
            content: GiniColor(lightModeColor: .GiniBank.dark6, darkModeColor: .GiniBank.light6)
        )
    }

    private static func createTextFieldColorScheme() -> GiniColorScheme.TextField {
        return GiniColorScheme.TextField(
            background: GiniColor(lightModeColor: .GiniBank.light1, darkModeColor: .GiniBank.dark3),
            border: GiniColor(lightModeColor: .GiniBank.light3, darkModeColor: .GiniBank.dark4),
            focusedText: GiniColor(lightModeColor: .GiniBank.dark2, darkModeColor: .GiniBank.light1),
            unfocusedText: GiniColor(lightModeColor: .GiniBank.dark2, darkModeColor: .GiniBank.light1),
            disabledText: GiniColor(lightModeColor: .GiniBank.dark2, darkModeColor: .GiniBank.light1),
            errorText: GiniColor(lightModeColor: .GiniBank.error3, darkModeColor: .GiniBank.error3),
            labelFocused: GiniColor(lightModeColor: .GiniBank.dark6, darkModeColor: .GiniBank.dark6),
            labelUnfocused: GiniColor(lightModeColor: .GiniBank.dark6, darkModeColor: .GiniBank.dark6),
            labelDisabled: GiniColor(lightModeColor: .GiniBank.dark6, darkModeColor: .GiniBank.dark6),
            labelError: GiniColor(lightModeColor: .GiniBank.error3, darkModeColor: .GiniBank.error3),
            supportingFocused: GiniColor(lightModeColor: .GiniBank.dark6, darkModeColor: .GiniBank.dark6),
            supportingUnfocused: GiniColor(lightModeColor: .GiniBank.dark6, darkModeColor: .GiniBank.dark6),
            supportingDisabled: GiniColor(lightModeColor: .GiniBank.dark6, darkModeColor: .GiniBank.dark6),
            supportingError: GiniColor(lightModeColor: .GiniBank.error3, darkModeColor: .GiniBank.error3),
            trailingFocused: GiniColor(lightModeColor: .GiniBank.dark7, darkModeColor: .GiniBank.light6),
            cursorEnabled: GiniColor(lightModeColor: .GiniBank.accent1, darkModeColor: .GiniBank.accent1),
            cursorError: GiniColor(lightModeColor: .GiniBank.error3, darkModeColor: .GiniBank.error3)
        )
    }

    private static func createToggleColorScheme() -> GiniColorScheme.Toggle {
        return GiniColorScheme.Toggle(
            thumb: GiniColor(lightModeColor: .GiniBank.light1, darkModeColor: .GiniBank.light1),
            trackOn: GiniColor(lightModeColor: .GiniBank.accent1, darkModeColor: .GiniBank.accent1),
            trackOff: GiniColor(lightModeColor: .GiniBank.light4, darkModeColor: .GiniBank.dark4),
            disabledTrack: GiniColor(lightModeColor: .GiniBank.light4, darkModeColor: .GiniBank.dark4)
        )
    }
}
