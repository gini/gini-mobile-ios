//
//  GiniSwiftUIButton.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import SwiftUI
import GiniCaptureSDK

struct GiniSwiftUIButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .frame(maxWidth: .infinity)
                .foregroundColor(Color(Constants.textColor))
                .padding()
        }
        .background(Color(Constants.itemBackgroundColor))
        .cornerRadius(7)
    }
}

private struct Constants {
    static let textColor = GiniColor(light: .black, dark: .white).uiColor()
    static let iconColor = GiniColor(light: .black, dark: .white).uiColor()
    static let itemBackgroundColor = GiniColor(
        light: giniCaptureColor("Light04"),
        dark: giniCaptureColor("Dark04")
    ).uiColor()
}
