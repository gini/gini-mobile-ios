//
//  IBANTextFieldSwiftUIView.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//
import SwiftUI
import GiniCaptureSDK
import GiniBankSDK

struct IBANTextFieldSwiftUIView: View {
    @Binding var ibanText: String
    var backgroundColor: Color = Constants.backgroundColor
    var textColor: Color = Constants.textColor
    var iconColor: Color = Constants.iconColor
    var onCameraTap: () -> Void

    var body: some View {
        HStack {
            TextField(DemoScreenStrings.ibanTextFieldPlaceholder.localized, text: $ibanText)
                .foregroundColor(textColor)
                .padding(.leading, Constants.textLeadingPadding)

            Spacer()

            Button(action: onCameraTap) {
                Image("cameraInput")
                    .renderingMode(.template)
                    .foregroundColor(iconColor)
                    .frame(width: Constants.cameraIconSize,
                           height: Constants.cameraIconSize)
            }
            .frame(width: Constants.cameraContainerWidth,
                   height: Constants.textFieldHeight)
        }
        .frame(height: Constants.textFieldHeight)
        .background(backgroundColor)
        .cornerRadius(Constants.cornerRadius)
    }
}

// MARK: - Constants
private struct Constants {
    static let textFieldHeight: CGFloat = 64
    static let textLeadingPadding: CGFloat = 16
    static let cameraIconSize: CGFloat = 24
    static let cameraContainerWidth: CGFloat = 50
    static let cornerRadius: CGFloat = 8

    static let backgroundColor = SwiftUIColor.gini(light: .GiniBank.light2, dark: .GiniBank.dark4)
    static let textColor = SwiftUIColor.gini(light: .GiniBank.dark1, dark: .GiniBank.light1)
    static let iconColor = SwiftUIColor.gini(light: .GiniBank.dark2, dark: .GiniBank.light1)
}
