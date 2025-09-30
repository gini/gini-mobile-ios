//
//  GiniSwiftUIButton.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import SwiftUI
import GiniCaptureSDK
import GiniBankSDK

struct GiniSwiftUIButton: View {
    let title: String
    let textColor: Color?
    let backgroundColor: Color?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: Constants.fontSize, weight: .semibold))
                .frame(maxWidth: .infinity)
                .foregroundColor(textColor)
                .padding()
        }
        .background(backgroundColor)
        .cornerRadius(Constants.cornerRadius)
    }
}

private struct Constants {
    static let fontSize: CGFloat = 17
    static let cornerRadius: CGFloat = 7
}
