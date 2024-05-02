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
                default:
                    return prefferedColorByProvider(named: name)
            }
        }
        return UIColor.GiniBank.accent1
    }
}
