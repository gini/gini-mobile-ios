//
//  IBANTextFieldSwiftUIView.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import SwiftUI
import GiniCaptureSDK

struct IBANTextFieldSwiftUIView: View {
    @Binding var ibanText: String
    var onCameraTap: () -> Void

    var body: some View {
        HStack {
            // IBAN TextField
            TextField(DemoScreenStrings.ibanTextFieldPlaceholder.localized, text: $ibanText)
                .font(.system(size: 17))
                .padding(.leading, 16)
                .foregroundColor(.black)
                .frame(height: 50) // Adjust height to match design
                .background(Color.clear)

            // Camera Icon Button
            Button(action: onCameraTap) {
                Image(systemName: "camera")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.black)
                    .padding(.trailing, 16)
            }
        }
        .frame(height: 50) // Match the height
        .background(Color(UIColor.systemGray6)) // Use a light background color
        .cornerRadius(10) // Rounded corners
    }
}
