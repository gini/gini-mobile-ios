//
//  GiniCaptureColorScheme.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit
import GiniUtilites

extension UIColor {
    static func giniCaptureColorScheme() -> GiniColorScheme {
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
            primary: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.light2, darkModeColor: .GiniCapture.dark2),
            secondary: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.light1, darkModeColor: .GiniCapture.dark2)
        )
    }

    private static func createActionSheetColorScheme() -> GiniColorScheme.ActionSheet {
        return GiniColorScheme.ActionSheet(
            buttonBackground: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.light1.withAlphaComponent(0.72), darkModeColor: .GiniCapture.dark5.withAlphaComponent(0.5)),
            cancelButtonBackground: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.light1, darkModeColor: .GiniCapture.dark3)
        )
    }

    private static func createAlertColorScheme() -> GiniColorScheme.Alert {
        return GiniColorScheme.Alert(
            background: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.light2.withAlphaComponent(0.8), darkModeColor: .GiniCapture.dark3.withAlphaComponent(0.8)),
            divider: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.light6, darkModeColor: .GiniCapture.dark4.withAlphaComponent(0.65))
        )
    }

    private static func createNavigationBarColorScheme() -> GiniColorScheme.NavigationBar {
        return GiniColorScheme.NavigationBar(
            background: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.light2, darkModeColor: .GiniCapture.dark2),
            action: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.accent1, darkModeColor: .GiniCapture.accent1),
            navigation: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.accent1, darkModeColor: .GiniCapture.accent1)
        )
    }

    private static func createContentColorScheme() -> GiniColorScheme.Content {
        return GiniColorScheme.Content(
            navigation: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.accent1, darkModeColor: .GiniCapture.accent1),
            text: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.light1, darkModeColor: .GiniCapture.light1)
        )
    }

    private static func createBottomBarColorScheme() -> GiniColorScheme.BottomBar {
        return GiniColorScheme.BottomBar(
            background: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.light1, darkModeColor: .GiniCapture.dark3),
            border: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.light3, darkModeColor: .GiniCapture.dark4)
        )
    }

    private static func createContainerColorScheme() -> GiniColorScheme.Container {
        return GiniColorScheme.Container(
            background: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.light1, darkModeColor: .GiniCapture.dark3)
        )
    }

    private static func createPlaceholderColorScheme() -> GiniColorScheme.Placeholder {
        return GiniColorScheme.Placeholder(
            background: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.light2, darkModeColor: .GiniCapture.dark4),
            tint: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.dark7, darkModeColor: .GiniCapture.light6)
        )
    }

    private static func createTextColorScheme() -> GiniColorScheme.Text {
        return GiniColorScheme.Text(
            primary: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.dark1, darkModeColor: .GiniCapture.light1),
            secondary: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.dark6, darkModeColor: .GiniCapture.dark7),
            tertiary: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.dark7, darkModeColor: .GiniCapture.dark7),
            accent: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.accent1, darkModeColor: .GiniCapture.accent1),
            success: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.success3, darkModeColor: .GiniCapture.success3),
            error: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.error3, darkModeColor: .GiniCapture.error3)
        )
    }

    private static func createIconColorScheme() -> GiniColorScheme.Icon {
        return GiniColorScheme.Icon(
            primary: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.dark2, darkModeColor: .GiniCapture.light1),
            secondary: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.light4, darkModeColor: .GiniCapture.dark6)
        )
    }

    private static func createPageControllerColorScheme() -> GiniColorScheme.PageController {
        return GiniColorScheme.PageController(
            selected: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.dark1, darkModeColor: .GiniCapture.light1),
            unselected: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.dark1.withAlphaComponent(0.3), darkModeColor: .GiniCapture.light1.withAlphaComponent(0.3))
        )
    }

    private static func createErrorColorScheme() -> GiniColorScheme.Error {
        return GiniColorScheme.Error(
            background: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.error4, darkModeColor: .GiniCapture.error4),
            icon: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.error3, darkModeColor: .GiniCapture.error3)
        )
    }

    private static func createMessageColorScheme() -> GiniColorScheme.Message {
        return GiniColorScheme.Message(
            backgroundSuccess: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.success5, darkModeColor: .GiniCapture.success5),
            contentSuccess: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.success2, darkModeColor: .GiniCapture.success2),
            backgroundWarning: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.warning5, darkModeColor: .GiniCapture.warning5),
            contentWarning: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.warning2, darkModeColor: .GiniCapture.warning2),
            backgroundError: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.error5, darkModeColor: .GiniCapture.error5),
            contentError: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.error2, darkModeColor: .GiniCapture.error2)
        )
    }

    private static func createBadgeColorScheme() -> GiniColorScheme.Badge {
        return GiniColorScheme.Badge(
            background: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.success3, darkModeColor: .GiniCapture.success3),
            content: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.light1, darkModeColor: .GiniCapture.light1)
        )
    }

    private static func createButtonColorScheme() -> GiniColorScheme.Button {
        return GiniColorScheme.Button(
            background: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.accent1, darkModeColor: .GiniCapture.accent1),
            backgroundLoading: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.accent1.withAlphaComponent(0.24), darkModeColor: .GiniCapture.accent1.withAlphaComponent(0.24)),
            content: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.light1, darkModeColor: .GiniCapture.light1)
        )
    }

    private static func createButtonOutlinedColorScheme() -> GiniColorScheme.ButtonOutlined {
        return GiniColorScheme.ButtonOutlined(
            background: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.light4, darkModeColor: .GiniCapture.dark4),
            content: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.dark6, darkModeColor: .GiniCapture.light6)
        )
    }

    private static func createTextFieldColorScheme() -> GiniColorScheme.TextField {
        return GiniColorScheme.TextField(
            background: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.light1, darkModeColor: .GiniCapture.dark3),
            border: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.light3, darkModeColor: .GiniCapture.dark4),
            focusedText: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.dark2, darkModeColor: .GiniCapture.light1),
            unfocusedText: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.dark2, darkModeColor: .GiniCapture.light1),
            disabledText: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.dark2, darkModeColor: .GiniCapture.light1),
            errorText: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.error3, darkModeColor: .GiniCapture.error3),
            labelFocused: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.dark6, darkModeColor: .GiniCapture.dark6),
            labelUnfocused: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.dark6, darkModeColor: .GiniCapture.dark6),
            labelDisabled: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.dark6, darkModeColor: .GiniCapture.dark6),
            labelError: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.error3, darkModeColor: .GiniCapture.error3),
            supportingFocused: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.dark6, darkModeColor: .GiniCapture.dark6),
            supportingUnfocused: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.dark6, darkModeColor: .GiniCapture.dark6),
            supportingDisabled: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.dark6, darkModeColor: .GiniCapture.dark6),
            supportingError: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.error3, darkModeColor: .GiniCapture.error3),
            trailingFocused: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.dark7, darkModeColor: .GiniCapture.light6),
            cursorEnabled: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.accent1, darkModeColor: .GiniCapture.accent1),
            cursorError: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.error3, darkModeColor: .GiniCapture.error3)
        )
    }

    private static func createToggleColorScheme() -> GiniColorScheme.Toggle {
        return GiniColorScheme.Toggle(
            thumb: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.light1, darkModeColor: .GiniCapture.light1),
            trackOn: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.accent1, darkModeColor: .GiniCapture.accent1),
            trackOff: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.light4, darkModeColor: .GiniCapture.dark4),
            disabledTrack: GiniUtilites.GiniColor(lightModeColor: .GiniCapture.light4, darkModeColor: .GiniCapture.dark4)
        )
    }
}
