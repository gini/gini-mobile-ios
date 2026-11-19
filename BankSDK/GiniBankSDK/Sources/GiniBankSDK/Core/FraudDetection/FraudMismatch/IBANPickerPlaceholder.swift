//
//  IBANPickerPlaceholder.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI

/**
 Placeholder for the IBAN selection sheet. The real picker (QR + printed
 IBAN rows, Confirm, chosen-IBAN propagation, `bic` removal) replaces this
 file's body in a follow-up; the `.sheet` wiring in `FraudWarningContainer`
 stays owned here. The dev-only Confirm button gives the Proceed path a
 terminal action until the real picker lands.
 */
struct IBANPickerPlaceholder: View {

    /// Default is a no-op so previews and smoke tests can render the view without wiring; `FraudWarningContainer` injects the real closure at the call site.
    var onConfirm: () -> Void = { /* no-op default — see property doc */ }

    var body: some View {
        VStack {
            Text("IBAN picker (placeholder)")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding()

            Spacer()

            Button(action: onConfirm) {
                Text("Confirm (placeholder — dev only)")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: Constants.buttonMinHeight)
                    .foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: Constants.buttonCornerRadius)
                            .fill(Color.accentColor)
                    )
            }
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.bottom, Constants.bottomPadding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private enum Constants {
        static let buttonMinHeight: CGFloat = 50
        static let buttonCornerRadius: CGFloat = 14
        static let horizontalPadding: CGFloat = 20
        static let bottomPadding: CGFloat = 20
    }
}
