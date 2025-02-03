//
//  UIColor+Gini.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

public enum GiniCaptureColors: String, CaseIterable {
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
        return UIColorPreferredByProvider(named: rawValue)
    }

    // This property provides a convenient way to access the UIColor corresponding to the raw value of the GiniCaptureColors enum.
    public var preferredUIColor: UIColor {
        return UIColorPreferred(named: rawValue)
    }
}

extension UIColor {
    public struct GiniCapture {
        public static var accent1: UIColor {
            return GiniCaptureColors.accent01.toUIColor
        }
        public static var accent2: UIColor {
            return GiniCaptureColors.accent02.toUIColor
        }
        public static var accent3: UIColor {
            return GiniCaptureColors.accent03.toUIColor
        }
        public static var accent4: UIColor {
            return GiniCaptureColors.accent04.toUIColor
        }
        public static var accent5: UIColor {
            return GiniCaptureColors.accent05.toUIColor
        }
        public static var dark1: UIColor {
            return GiniCaptureColors.dark01.toUIColor
        }
        public static var dark2: UIColor {
            return GiniCaptureColors.dark02.toUIColor
        }
        public static var dark3: UIColor {
            return GiniCaptureColors.dark03.toUIColor
        }
        public static var dark4: UIColor {
            return GiniCaptureColors.dark04.toUIColor
        }
        public static var dark5: UIColor {
            return GiniCaptureColors.dark05.toUIColor
        }
        public static var dark6: UIColor {
            return GiniCaptureColors.dark06.toUIColor
        }
        public static var dark7: UIColor {
            return GiniCaptureColors.dark07.toUIColor
        }
        public static var error1: UIColor {
            return GiniCaptureColors.error01.toUIColor
        }
        public static var error2: UIColor {
            return GiniCaptureColors.error02.toUIColor
        }
        public static var error3: UIColor {
            return GiniCaptureColors.error03.toUIColor
        }
        public static var error4: UIColor {
            return GiniCaptureColors.error04.toUIColor
        }
        public static var error5: UIColor {
            return GiniCaptureColors.error05.toUIColor
        }
        public static var light1: UIColor {
            return GiniCaptureColors.light01.toUIColor
        }
        public static var light2: UIColor {
            return GiniCaptureColors.light02.toUIColor
        }
        public static var light3: UIColor {
            return GiniCaptureColors.light03.toUIColor
        }
        public static var light4: UIColor {
            return GiniCaptureColors.light04.toUIColor
        }
        public static var light5: UIColor {
            return GiniCaptureColors.light05.toUIColor
        }
        public static var light6: UIColor {
            return GiniCaptureColors.light06.toUIColor
        }
        public static var success1: UIColor {
            return GiniCaptureColors.success01.toUIColor
        }
        public static var success2: UIColor {
            return GiniCaptureColors.success02.toUIColor
        }
        public static var success3: UIColor {
            return GiniCaptureColors.success03.toUIColor
        }
        public static var success4: UIColor {
            return GiniCaptureColors.success04.toUIColor
        }
        public static var success5: UIColor {
            return GiniCaptureColors.success05.toUIColor
        }
        public static var warning1: UIColor {
            return GiniCaptureColors.warning01.toUIColor
        }
        public static var warning2: UIColor {
            return GiniCaptureColors.warning02.toUIColor
        }
        public static var warning3: UIColor {
            return GiniCaptureColors.warning03.toUIColor
        }
        public static var warning4: UIColor {
            return GiniCaptureColors.warning04.toUIColor
        }
        public static var warning5: UIColor {
            return GiniCaptureColors.warning05.toUIColor
        }
    }
}
