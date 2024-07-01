//
//  GiniColors.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

public enum GiniBankColors: String, CaseIterable {
    case accent01 = "Accent01"
    case accent02 = "Accent02"
    case accent03 = "Accent03"
    case accent04 = "Accent04"
    case accent05 = "Accent05"
    case dark01 = "Dark01"
    case dark02 = "Dark02"
    case dark03 = "Dark03"
    case dark04 = "Dark04"
    case dark05 = "Dark05"
    case dark06 = "Dark06"
    case dark07 = "Dark07"
    case error01 = "Error01"
    case error02 = "Error02"
    case error03 = "Error03"
    case error04 = "Error04"
    case error05 = "Error05"
    case light01 = "Light01"
    case light02 = "Light02"
    case light03 = "Light03"
    case light04 = "Light04"
    case light05 = "Light05"
    case light06 = "Light06"
    case success01 = "Success01"
    case success02 = "Success02"
    case success03 = "Success03"
    case success04 = "Success04"
    case success05 = "Success05"
    case warning01 = "Warning01"
    case warning02 = "Warning02"
    case warning03 = "Warning03"
    case warning04 = "Warning04"
    case warning05 = "Warning05"

    // Convert enum case to UIColor
    var toUIColor: UIColor {
        return prefferedColorByProvider(named: rawValue)
    }

    // This property provides a convenient way to access the UIColor corresponding to the raw value of the GiniBankColors enum.
    public var preferredUIColor: UIColor {
        return prefferedColor(named: rawValue)
    }
}

extension UIColor {
    public struct GiniBank {
        public static var accent1: UIColor {
            return GiniBankColors.accent01.toUIColor
        }
        public static var accent2: UIColor {
            return GiniBankColors.accent02.toUIColor
        }
        public static var accent3: UIColor {
            return GiniBankColors.accent03.toUIColor
        }
        public static var accent4: UIColor {
            return GiniBankColors.accent04.toUIColor
        }
        public static var accent5: UIColor {
            return GiniBankColors.accent05.toUIColor
        }
        public static var dark1: UIColor {
            return GiniBankColors.dark01.toUIColor
        }
        public static var dark2: UIColor {
            return GiniBankColors.dark02.toUIColor
        }
        public static var dark3: UIColor {
            return GiniBankColors.dark03.toUIColor
        }
        public static var dark4: UIColor {
            return GiniBankColors.dark04.toUIColor
        }
        public static var dark5: UIColor {
            return GiniBankColors.dark05.toUIColor
        }
        public static var dark6: UIColor {
            return GiniBankColors.dark06.toUIColor
        }
        public static var dark7: UIColor {
            return GiniBankColors.dark07.toUIColor
        }
        public static var error1: UIColor {
            return GiniBankColors.error01.toUIColor
        }
        public static var error2: UIColor {
            return GiniBankColors.error02.toUIColor
        }
        public static var error3: UIColor {
            return GiniBankColors.error03.toUIColor
        }
        public static var error4: UIColor {
            return GiniBankColors.error04.toUIColor
        }
        public static var error5: UIColor {
            return GiniBankColors.error05.toUIColor
        }
        public static var light1: UIColor {
            return GiniBankColors.light01.toUIColor
        }
        public static var light2: UIColor {
            return GiniBankColors.light02.toUIColor
        }
        public static var light3: UIColor {
            return GiniBankColors.light03.toUIColor
        }
        public static var light4: UIColor {
            return GiniBankColors.light04.toUIColor
        }
        public static var light5: UIColor {
            return GiniBankColors.light05.toUIColor
        }
        public static var light6: UIColor {
            return GiniBankColors.light06.toUIColor
        }
        public static var success1: UIColor {
            return GiniBankColors.success01.toUIColor
        }
        public static var success2: UIColor {
            return GiniBankColors.success02.toUIColor
        }
        public static var success3: UIColor {
            return GiniBankColors.success03.toUIColor
        }
        public static var success4: UIColor {
            return GiniBankColors.success04.toUIColor
        }
        public static var success5: UIColor {
            return GiniBankColors.success05.toUIColor
        }
        public static var warning1: UIColor {
            return GiniBankColors.warning01.toUIColor
        }
        public static var warning2: UIColor {
            return GiniBankColors.warning02.toUIColor
        }
        public static var warning3: UIColor {
            return GiniBankColors.warning03.toUIColor
        }
        public static var warning4: UIColor {
            return GiniBankColors.warning04.toUIColor
        }
        public static var warning5: UIColor {
            return GiniBankColors.warning05.toUIColor
        }
    }
}

extension UIColor {
    // MARK: Development scheme
    // TODO: Need to update scheme when designer will finish it
    public struct GiniColorScheme {
        struct Bg {
            var background: GiniColor
            var surface: GiniColor
            var tabbar: GiniColor
            var navbar: GiniColor
            var inputUnfocused: GiniColor
            var inputFocused: GiniColor
            var divider: GiniColor
            var border: GiniColor
        }

        struct Button {
            var surfaceEnabled: GiniColor
            var textEnabled: GiniColor
        }

        struct Icons {
            var surfaceFilled: GiniColor
            var standardPrimary: GiniColor
            var standardSecondary: GiniColor
            var standardTertiary: GiniColor
            var system: GiniColor
        }

        struct Text {
            var system: GiniColor
            var primary: GiniColor
            var secondary: GiniColor
            var tertiary: GiniColor
            var status: GiniColor
        }

        struct Chips {
            var suggestionEnabled: GiniColor
            var textSuggestionEnabled: GiniColor
            var assistEnabled: GiniColor
            var textAssistEnabled: GiniColor
        }

        struct Toggles {
            var surfaceFocused: GiniColor
            var surfaceUnfocused: GiniColor
            var surfaceDisabled: GiniColor
            var thumb: GiniColor
        }

        var bg: Bg
        var button: Button
        var icons: Icons
        var text: Text
        var chips: Chips
        var toggles: Toggles
    }

    public static func giniColorScheme() -> GiniColorScheme {
        return GiniColorScheme(
            bg: GiniColorScheme.Bg(
                background: GiniColor(light: .GiniBank.light2, dark: .GiniBank.dark2),
                surface: GiniColor(light: .GiniBank.light1, dark: .GiniBank.dark3),
                tabbar: GiniColor(light: .GiniBank.light1, dark: .GiniBank.dark3),
                navbar: GiniColor(light: .GiniBank.light2, dark: .GiniBank.dark2),
                inputUnfocused: GiniColor(light: .GiniBank.light1, dark: .GiniBank.dark3),
                inputFocused: GiniColor(light: .GiniBank.light1, dark: .GiniBank.dark3),
                divider: GiniColor(light: .GiniBank.light3, dark: .GiniBank.dark4),
                border: GiniColor(light: .GiniBank.light3, dark: .GiniBank.dark4)
            ),
            button: GiniColorScheme.Button(
                surfaceEnabled: GiniColor(light: .GiniBank.accent1, dark: .GiniBank.accent1),
                textEnabled: GiniColor(light: .GiniBank.light1, dark: .GiniBank.light1)
            ),
            icons: GiniColorScheme.Icons(
                surfaceFilled: GiniColor(light: .GiniBank.light2, dark: .GiniBank.light4),
                standardPrimary: GiniColor(light: .GiniBank.dark2, dark: .GiniBank.light2),
                standardSecondary: GiniColor(light: .GiniBank.light4, dark: .GiniBank.dark6),
                standardTertiary: GiniColor(light: .GiniBank.dark7, dark: .GiniBank.light6),
                system: GiniColor(light: .GiniBank.accent1, dark: .GiniBank.accent1)
            ),
            text: GiniColorScheme.Text(
                system: GiniColor(light: .GiniBank.accent1, dark: .GiniBank.accent1),
                primary: GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1),
                secondary: GiniColor(light: .GiniBank.dark6, dark: .GiniBank.dark7),
                tertiary: GiniColor(light: .GiniBank.dark7, dark: .GiniBank.light4),
                status: GiniColor(light: .GiniBank.success3, dark: .GiniBank.success3)),
            chips: GiniColorScheme.Chips(
                suggestionEnabled: GiniColor(light: .GiniBank.success3, dark: .GiniBank.success3),
                textSuggestionEnabled: GiniColor(light: .GiniBank.light1, dark: .GiniBank.light1),
                assistEnabled: GiniColor(light: .GiniBank.success5, dark: .GiniBank.success5),
                textAssistEnabled: GiniColor(light: .GiniBank.success2, dark: .GiniBank.success2)
            ),
            toggles: GiniColorScheme.Toggles(
                surfaceFocused: GiniColor(light: .GiniBank.accent1, dark: .GiniBank.accent1),
                surfaceUnfocused: GiniColor(light: .GiniBank.light4, dark: .GiniBank.dark4),
                surfaceDisabled: GiniColor(light: .white, dark: .white),
                thumb: GiniColor(light: .GiniBank.light1, dark: .GiniBank.light1)
            )
        )
    }
}
