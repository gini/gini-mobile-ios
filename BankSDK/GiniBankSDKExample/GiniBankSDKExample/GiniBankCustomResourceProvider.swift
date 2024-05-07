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
        for color in GiniBankColors.allCases where color.rawValue == name {
            switch color {
                case .accent01:
                    return .magenta
                default:
                    return color.preferredUIColor
            }
        }
        return .brown
    }
}
