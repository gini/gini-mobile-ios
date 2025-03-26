//
//  GiniColorScheme.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniUtilites

struct GiniColorScheme {
    struct Background {
        var primary: GiniUtilites.GiniColor
        var secondary: GiniUtilites.GiniColor
    }

    struct ActionSheet {
        var buttonBackground: GiniUtilites.GiniColor
        var cancelButtonBackground: GiniUtilites.GiniColor
    }

    struct Alert {
        var background: GiniUtilites.GiniColor
        var divider: GiniUtilites.GiniColor
    }

    struct NavigationBar {
        var background: GiniUtilites.GiniColor
        var action: GiniUtilites.GiniColor
        var navigation: GiniUtilites.GiniColor
    }

    struct Content {
        var navigation: GiniUtilites.GiniColor
        var text: GiniUtilites.GiniColor
    }

    struct BottomBar {
        var background: GiniUtilites.GiniColor
        var border: GiniUtilites.GiniColor
    }
    
    struct Container {
        var background: GiniUtilites.GiniColor
    }

    struct Placeholder {
        var background: GiniUtilites.GiniColor
        var tint: GiniUtilites.GiniColor
    }

    struct Text {
        var primary: GiniUtilites.GiniColor
        var secondary: GiniUtilites.GiniColor
        var tertiary: GiniUtilites.GiniColor
        var accent: GiniUtilites.GiniColor
        var success: GiniUtilites.GiniColor
        var error: GiniUtilites.GiniColor
    }

    struct Icon {
        var primary: GiniUtilites.GiniColor
        var secondary: GiniUtilites.GiniColor
    }

    struct PageController {
        var selected: GiniUtilites.GiniColor
        var unselected: GiniUtilites.GiniColor
    }

    struct Error {
        var background: GiniUtilites.GiniColor
        var icon: GiniUtilites.GiniColor
    }

    struct Message {
        var backgroundSuccess: GiniUtilites.GiniColor
        var contentSuccess: GiniUtilites.GiniColor
        var backgroundWarning: GiniUtilites.GiniColor
        var contentWarning: GiniUtilites.GiniColor
        var backgroundError: GiniUtilites.GiniColor
        var contentError: GiniUtilites.GiniColor
    }

    struct Badge {
        var background: GiniUtilites.GiniColor
        var content: GiniUtilites.GiniColor
    }

    struct Button {
        var background: GiniUtilites.GiniColor
        var backgroundLoading: GiniUtilites.GiniColor
        var content: GiniUtilites.GiniColor
    }

    struct ButtonOutlined {
        var background: GiniUtilites.GiniColor
        var content: GiniUtilites.GiniColor
    }

    struct TextField {
        var background: GiniUtilites.GiniColor
        var border: GiniUtilites.GiniColor
        var focusedText: GiniUtilites.GiniColor
        var unfocusedText: GiniUtilites.GiniColor
        var disabledText: GiniUtilites.GiniColor
        var errorText: GiniUtilites.GiniColor
        var labelFocused: GiniUtilites.GiniColor
        var labelUnfocused: GiniUtilites.GiniColor
        var labelDisabled: GiniUtilites.GiniColor
        var labelError: GiniUtilites.GiniColor
        var supportingFocused: GiniUtilites.GiniColor
        var supportingUnfocused: GiniUtilites.GiniColor
        var supportingDisabled: GiniUtilites.GiniColor
        var supportingError: GiniUtilites.GiniColor
        var trailingFocused: GiniUtilites.GiniColor
        var cursorEnabled: GiniUtilites.GiniColor
        var cursorError: GiniUtilites.GiniColor
    }

    struct Toggle {
        var thumb: GiniUtilites.GiniColor
        var trackOn: GiniUtilites.GiniColor
        var trackOff: GiniUtilites.GiniColor
        var disabledTrack: GiniUtilites.GiniColor
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
            primary: GiniUtilites.GiniColor(lightModeColor: .GiniBank.light2, darkModeColor: .GiniBank.dark2),
            secondary: GiniUtilites.GiniColor(lightModeColor: .GiniBank.light1, darkModeColor: .GiniBank.dark2)
        )
    }

    private static func createActionSheetColorScheme() -> GiniColorScheme.ActionSheet {
        return GiniColorScheme.ActionSheet(
            buttonBackground: GiniUtilites.GiniColor(lightModeColor: .GiniBank.light1.withAlphaComponent(0.72), darkModeColor: .GiniBank.dark5.withAlphaComponent(0.5)),
            cancelButtonBackground: GiniUtilites.GiniColor(lightModeColor: .GiniBank.light1, darkModeColor: .GiniBank.dark3)
        )
    }

    private static func createAlertColorScheme() -> GiniColorScheme.Alert {
        return GiniColorScheme.Alert(
            background: GiniUtilites.GiniColor(lightModeColor: .GiniBank.light2.withAlphaComponent(0.8), darkModeColor: .GiniBank.dark3.withAlphaComponent(0.8)),
            divider: GiniUtilites.GiniColor(lightModeColor: .GiniBank.light6, darkModeColor: .GiniBank.dark4.withAlphaComponent(0.65))
        )
    }

    private static func createNavigationBarColorScheme() -> GiniColorScheme.NavigationBar {
        return GiniColorScheme.NavigationBar(
            background: GiniUtilites.GiniColor(lightModeColor: .GiniBank.light2, darkModeColor: .GiniBank.dark2),
            action: GiniUtilites.GiniColor(lightModeColor: .GiniBank.accent1, darkModeColor: .GiniBank.accent1),
            navigation: GiniUtilites.GiniColor(lightModeColor: .GiniBank.accent1, darkModeColor: .GiniBank.accent1)
        )
    }

    private static func createContentColorScheme() -> GiniColorScheme.Content {
        return GiniColorScheme.Content(
            navigation: GiniUtilites.GiniColor(lightModeColor: .GiniBank.accent1, darkModeColor: .GiniBank.accent1),
            text: GiniUtilites.GiniColor(lightModeColor: .GiniBank.light1, darkModeColor: .GiniBank.light1)
        )
    }

    private static func createBottomBarColorScheme() -> GiniColorScheme.BottomBar {
        return GiniColorScheme.BottomBar(
            background: GiniUtilites.GiniColor(lightModeColor: .GiniBank.light1, darkModeColor: .GiniBank.dark3),
            border: GiniUtilites.GiniColor(lightModeColor: .GiniBank.light3, darkModeColor: .GiniBank.dark4)
        )
    }

    private static func createContainerColorScheme() -> GiniColorScheme.Container {
        return GiniColorScheme.Container(
            background: GiniUtilites.GiniColor(lightModeColor: .GiniBank.light1, darkModeColor: .GiniBank.dark3)
        )
    }

    private static func createPlaceholderColorScheme() -> GiniColorScheme.Placeholder {
        return GiniColorScheme.Placeholder(
            background: GiniUtilites.GiniColor(lightModeColor: .GiniBank.light2, darkModeColor: .GiniBank.dark4),
            tint: GiniUtilites.GiniColor(lightModeColor: .GiniBank.dark7, darkModeColor: .GiniBank.light6)
        )
    }

    private static func createTextColorScheme() -> GiniColorScheme.Text {
        return GiniColorScheme.Text(
            primary: GiniUtilites.GiniColor(lightModeColor: .GiniBank.dark1, darkModeColor: .GiniBank.light1),
            secondary: GiniUtilites.GiniColor(lightModeColor: .GiniBank.dark6, darkModeColor: .GiniBank.dark7),
            tertiary: GiniUtilites.GiniColor(lightModeColor: .GiniBank.dark7, darkModeColor: .GiniBank.dark7),
            accent: GiniUtilites.GiniColor(lightModeColor: .GiniBank.accent1, darkModeColor: .GiniBank.accent1),
            success: GiniUtilites.GiniColor(lightModeColor: .GiniBank.success3, darkModeColor: .GiniBank.success3),
            error: GiniUtilites.GiniColor(lightModeColor: .GiniBank.error3, darkModeColor: .GiniBank.error3)
        )
    }

    private static func createIconColorScheme() -> GiniColorScheme.Icon {
        return GiniColorScheme.Icon(
            primary: GiniUtilites.GiniColor(lightModeColor: .GiniBank.dark2, darkModeColor: .GiniBank.light1),
            secondary: GiniUtilites.GiniColor(lightModeColor: .GiniBank.light4, darkModeColor: .GiniBank.dark6)
        )
    }

    private static func createPageControllerColorScheme() -> GiniColorScheme.PageController {
        return GiniColorScheme.PageController(
            selected: GiniUtilites.GiniColor(lightModeColor: .GiniBank.dark1, darkModeColor: .GiniBank.light1),
            unselected: GiniUtilites.GiniColor(lightModeColor: .GiniBank.dark1.withAlphaComponent(0.3), darkModeColor: .GiniBank.light1.withAlphaComponent(0.3))
        )
    }

    private static func createErrorColorScheme() -> GiniColorScheme.Error {
        return GiniColorScheme.Error(
            background: GiniUtilites.GiniColor(lightModeColor: .GiniBank.error4, darkModeColor: .GiniBank.error4),
            icon: GiniUtilites.GiniColor(lightModeColor: .GiniBank.error3, darkModeColor: .GiniBank.error3)
        )
    }

    private static func createMessageColorScheme() -> GiniColorScheme.Message {
        return GiniColorScheme.Message(
            backgroundSuccess: GiniUtilites.GiniColor(lightModeColor: .GiniBank.success5, darkModeColor: .GiniBank.success5),
            contentSuccess: GiniUtilites.GiniColor(lightModeColor: .GiniBank.success2, darkModeColor: .GiniBank.success2),
            backgroundWarning: GiniUtilites.GiniColor(lightModeColor: .GiniBank.warning5, darkModeColor: .GiniBank.warning5),
            contentWarning: GiniUtilites.GiniColor(lightModeColor: .GiniBank.warning2, darkModeColor: .GiniBank.warning2),
            backgroundError: GiniUtilites.GiniColor(lightModeColor: .GiniBank.error5, darkModeColor: .GiniBank.error5),
            contentError: GiniUtilites.GiniColor(lightModeColor: .GiniBank.error2, darkModeColor: .GiniBank.error2)
        )
    }

    private static func createBadgeColorScheme() -> GiniColorScheme.Badge {
        return GiniColorScheme.Badge(
            background: GiniUtilites.GiniColor(lightModeColor: .GiniBank.success3, darkModeColor: .GiniBank.success3),
            content: GiniUtilites.GiniColor(lightModeColor: .GiniBank.light1, darkModeColor: .GiniBank.light1)
        )
    }

    private static func createButtonColorScheme() -> GiniColorScheme.Button {
        return GiniColorScheme.Button(
            background: GiniUtilites.GiniColor(lightModeColor: .GiniBank.accent1, darkModeColor: .GiniBank.accent1),
            backgroundLoading: GiniUtilites.GiniColor(lightModeColor: .GiniBank.accent1.withAlphaComponent(0.24), darkModeColor: .GiniBank.accent1.withAlphaComponent(0.24)),
            content: GiniUtilites.GiniColor(lightModeColor: .GiniBank.light1, darkModeColor: .GiniBank.light1)
        )
    }

    private static func createButtonOutlinedColorScheme() -> GiniColorScheme.ButtonOutlined {
        return GiniColorScheme.ButtonOutlined(
            background: GiniUtilites.GiniColor(lightModeColor: .GiniBank.light4, darkModeColor: .GiniBank.dark4),
            content: GiniUtilites.GiniColor(lightModeColor: .GiniBank.dark6, darkModeColor: .GiniBank.light6)
        )
    }

    private static func createTextFieldColorScheme() -> GiniColorScheme.TextField {
        return GiniColorScheme.TextField(
            background: GiniUtilites.GiniColor(lightModeColor: .GiniBank.light1, darkModeColor: .GiniBank.dark3),
            border: GiniUtilites.GiniColor(lightModeColor: .GiniBank.light3, darkModeColor: .GiniBank.dark4),
            focusedText: GiniUtilites.GiniColor(lightModeColor: .GiniBank.dark2, darkModeColor: .GiniBank.light1),
            unfocusedText: GiniUtilites.GiniColor(lightModeColor: .GiniBank.dark2, darkModeColor: .GiniBank.light1),
            disabledText: GiniUtilites.GiniColor(lightModeColor: .GiniBank.dark2, darkModeColor: .GiniBank.light1),
            errorText: GiniUtilites.GiniColor(lightModeColor: .GiniBank.error3, darkModeColor: .GiniBank.error3),
            labelFocused: GiniUtilites.GiniColor(lightModeColor: .GiniBank.dark6, darkModeColor: .GiniBank.dark6),
            labelUnfocused: GiniUtilites.GiniColor(lightModeColor: .GiniBank.dark6, darkModeColor: .GiniBank.dark6),
            labelDisabled: GiniUtilites.GiniColor(lightModeColor: .GiniBank.dark6, darkModeColor: .GiniBank.dark6),
            labelError: GiniUtilites.GiniColor(lightModeColor: .GiniBank.error3, darkModeColor: .GiniBank.error3),
            supportingFocused: GiniUtilites.GiniColor(lightModeColor: .GiniBank.dark6, darkModeColor: .GiniBank.dark6),
            supportingUnfocused: GiniUtilites.GiniColor(lightModeColor: .GiniBank.dark6, darkModeColor: .GiniBank.dark6),
            supportingDisabled: GiniUtilites.GiniColor(lightModeColor: .GiniBank.dark6, darkModeColor: .GiniBank.dark6),
            supportingError: GiniUtilites.GiniColor(lightModeColor: .GiniBank.error3, darkModeColor: .GiniBank.error3),
            trailingFocused: GiniUtilites.GiniColor(lightModeColor: .GiniBank.dark7, darkModeColor: .GiniBank.light6),
            cursorEnabled: GiniUtilites.GiniColor(lightModeColor: .GiniBank.accent1, darkModeColor: .GiniBank.accent1),
            cursorError: GiniUtilites.GiniColor(lightModeColor: .GiniBank.error3, darkModeColor: .GiniBank.error3)
        )
    }

    private static func createToggleColorScheme() -> GiniColorScheme.Toggle {
        return GiniColorScheme.Toggle(
            thumb: GiniUtilites.GiniColor(lightModeColor: .GiniBank.light1, darkModeColor: .GiniBank.light1),
            trackOn: GiniUtilites.GiniColor(lightModeColor: .GiniBank.accent1, darkModeColor: .GiniBank.accent1),
            trackOff: GiniUtilites.GiniColor(lightModeColor: .GiniBank.light4, darkModeColor: .GiniBank.dark4),
            disabledTrack: GiniUtilites.GiniColor(lightModeColor: .GiniBank.light4, darkModeColor: .GiniBank.dark4)
        )
    }
}
