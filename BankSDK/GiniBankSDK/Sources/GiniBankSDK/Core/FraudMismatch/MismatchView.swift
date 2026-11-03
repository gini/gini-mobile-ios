//
//  MismatchView.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//
//  Spike PP-3938 — visual mock of the IBAN mismatch full-screen content.
//  Placeholder styling (SF Symbols, system colors). Not yet tokenized to
//  UIColor.giniBankColorScheme() / textStyleFonts / LocalizableStringResource.
//

import SwiftUI
import UIKit

struct MismatchView: View {

    let qrIBAN: String
    let printedIBAN: String

    var onCancel: () -> Void = {}
    var onProceedAnyway: () -> Void = {}

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                warningIcon

                VStack(spacing: 8) {
                    Text("Different IBANs in this document")
                        .font(.title2.weight(.bold))
                        .multilineTextAlignment(.center)

                    Text("The IBAN in the QR code doesn't match the printed IBAN")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                protectChip

                VStack(alignment: .leading, spacing: 16) {
                    Text("The following IBANs were detected")
                        .font(.headline)

                    ibanRow(label: "In the QR code", iban: qrIBAN)

                    Divider()

                    ibanRow(label: "Printed on the document", iban: printedIBAN)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 12) {
                    Button(action: onCancel) {
                        Text("Cancel transfer")
                            .font(.body.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .foregroundStyle(.white)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.accentColor)
                            )
                    }

                    Button(action: onProceedAnyway) {
                        Text("Proceed anyway")
                            .font(.body.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .foregroundStyle(Color.accentColor)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(Color(uiColor: .systemBackground))
    }

    private var warningIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.orange.opacity(0.15))
                .frame(width: 56, height: 56)
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(Color.orange)
        }
    }

    private var protectChip: some View {
        HStack(spacing: 10) {
            Image(systemName: "shield")
                .foregroundStyle(Color.blue)
            Text("How do I protect myself?")
                .font(.subheadline.weight(.medium))
            Spacer()
            Image(systemName: "chevron.down")
                .foregroundStyle(.secondary)
                .font(.footnote)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.12))
        )
    }

    private func ibanRow(label: String, iban: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text(iban)
                .font(.body.monospaced())
                .foregroundStyle(.primary)
        }
    }
}

#if DEBUG
struct MismatchView_Previews: PreviewProvider {
    static var previews: some View {
        MismatchView(
            qrIBAN: "PL12 1000 0111 0100 1000",
            printedIBAN: "DE89 3704 0044 0532 0130 00"
        )
    }
}
#endif
