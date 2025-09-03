//
//  SwiftUIColor.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//
import SwiftUI
import GiniCaptureSDK

struct SwiftUIColor {
    static func gini(light: UIColor, dark: UIColor) -> Color {
        Color(GiniColor(light: light, dark: dark).uiColor())
    }
}
