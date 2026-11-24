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
                middleSection
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
        let (titleKey, bodyKey) = Self.titleAndBodyKeys(for: viewModel.content)
        return VStack(spacing: Constants.titleToSubtitleSpacing) {
            Text(Self.localized(titleKey))
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)

            Text(Self.localized(bodyKey))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private static func titleAndBodyKeys(for content: FraudWarningContent) -> (String, String) {
        switch content {
        case .qrPrinted:
            return ("ginibank.fraud.warning.title.qr.printed",
                    "ginibank.fraud.warning.body.qr.printed")
        case .country:
            return ("ginibank.fraud.warning.title.country",
                    "ginibank.fraud.warning.body.country")
        case .combined:
            return ("ginibank.fraud.warning.title.combined",
                    "ginibank.fraud.warning.body.combined")
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
                                    expandedAccessibilityValue: localized("ginibank.fraud.protect.a11y.expanded"),
                                    collapsedAccessibilityValue: localized("ginibank.fraud.protect.a11y.collapsed"))
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

    @ViewBuilder
    private var middleSection: some View {
        switch viewModel.content {
        case let .qrPrinted(qrIBAN, printedIBAN):
            qrPrintedSection(qrIBAN: qrIBAN, printedIBAN: printedIBAN)
        case let .country(senderName, senderCountry, iban):
            countrySection(senderName: senderName,
                           senderCountry: senderCountry,
                           iban: iban)
        case let .combined(senderName, senderCountry, qrIBAN, printedIBAN):
            combinedSection(senderName: senderName,
                            senderCountry: senderCountry,
                            qrIBAN: qrIBAN,
                            printedIBAN: printedIBAN)
        }
    }

    private func qrPrintedSection(qrIBAN: String,
                                  printedIBAN: String) -> some View {
        VStack(alignment: .leading, spacing: Constants.ibanSectionSpacing) {
            detectedIBANsHeader

            GiniOptionRow(title: Self.localized("ginibank.fraud.warning.row.qr.label"),
                          content: qrIBAN,
                          variant: .informational,
                          giniColorScheme: UIColor.giniBankColorScheme())

            GiniOptionRow(title: Self.localized("ginibank.fraud.warning.row.printed.label"),
                          content: printedIBAN,
                          variant: .informational,
                          giniColorScheme: UIColor.giniBankColorScheme())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func countrySection(senderName: String?,
                                senderCountry: String,
                                iban: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            senderOptionRow(senderName: senderName, senderCountry: senderCountry)
            Divider()
            GiniOptionRow(title: Self.localized("ginibank.fraud.warning.row.document.label"),
                          content: iban,
                          footer: Self.countryHint(for: iban, senderCountry: senderCountry),
                          variant: .informational,
                          giniColorScheme: UIColor.giniBankColorScheme())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func combinedSection(senderName: String?,
                                 senderCountry: String,
                                 qrIBAN: String,
                                 printedIBAN: String) -> some View {
        VStack(alignment: .leading, spacing: Constants.ibanSectionSpacing) {
            senderCard(senderName: senderName, senderCountry: senderCountry)

            detectedIBANsHeader

            VStack(alignment: .leading, spacing: 0) {
                GiniOptionRow(title: Self.localized("ginibank.fraud.warning.row.qr.label"),
                              content: qrIBAN,
                              footer: Self.countryHint(for: qrIBAN, senderCountry: senderCountry),
                              variant: .informational,
                              giniColorScheme: UIColor.giniBankColorScheme())
                Divider()
                GiniOptionRow(title: Self.localized("ginibank.fraud.warning.row.printed.label"),
                              content: printedIBAN,
                              footer: Self.countryHint(for: printedIBAN, senderCountry: senderCountry),
                              variant: .informational,
                              giniColorScheme: UIColor.giniBankColorScheme())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var detectedIBANsHeader: some View {
        Text(Self.localized("ginibank.fraud.warning.ibans.header"))
            .font(.headline)
            .foregroundStyle(.primary)
            .accessibilityAddTraits(.isHeader)
    }

    private func senderOptionRow(senderName: String?,
                                 senderCountry: String) -> some View {
        GiniOptionRow(title: Self.localized("ginibank.fraud.warning.sender.label"),
                      content: Self.senderContent(senderName: senderName,
                                                  senderCountry: senderCountry),
                      variant: .informational,
                      giniColorScheme: UIColor.giniBankColorScheme())
    }

    private func senderCard(senderName: String?,
                            senderCountry: String) -> some View {
        GiniOptionRow(title: Self.localized("ginibank.fraud.warning.sender.label"),
                      content: Self.senderContent(senderName: senderName,
                                                  senderCountry: senderCountry),
                      variant: .informational,
                      giniColorScheme: UIColor.giniBankColorScheme(),
                      background: Self.senderCardBackground)
    }

    private static var senderCardBackground: GiniColor {
        UIColor.giniBankColorScheme().placeholder.background
    }

    private static func senderContent(senderName: String?,
                                      senderCountry: String) -> String {
        let country = FraudCountryName.display(code: senderCountry,
                                               in: Self.countryNameLocale)
        guard let name = senderName, !name.isEmpty else { return country }
        return String(format: Self.localized("ginibank.fraud.warning.sender.with.country"),
                      name, country)
    }

    private static func countryHint(for iban: String,
                                    senderCountry: String) -> String? {
        guard let code = FraudWarningContent.hintCountryCode(for: iban,
                                                             senderCountry: senderCountry) else {
            return nil
        }
        let name = FraudCountryName.display(code: code, in: Self.countryNameLocale)
        return String(format: Self.localized("ginibank.fraud.warning.row.country.hint"), name)
    }

    private static var countryNameLocale: Locale {
        Locale(identifier: Self.localized("ginibank.fraud.country.name.locale"))
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
