//
//  FraudWarningView.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI

/**
 Scaffold layout for the fraud warning screen.

 Renders two action buttons — a secondary "Cancel transfer" above a primary
 "Proceed anyway" — stacked at the bottom of a reserved empty area where the
 real content (icon, title, body, IBAN rows) will land in the follow-up that
 completes the UI. The view is purely stateless; both button actions bubble
 up as closures the Coordinator wires to `FraudWarningViewModel`.
 */
struct FraudWarningView: View {

    /** Invoked when the user taps the Cancel button. */
    var onCancel: () -> Void

    /** Invoked when the user taps the Proceed button. */
    var onProceed: () -> Void

    var body: some View {
        VStack(spacing: Constants.buttonSpacing) {
            Spacer()

            Button(action: onCancel) {
                // Hardcoded English scaffold — LocalizableStringResource wiring lands with the visual pass.
                Text("Cancel transfer")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: Constants.buttonMinHeight)
                    .foregroundStyle(Color.accentColor)
                    .background(
                        RoundedRectangle(cornerRadius: Constants.buttonCornerRadius)
                            .stroke(Color.gray.opacity(Constants.secondaryBorderOpacity),
                                    lineWidth: Constants.secondaryBorderWidth)
                    )
            }

            Button(action: onProceed) {
                // Hardcoded English scaffold — LocalizableStringResource wiring lands with the visual pass.
                Text("Proceed anyway")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: Constants.buttonMinHeight)
                    .foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: Constants.buttonCornerRadius)
                            .fill(Color.accentColor)
                    )
            }
        }
        .padding(Constants.outerPadding)
    }

    private enum Constants {
        static let buttonSpacing: CGFloat = 12
        static let outerPadding: CGFloat = 20
        static let buttonMinHeight: CGFloat = 50
        static let buttonCornerRadius: CGFloat = 14
        static let secondaryBorderOpacity: CGFloat = 0.3
        static let secondaryBorderWidth: CGFloat = 1
    }
}
