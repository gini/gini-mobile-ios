//
//  IBANPickerSheet.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//
//  Spike PP-3938 — bottom sheet content, presented on top of MismatchView
//  when the user taps "Proceed anyway". Visual mock, placeholder styling.
//

import SwiftUI

struct IBANPickerSheet: View {

    let qrIBAN: String
    let printedIBAN: String

    @State private var selection: IBANChoice?
    var onContinue: (IBANChoice) -> Void = { _ in }

    enum IBANChoice: Hashable {
        case qr, printed
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("To continue, select one of the IBANs")
                .font(.title3.weight(.bold))
                .padding(.top, 20)

            VStack(spacing: 0) {
                row(choice: .qr, label: "In the QR code", iban: qrIBAN)
                row(choice: .printed, label: "Printed on the document", iban: printedIBAN)
            }

            Text("You can still check the IBAN on the next screen.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)

            Button {
                if let selection {
                    onContinue(selection)
                }
            } label: {
                Text("Continue")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(selection == nil ? Color.accentColor.opacity(0.4) : Color.accentColor)
                    )
            }
            .disabled(selection == nil)
            .padding(.bottom, 8)
        }
        .padding(.horizontal, 20)
    }

    private func row(choice: IBANChoice, label: String, iban: String) -> some View {
        Button {
            selection = choice
        } label: {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: selection == choice ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(selection == choice ? Color.accentColor : Color.secondary.opacity(0.6))

                VStack(alignment: .leading, spacing: 4) {
                    Text(label)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Text(iban)
                        .font(.body.monospaced())
                        .foregroundStyle(.primary)
                }

                Spacer(minLength: 0)
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
struct IBANPickerSheet_Previews: PreviewProvider {
    static var previews: some View {
        Color.gray.opacity(0.2)
            .ignoresSafeArea()
            .bottomSheet(isPresented: .constant(true)) {
                IBANPickerSheet(
                    qrIBAN: "PL12 1000 0111 0100 1000",
                    printedIBAN: "DE89 3704 0044 0532 0130 00"
                )
            }
    }
}
#endif
