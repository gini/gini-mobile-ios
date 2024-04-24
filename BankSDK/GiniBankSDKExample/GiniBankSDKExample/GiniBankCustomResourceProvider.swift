//
//  GiniBankCustomResourceProvider.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniBankSDK
import GiniCaptureSDK

class GiniBankCustomResourceProvider: CustomResourceProvider {
    func customPrefferedColor(name: String) -> UIColor {
        for color in GiniBankColors.allCases {
            switch color {
                case .accent01:
                    return UIColor(hex: "#C4DDF7")!
                case .accent02:
                    return UIColor(hex: "#FFFFFF")!
                case .accent03:
                    return .cyan
                case .accent04:
                    return .cyan
                case .accent05:
                    return .cyan
                case .dark01:
                    return .cyan
                case .dark02:
                    return .cyan
                case .dark03:
                    return .cyan
                case .dark04:
                    return .cyan
                case .dark05:
                    return .cyan
                case .dark06:
                    return .cyan
                case .dark07:
                    return .cyan
                case .error01:
                    return .red
                case .error02:
                    return .purple
                case .error03:
                    return .systemPink
                case .error04:
                    return .systemRed
                case .error05:
                    return .brown
                case .light01:
                    return .lightGray
                case .light02:
                    return .lightGray
                case .light03:
                    return .cyan
                case .light04:
                    return .lightGray
                case .light05:
                    return .cyan
                case .light06:
                    return .cyan
                case .success01:
                    return .cyan
                case .success02:
                    return .cyan
                case .success03:
                    return .cyan
                case .success04:
                    return .cyan
                case .success05:
                    return .cyan
                case .warning01:
                    return UIColor.GiniBank.accent1
                case .warning02:
                    return UIColor.GiniBank.accent2
                case .warning03:
                    return UIColor.GiniBank.accent3
                case .warning04:
                    return UIColor.GiniBank.accent4
                case .warning05:
                    return UIColor.GiniBank.accent5
            }
        }
        return UIColor.GiniBank.accent1
    }
}
