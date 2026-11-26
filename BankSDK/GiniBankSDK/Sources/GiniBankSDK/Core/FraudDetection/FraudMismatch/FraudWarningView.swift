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

 Renders, from top to bottom: a warning icon, the title + subtitle, the
 "How do I protect myself?" expandable, the mismatch middle section
 (QR + printed IBAN rows, sender + country rows, or the combined
 variant), and the Cancel / Proceed button stack. Content values and
 expand state come from the owning `FraudWarningViewModel`; button taps
 bubble up as closures the composition root wires.

 Buttons route through `GiniBankConfiguration.shared.primaryButtonConfiguration`
 / `secondaryButtonConfiguration` so integrator overrides flow through
 to this screen too. `GiniOptionRow` rows resolve their colors from
 `GiniColorScheme` via `UIColor.giniBankColorScheme()`.
 */
struct FraudWarningView: View {

    @ObservedObject var viewModel: FraudWarningViewModel

    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var onCancel: () -> Void
    var onProceed: () -> Void

    var body: some View {
        let scheme = UIColor.giniBankColorScheme()
        let expandableVM = makeExpandableViewModel(scheme: scheme)
        return Group {
            if verticalSizeClass == .compact {
                // Landscape: everything scrolls together. When content overflows
                // the sheet, the user scrolls down to reveal the buttons rather
                // than having them pinned on top of the content.
                ScrollView {
                    VStack(spacing: Constants.majorSectionSpacing) {
                        scrollContent(scheme: scheme, expandableVM: expandableVM)
                        buttonStack
                    }
                    .padding(.horizontal, Constants.outerPadding)
                    .padding(.top, Constants.topInset)
                    .padding(.bottom, Constants.outerPadding)
                }
            } else {
                // Portrait: content scrolls, buttons pin to the bottom so the
                // primary action stays reachable without scrolling.
                VStack(spacing: 0) {
                    ScrollView {
                        scrollContent(scheme: scheme, expandableVM: expandableVM)
                            .padding(.horizontal, Constants.outerPadding)
                            .padding(.top, Constants.topInset)
                            .padding(.bottom, Constants.outerPadding)
                    }
                    buttonStack
                        .padding(.horizontal, Constants.outerPadding)
                        .padding(.bottom, Constants.outerPadding)
                }
            }
        }
    }

    private func scrollContent(scheme: GiniColorScheme,
                               expandableVM: GiniExpandableInfoViewModel) -> some View {
        VStack(spacing: Constants.majorSectionSpacing) {
            VStack(spacing: Constants.topBlockSpacing) {
                warningIcon
                titleAndSubtitle
                protectMyselfExpandable(scheme: scheme, expandableVM: expandableVM)
            }
            middleSection(scheme: scheme)
        }
    }

    private var warningIcon: some View {
        Image(uiImage: GiniImages.fraudWarning.image
              ?? UIImage(systemName: "exclamationmark.triangle.fill")
              ?? UIImage())
            .resizable()
            .scaledToFit()
            .frame(width: Constants.iconBackgroundSize,
                   height: Constants.iconBackgroundSize)
    }

    private var titleAndSubtitle: some View {
        VStack(spacing: Constants.titleToSubtitleSpacing) {
            Text(viewModel.title)
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)

            Text(viewModel.body)
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private func protectMyselfExpandable(scheme: GiniColorScheme,
                                         expandableVM: GiniExpandableInfoViewModel) -> some View {
        GiniExpandableInfoView(viewModel: expandableVM,
                               isExpanded: $viewModel.isExpandedProtectMyself) {
            Text(viewModel.protectBody)
                .font(Font(giniFont: Self.font(.footnote)))
                .foregroundStyle(scheme.text.secondary.swiftUIColor())
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .clipShape(RoundedRectangle(cornerRadius: Constants.expandableCornerRadius, style: .continuous))
    }

    private func makeExpandableViewModel(scheme: GiniColorScheme) -> GiniExpandableInfoViewModel {
        GiniExpandableInfoViewModel(icon: GiniImages.shield.image
                                        ?? UIImage(systemName: "shield.fill")
                                        ?? UIImage(),
                                    iconTint: scheme.text.accent,
                                    chevronIcon: GiniImages.chevronDownThin.image
                                                 ?? UIImage(systemName: "chevron.down")
                                                 ?? UIImage(),
                                    title: viewModel.protectTitle,
                                    backgroundColor: Self.expandableBackground(from: scheme),
                                    colorScheme: scheme,
                                    titleFont: Self.font(.subheadline),
                                    expandedAccessibilityValue: viewModel.protectExpandedA11yValue,
                                    collapsedAccessibilityValue: viewModel.protectCollapsedA11yValue)
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
    private func middleSection(scheme: GiniColorScheme) -> some View {
        switch viewModel.content {
        case let .qrPrinted(qrIBAN, printedIBAN):
            qrPrintedSection(qrIBAN: qrIBAN, printedIBAN: printedIBAN, scheme: scheme)
        case let .country(senderName, senderCountry, iban):
            countrySection(senderName: senderName,
                           senderCountry: senderCountry,
                           iban: iban,
                           scheme: scheme)
        case let .combined(senderName, senderCountry, qrIBAN, printedIBAN):
            combinedSection(senderName: senderName,
                            senderCountry: senderCountry,
                            qrIBAN: qrIBAN, printedIBAN: printedIBAN,
                            scheme: scheme)
        }
    }

    private func qrPrintedSection(qrIBAN: String,
                                  printedIBAN: String,
                                  scheme: GiniColorScheme) -> some View {
        VStack(alignment: .leading, spacing: Constants.headerToRowsCardSpacing) {
            detectedIBANsHeader

            VStack(alignment: .leading, spacing: 0) {
                GiniOptionRow(title: viewModel.qrRowLabel,
                              content: qrIBAN,
                              variant: .informational,
                              giniColorScheme: scheme,
                              contentPadding: Constants.flushRowPadding)
                Divider()
                GiniOptionRow(title: viewModel.printedRowLabel,
                              content: printedIBAN,
                              variant: .informational,
                              giniColorScheme: scheme,
                              contentPadding: Constants.flushRowPadding)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func countrySection(senderName: String?,
                                senderCountry: String,
                                iban: String,
                                scheme: GiniColorScheme) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            senderOptionRow(senderName: senderName,
                            senderCountry: senderCountry,
                            scheme: scheme,
                            contentPadding: Constants.firstFlushRowPadding)
            Divider()
            GiniOptionRow(title: viewModel.documentRowLabel,
                          content: iban,
                          footer: viewModel.countryHint(for: iban, senderCountry: senderCountry),
                          variant: .informational,
                          giniColorScheme: scheme,
                          contentPadding: Constants.lastFlushRowPadding)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func combinedSection(senderName: String?,
                                 senderCountry: String,
                                 qrIBAN: String,
                                 printedIBAN: String,
                                 scheme: GiniColorScheme) -> some View {
        VStack(alignment: .leading, spacing: Constants.senderToSectionHeaderSpacing) {
            senderCard(senderName: senderName,
                       senderCountry: senderCountry,
                       scheme: scheme)

            VStack(alignment: .leading, spacing: Constants.sectionHeaderToRowsSpacing) {
                detectedIBANsHeader

                VStack(alignment: .leading, spacing: 0) {
                    GiniOptionRow(title: viewModel.qrRowLabel,
                                  content: qrIBAN,
                                  footer: viewModel.countryHint(for: qrIBAN, senderCountry: senderCountry),
                                  variant: .informational,
                                  giniColorScheme: scheme,
                                  contentPadding: Constants.firstFlushRowPadding)
                    Divider()
                    GiniOptionRow(title: viewModel.printedRowLabel,
                                  content: printedIBAN,
                                  footer: viewModel.countryHint(for: printedIBAN, senderCountry: senderCountry),
                                  variant: .informational,
                                  giniColorScheme: scheme,
                                  contentPadding: Constants.flushRowPadding)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var detectedIBANsHeader: some View {
        Text(viewModel.ibansHeader)
            .font(.body.weight(.bold))
            .foregroundStyle(.primary)
            .accessibilityAddTraits(.isHeader)
    }

    private func senderOptionRow(senderName: String?,
                                 senderCountry: String,
                                 scheme: GiniColorScheme,
                                 contentPadding: EdgeInsets) -> some View {
        GiniOptionRow(title: viewModel.senderLabel,
                      content: viewModel.senderContent(senderName: senderName,
                                                      senderCountry: senderCountry),
                      variant: .informational,
                      giniColorScheme: scheme,
                      contentPadding: contentPadding)
    }

    private func senderCard(senderName: String?,
                            senderCountry: String,
                            scheme: GiniColorScheme) -> some View {
        GiniOptionRow(title: viewModel.senderLabel,
                      content: viewModel.senderContent(senderName: senderName,
                                                      senderCountry: senderCountry),
                      variant: .informational,
                      giniColorScheme: scheme,
                      background: scheme.placeholder.background)
    }

    /**
     Cancel + Proceed stacked vertically in portrait, side-by-side in
     landscape. Mirrors the UIKit `ButtonsView` axis flip and Android's
     `GiniActionFooter` orientation split so fraud warning matches every
     other secondary-button pair in the SDK.
     */
    private var buttonStack: some View {
        let layout: AnyLayout = verticalSizeClass == .compact
            ? AnyLayout(HStackLayout(spacing: Constants.buttonSpacing))
            : AnyLayout(VStackLayout(spacing: Constants.buttonSpacing))
        return layout {
            cancelButton
            proceedButton
        }
    }

    /**
     "Cancel transfer" is wired to `primaryButtonConfiguration` on purpose —
     fraud prevention nudges the user toward cancelling, so the filled
     brand button carries the safer action. The outlined
     `secondaryButtonConfiguration` goes to "Proceed anyway" so the
     riskier action reads as subordinate. Do not swap these without a
     product sign-off; a well-meaning "fix" to match the SDK's generic
     Primary = forward / Secondary = cancel convention would invert the
     entire fraud-prevention UX intent.
     */
    private var cancelButton: some View {
        Button(action: onCancel) {
            Text(viewModel.cancelCTA)
                .font(.body.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: Constants.buttonMinHeight)
        }
        .buttonStyle(GiniButtonStyle(GiniBankConfiguration.shared.primaryButtonConfiguration))
    }

    private var proceedButton: some View {
        Button(action: onProceed) {
            Text(viewModel.proceedCTA)
                .font(.body.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: Constants.buttonMinHeight)
        }
        .buttonStyle(GiniButtonStyle(GiniBankConfiguration.shared.secondaryButtonConfiguration))
    }

    private enum Constants {
        static let majorSectionSpacing: CGFloat = 32
        static let topBlockSpacing: CGFloat = 24
        static let outerPadding: CGFloat = 24
        /**
         Top padding from the sheet edge to the warning icon. Matches Figma's
         outer sheet `pt-32` plus the content wrapper's internal `pt-16`, so
         the icon sits 48pt below the sheet edge.
         */
        static let topInset: CGFloat = 48
        /** Gap between the sender card and the "The following IBANs were detected" header. Matches Figma's `space-350`. */
        static let senderToSectionHeaderSpacing: CGFloat = 20
        /** Gap between the "The following IBANs were detected" header and the IBAN rows block. Figma literal 11pt (not a named token). */
        static let sectionHeaderToRowsSpacing: CGFloat = 11
        /** First row has no top padding so the 11pt header→rows VStack gap maps straight to Figma's 11pt label-to-content distance. */
        static let firstFlushRowPadding = EdgeInsets.vertical(top: 0, bottom: 12)
        /** Last row drops its bottom padding so the row's content sits flush with the section's bottom edge (used by the country variant where there's no containing card). */
        static let lastFlushRowPadding = EdgeInsets.vertical(top: 12, bottom: 0)
        /** 12pt vertical breathing room between rows but flush to the content left/right edge, so the labels line up with the "The following IBANs were detected" header and the Sender card's outer edge. */
        static let flushRowPadding = EdgeInsets.vertical(top: 12, bottom: 12)
        /** QR variant's header→rows gap: Figma's `space-250` — the rows container supplies its own 12pt top padding via `flushRowPadding`, so the visual distance from header to the first row's content is 12pt (gap) + 12pt (row padding) = 24pt. */
        static let headerToRowsCardSpacing: CGFloat = 12
        static let titleToSubtitleSpacing: CGFloat = 12
        static let buttonSpacing: CGFloat = 12
        static let buttonMinHeight: CGFloat = 50

        static let iconBackgroundSize: CGFloat = 50

        static let expandableCornerRadius: CGFloat = 12

        static let expandableCardTintAlpha: CGFloat = 0.1
    }
}

private extension EdgeInsets {
    /** `EdgeInsets` shortcut for row paddings that use horizontal 0 and set only top/bottom. Reduces visual noise at the many `firstFlushRowPadding` / `flushRowPadding` / `lastFlushRowPadding` constant sites. */
    static func vertical(top: CGFloat, bottom: CGFloat) -> EdgeInsets {
        EdgeInsets(top: top, leading: 0, bottom: bottom, trailing: 0)
    }
}
