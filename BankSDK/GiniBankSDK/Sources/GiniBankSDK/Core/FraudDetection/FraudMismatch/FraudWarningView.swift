//
//  FraudWarningView.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI
import UIKit
import GiniUtilites

/**
 Fraud warning screen body.

 Renders, from top to bottom: a warning icon, the "Different IBANs in this
 document" title and subtitle, a "How do I protect myself?" expandable, the
 "The following IBANs were detected" section with two informational
 `GiniOptionRow` instances (QR + printed IBAN), and the Cancel / Proceed
 button stack. Content values and the expand state come from the owning
 `FraudWarningViewModel`; button taps bubble up as closures the composition
 root wires.

 Strings are hardcoded English and design-system tokens on the title /
 subtitle / buttons are deferred to the final visual pass. The two
 `GiniOptionRow` rows already resolve their colors through the BankSDK
 `GiniColorScheme`.
 */
struct FraudWarningView: View {

    @ObservedObject var viewModel: FraudWarningViewModel

    var onCancel: () -> Void
    var onProceed: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: Constants.sectionSpacing) {
                warningIcon
                titleAndSubtitle
                protectMyselfExpandable
                detectedIBANsSection
                buttonStack
            }
            .padding(Constants.outerPadding)
        }
    }

    private var warningIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Constants.iconBackgroundCornerRadius)
                .fill(Color.orange.opacity(Constants.iconBackgroundOpacity))
                .frame(width: Constants.iconBackgroundSize,
                       height: Constants.iconBackgroundSize)

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: Constants.iconFontSize, weight: .semibold))
                .foregroundStyle(Color.orange)
        }
        /// SF Symbol placeholder — Figma glyph lands with the final visual pass.
    }

    private var titleAndSubtitle: some View {
        VStack(spacing: Constants.titleToSubtitleSpacing) {
            Text("Different IBANs in this document")
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)

            Text("The IBAN in the QR code doesn't match the printed IBAN")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var protectMyselfExpandable: some View {
        ExpandableInfoPlaceholder(title: "How do I protect myself?",
                                  message: "Documents are sometimes changed to redirect payments. If you're unsure which IBAN is right, ask the sender using contact details you already know.",
                                  icon: Image(systemName: "shield.lefthalf.filled"),
                                  isExpanded: $viewModel.isExpandedProtectMyself)
        /// Swap for `GiniExpandableInfoView` once that component lands.
    }

    private var detectedIBANsSection: some View {
        VStack(alignment: .leading, spacing: Constants.ibanSectionSpacing) {
            Text("The following IBANs were detected")
                .font(.headline)
                .foregroundStyle(.primary)

            GiniOptionRow(title: Constants.qrRowTitle,
                          content: viewModel.qrIBAN,
                          variant: .informational,
                          giniColorScheme: UIColor.giniBankColorScheme())

            GiniOptionRow(title: Constants.printedRowTitle,
                          content: viewModel.printedIBAN,
                          variant: .informational,
                          giniColorScheme: UIColor.giniBankColorScheme())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var buttonStack: some View {
        VStack(spacing: Constants.buttonSpacing) {
            Button(action: onCancel) {
                Text("Cancel transfer")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: Constants.buttonMinHeight)
                    .foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: Constants.buttonCornerRadius)
                            .fill(Color.accentColor)
                    )
            }

            Button(action: onProceed) {
                Text("Proceed anyway")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: Constants.buttonMinHeight)
                    .foregroundStyle(Color.accentColor)
                    .background(
                        RoundedRectangle(cornerRadius: Constants.buttonCornerRadius)
                            .stroke(Color.gray.opacity(Constants.secondaryBorderOpacity),
                                    lineWidth: Constants.secondaryBorderWidth)
                    )
            }
        }
        .padding(.top, Constants.buttonStackTopPadding)
    }

    private enum Constants {
        static let qrRowTitle = "In the QR code"
        static let printedRowTitle = "Printed on the document"

        static let sectionSpacing: CGFloat = 24
        static let outerPadding: CGFloat = 20
        static let titleToSubtitleSpacing: CGFloat = 8
        static let ibanSectionSpacing: CGFloat = 16
        static let buttonSpacing: CGFloat = 12
        static let buttonStackTopPadding: CGFloat = 8
        static let buttonMinHeight: CGFloat = 50
        static let buttonCornerRadius: CGFloat = 14
        static let secondaryBorderOpacity: CGFloat = 0.3
        static let secondaryBorderWidth: CGFloat = 1

        static let iconBackgroundSize: CGFloat = 56
        static let iconBackgroundCornerRadius: CGFloat = 14
        static let iconBackgroundOpacity: CGFloat = 0.15
        static let iconFontSize: CGFloat = 24
    }
}
