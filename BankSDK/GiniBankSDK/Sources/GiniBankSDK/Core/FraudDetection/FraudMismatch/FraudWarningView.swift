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
            Text(Self.localized("ginibank.fraud.warning.title.qr.printed"))
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)

            Text(Self.localized("ginibank.fraud.warning.body.qr.printed"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var protectMyselfExpandable: some View {
        let scheme = UIColor.giniBankColorScheme()
        return GiniExpandableInfoView(viewModel: Self.makeExpandableViewModel(scheme: scheme),
                                      isExpanded: $viewModel.isExpandedProtectMyself) {
            Text(Self.localized("ginibank.fraud.protect.body"))
                .font(Font(giniFont: Self.font(.footnote)))
                .lineSpacing(Constants.expandableBodyLineSpacing)
                .foregroundStyle(scheme.text.secondary.swiftUIColor())
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .clipShape(RoundedRectangle(cornerRadius: Constants.expandableCornerRadius, style: .continuous))
    }

    private static func makeExpandableViewModel(scheme: GiniColorScheme) -> GiniExpandableInfoViewModel {
        GiniExpandableInfoViewModel(icon: GiniImages.shield.image ?? UIImage(),
                                    iconTint: scheme.text.accent,
                                    chevronIcon: GiniImages.chevronDownThin.image ?? UIImage(),
                                    title: localized("ginibank.fraud.protect.title"),
                                    backgroundColor: expandableBackground(from: scheme),
                                    colorScheme: scheme,
                                    titleFont: font(.subheadline),
                                    expandedAccessibilityValue: "Expanded",
                                    collapsedAccessibilityValue: "Collapsed")
    }

    /**
     Derives the expandable card surface from `scheme.text.accent`, applying the
     tint alpha through a dynamic provider so iOS resolves the base color per
     trait collection before compositing — dark mode gets a translucent accent
     over the dark background instead of inheriting a baked light-mode tint.
     */
    private static func expandableBackground(from scheme: GiniColorScheme) -> GiniColor {
        let base = scheme.text.accent.uiColor()
        let tinted = UIColor { trait in
            base.resolvedColor(with: trait).withAlphaComponent(Constants.expandableCardTintAlpha)
        }
        return GiniColor(lightModeColor: tinted, darkModeColor: tinted)
    }

    private static func font(_ style: UIFont.TextStyle) -> UIFont {
        GiniBankConfiguration.shared.textStyleFonts[style] ?? UIFont.preferredFont(forTextStyle: style)
    }

    private var detectedIBANsSection: some View {
        VStack(alignment: .leading, spacing: Constants.ibanSectionSpacing) {
            Text(Self.localized("ginibank.fraud.warning.ibans.header"))
                .font(.headline)
                .foregroundStyle(.primary)

            GiniOptionRow(title: Self.localized("ginibank.fraud.warning.row.qr.label"),
                          content: viewModel.qrIBAN,
                          variant: .informational,
                          giniColorScheme: UIColor.giniBankColorScheme())

            GiniOptionRow(title: Self.localized("ginibank.fraud.warning.row.printed.label"),
                          content: viewModel.printedIBAN,
                          variant: .informational,
                          giniColorScheme: UIColor.giniBankColorScheme())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var buttonStack: some View {
        VStack(spacing: Constants.buttonSpacing) {
            Button(action: onCancel) {
                Text(Self.localized("ginibank.fraud.warning.cta.cancel"))
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: Constants.buttonMinHeight)
                    .foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: Constants.buttonCornerRadius)
                            .fill(Color.accentColor)
                    )
            }

            Button(action: onProceed) {
                Text(Self.localized("ginibank.fraud.warning.cta.proceed"))
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

    private static func localized(_ key: String) -> String {
        NSLocalizedStringPreferredGiniBankFormat(key, comment: "")
    }

    private enum Constants {
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

        static let expandableCornerRadius: CGFloat = 12

        static let expandableCardTintAlpha: CGFloat = 0.2

        static let expandableBodyLineSpacing: CGFloat = 2
    }
}
