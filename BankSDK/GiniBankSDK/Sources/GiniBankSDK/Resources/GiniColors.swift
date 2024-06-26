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
    public struct GiniColorScheme {
        struct Background {
            var background: GiniColor
            var surface: GiniColor
            var bar: GiniColor
            var listNormal: GiniColor
            var buttonEnabled: GiniColor
            var buttonFilled: GiniColor
            var inputUnfocused: GiniColor
            var inputFocused: GiniColor
            var divider: GiniColor
            var border: GiniColor
        }

        struct Text {
            var primary: GiniColor
            var secondary: GiniColor
            var chipsAssistEnabled: GiniColor
            var chipsSuggestionEnabled: GiniColor
            var buttonEnabled: GiniColor
            var status: GiniColor
        }

        struct Icons {
            var standardPrimary: GiniColor
            var standardSecondary: GiniColor
            var standardTertiary: GiniColor
        }

        struct Chips {
            var suggestionEnabled: GiniColor
            var assistEnabled: GiniColor
        }

        var background: Background
        var text: Text
        var icons: Icons
        var chips: Chips
    }

    public static func giniColorScheme() -> GiniColorScheme {
        return GiniColorScheme(
            background: GiniColorScheme.Background(
                background: GiniColor(light: .GiniBank.light2, dark: .GiniBank.dark1),
                surface: GiniColor(light: .GiniBank.light1, dark: .GiniBank.dark2),
                bar: GiniColor(light: .GiniBank.light1, dark: .GiniBank.dark2),
                listNormal: GiniColor(light: .GiniBank.light1, dark: .GiniBank.dark3),
                buttonEnabled: GiniColor(light: .GiniBank.accent1, dark: .GiniBank.accent1),
                buttonFilled: GiniColor(light: .GiniBank.light2, dark: .GiniBank.dark4),
                inputUnfocused: GiniColor(light: .GiniBank.light1, dark: .GiniBank.dark2),
                inputFocused: GiniColor(light: .GiniBank.light1, dark: .GiniBank.dark2),
                divider: GiniColor(light: .GiniBank.light3, dark: .GiniBank.dark3),
                border: GiniColor(light: .GiniBank.light3, dark: .GiniBank.dark3)
            ),
            text: GiniColorScheme.Text(
                primary: GiniColor(light: .GiniBank.dark2, dark: .GiniBank.light1),
                secondary: GiniColor(light: .GiniBank.dark6, dark: .GiniBank.light6),
                chipsAssistEnabled: GiniColor(light: .GiniBank.success2, dark: .GiniBank.success2),
                chipsSuggestionEnabled: GiniColor(light: .GiniBank.light1, dark: .GiniBank.light1),
                buttonEnabled: GiniColor(light: .GiniBank.light1, dark: .GiniBank.light1),
                status: GiniColor(light: .GiniBank.success1, dark: .GiniBank.success1)
            ),
            icons: GiniColorScheme.Icons(
                standardPrimary: GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1),
                standardSecondary: GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light2),
                standardTertiary: GiniColor(light: .GiniBank.dark5, dark: .GiniBank.light5)
            ),
            chips: GiniColorScheme.Chips(
                suggestionEnabled: GiniColor(light: .GiniBank.success1, dark: .GiniBank.success1),
                assistEnabled: GiniColor(light: .GiniBank.success4, dark: .GiniBank.success4)
            )
        )
    }
}
