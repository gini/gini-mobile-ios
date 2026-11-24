//
//  IBANSelectionSheet.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import GiniUtilites
import SwiftUI
import UIKit

/**
 Bottom-sheet content presenting the user with a list of IBAN candidates
 (the QR code IBAN plus every printed IBAN) and asking them to pick which
 one the bank will receive.

 Validation is error-driven, not selection-gated: "Continue" is always
 tappable. Tapping it with no selection switches every row's radio to
 `.radio(.error)` and reveals the inline validation line; tapping any row
 clears the error state.

 ## Attaching the sheet

 ```swift
 parent.giniBottomSheet(isPresented: $show,
                        onDismiss: { selection = nil }) {
     IBANSelectionSheet(viewModel: vm,
                        selection: $selection,
                        onContinue: { choice in
                            show = false
                            coordinator.userConfirmed(choice)
                        })
 }
 ```
 */
struct IBANSelectionSheet: View {

    let viewModel: IBANSelectionSheetViewModel

    @Binding var selection: IBANChoice?

    /**
     Invoked when the user taps "Continue" with a valid selection. The caller
     flips the sheet's `isPresented` binding to `false` and runs any further
     hand-off. Drag-dismiss is handled by the `giniBottomSheet` modifier's
     `onDismiss` parameter.
     */
    var onContinue: (IBANChoice) -> Void = { _ in /* no-op default — caller opts in */ }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var showValidationError: Bool = false

    /**
     Focus hook so VoiceOver reads the validation message rather than
     staying on the Continue button (WCAG 4.1.3).
     */
    @AccessibilityFocusState private var validationErrorFocused: Bool

    var body: some View {
        // Non-accessibility Dynamic Type: render naturally inside the
        // `.medium` detent. Accessibility sizes can grow row heights past
        // the `.large` detent that `giniBottomSheet` switches to, so wrap
        // in a `ScrollView` as a safety net.
        if dynamicTypeSize.isAccessibilitySize {
            ScrollView { naturalLayout }
        } else {
            naturalLayout
        }
    }

    private var naturalLayout: some View {
        VStack(alignment: .leading, spacing: Constants.titleToContentSpacing) {
            Text(viewModel.title)
                .font(titleFont)
                .foregroundStyle(titleColor)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)

            VStack(alignment: .leading, spacing: Constants.innerContentSpacing) {
                VStack(alignment: .leading, spacing: Constants.rowsToErrorSpacing) {
                    optionsList

                    if showValidationError {
                        Text(viewModel.validationErrorMessage)
                            .font(validationErrorFont)
                            .foregroundStyle(validationErrorColor)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, Constants.errorLineHorizontalPadding)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityFocused($validationErrorFocused)
                    }
                }

                VStack(alignment: .leading, spacing: Constants.footerToButtonSpacing) {
                    Text(viewModel.footerHint)
                        .font(footerHintFont)
                        .foregroundStyle(footerHintColor)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .fixedSize(horizontal: false, vertical: true)

                    continueButton
                }
            }
        }
        .padding(.horizontal, Constants.horizontalPadding)
        .padding(.bottom, Constants.bottomPadding)
    }

    // MARK: - Subviews

    private var optionsList: some View {
        VStack(spacing: 0) {
            GiniOptionRow(title: viewModel.qrRowTitle,
                          content: viewModel.qrIBAN,
                          variant: variant(for: .qr(iban: viewModel.qrIBAN)),
                          giniColorScheme: viewModel.giniColorScheme,
                          fonts: viewModel.rowFonts,
                          onTap: { select(.qr(iban: viewModel.qrIBAN)) })
                .accessibilityAction(named: Text(viewModel.spellOutIBANActionName)) {
                    Self.announceSpelledOut(viewModel.qrIBAN)
                }

            ForEach(Array(viewModel.printedIBANs.enumerated()), id: \.offset) { _, printedIBAN in
                Divider()
                GiniOptionRow(title: viewModel.printedRowTitle,
                              content: printedIBAN,
                              variant: variant(for: .printed(iban: printedIBAN)),
                              giniColorScheme: viewModel.giniColorScheme,
                              fonts: viewModel.rowFonts,
                              onTap: { select(.printed(iban: printedIBAN)) })
                    .accessibilityAction(named: Text(viewModel.spellOutIBANActionName)) {
                        Self.announceSpelledOut(printedIBAN)
                    }
            }
        }
    }

    /**
     Posts an accessibility announcement that reads `iban` character by
     character. Used by the per-row "Spell out IBAN" rotor action so a blind
     user can detect a one-character substitution.
     */
    private static func announceSpelledOut(_ iban: String) {
        var spelled = AttributedString(iban)
        spelled.accessibilitySpeechSpellsOutCharacters = true
        UIAccessibility.post(notification: .announcement,
                             argument: NSAttributedString(spelled))
    }

    private var continueButton: some View {
        Button(action: handleContinueTap) {
            Text(viewModel.continueCTA)
                .font(continueCTAFont)
                .foregroundStyle(continueCTAContentColor)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, minHeight: Constants.buttonMinHeight)
                .background(
                    RoundedRectangle(cornerRadius: Constants.buttonCornerRadius)
                        .fill(continueCTABackgroundColor)
                )
        }
        .buttonStyle(.plain)
        .accessibilityHint(selection == nil ? viewModel.continueHintWhenNoSelection : "")
    }

    // MARK: - State transitions

    private func variant(for choice: IBANChoice) -> GiniOptionRow.Variant {
        IBANSelectionSheetState.variant(for: choice,
                                         selection: selection,
                                         showValidationError: showValidationError)
    }

    private func select(_ choice: IBANChoice) {
        let newState = IBANSelectionSheetState.select(choice,
                                                      currentSelection: selection,
                                                      showValidationError: showValidationError)
        let apply = {
            selection = newState.selection
            showValidationError = newState.showValidationError
        }
        if reduceMotion {
            apply()
        } else {
            withAnimation(.easeInOut(duration: Constants.animationDuration)) { apply() }
        }
    }

    private func handleContinueTap() {
        switch IBANSelectionSheetState.resolveContinueTap(selection: selection) {
        case .confirm(let choice):
            onContinue(choice)
        case .revealError:
            revealValidationError()
        }
    }

    private func revealValidationError() {
        let apply = { showValidationError = true }
        if reduceMotion {
            apply()
        } else {
            withAnimation(.easeInOut(duration: Constants.animationDuration)) { apply() }
        }
        validationErrorFocused = true
        UIAccessibility.post(notification: .announcement,
                             argument: viewModel.validationErrorMessage)
    }

    // MARK: - Styling helpers

    private var titleFont: Font {
        viewModel.sheetFonts.title.map { Font(giniFont: $0) } ?? .title2
    }

    private var validationErrorFont: Font {
        viewModel.sheetFonts.validationError.map { Font(giniFont: $0) } ?? .footnote
    }

    private var footerHintFont: Font {
        viewModel.sheetFonts.footerHint.map { Font(giniFont: $0) } ?? .footnote
    }

    private var continueCTAFont: Font {
        viewModel.sheetFonts.continueCTA.map { Font(giniFont: $0) } ?? .body.weight(.semibold)
    }

    private var titleColor: Color {
        viewModel.giniColorScheme.text.primary.swiftUIColor()
    }

    private var validationErrorColor: Color {
        viewModel.giniColorScheme.text.error.swiftUIColor()
    }

    private var footerHintColor: Color {
        viewModel.giniColorScheme.text.secondary.swiftUIColor()
    }

    private var continueCTAContentColor: Color {
        viewModel.giniColorScheme.button.content.swiftUIColor()
    }

    private var continueCTABackgroundColor: Color {
        viewModel.giniColorScheme.button.background.swiftUIColor()
    }

    private enum Constants {
        static let titleToContentSpacing: CGFloat = 20
        static let innerContentSpacing: CGFloat = 24
        static let rowsToErrorSpacing: CGFloat = 4
        static let footerToButtonSpacing: CGFloat = 8
        static let errorLineHorizontalPadding: CGFloat = 8
        static let horizontalPadding: CGFloat = 24
        static let bottomPadding: CGFloat = 24
        static let buttonMinHeight: CGFloat = 50
        static let buttonCornerRadius: CGFloat = 14
        static let animationDuration: Double = 0.2
    }
}

/**
 Pure value-type carrier for `IBANSelectionSheet`'s state transitions. Kept
 outside the view so the three helpers (`variant`, `select`,
 `resolveContinueTap`) can be unit-tested without a view hosting harness.
 */
enum IBANSelectionSheetState {

    /**
     The `GiniOptionRow.Variant` for `choice` given the sheet's current
     `selection` and `showValidationError`. All rows turn `.error` together
     while the validation flag is on so the user sees the sheet is blocked.
     */
    static func variant(for choice: IBANChoice,
                        selection: IBANChoice?,
                        showValidationError: Bool) -> GiniOptionRow.Variant {
        if showValidationError { return .radio(.error) }
        if selection == choice { return .radio(.selected) }
        return .radio(.unselected)
    }

    /**
     New state after the user taps a row — the selection is replaced and
     the error flag is cleared (the user has responded to the validation).
     The `currentSelection` and `showValidationError` inputs document that
     the result is independent of them.
     */
    static func select(_ choice: IBANChoice,
                       currentSelection _: IBANChoice?,
                       showValidationError _: Bool) -> (selection: IBANChoice?, showValidationError: Bool) {
        (.some(choice), false)
    }

    /**
     Resolution for a "Continue" tap: `confirm(iban)` when a selection is
     present, `revealError` otherwise.
     */
    enum ContinueTapResolution: Equatable {
        case confirm(IBANChoice)
        case revealError
    }

    static func resolveContinueTap(selection: IBANChoice?) -> ContinueTapResolution {
        if let selection { return .confirm(selection) }
        return .revealError
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 17.0, *)
#Preview("Default — unselected") {
    IBANSelectionSheetPreviewHost(initialSelection: nil)
}

@available(iOS 17.0, *)
#Preview("Printed selected") {
    IBANSelectionSheetPreviewHost(initialSelection: .printed(iban: "DE89 3704 0044 0532 0130 00"))
}

@available(iOS 17.0, *)
#Preview("Multiple printed IBANs") {
    IBANSelectionSheetPreviewHost(
        initialSelection: nil,
        printedIBANs: ["DE89 3704 0044 0532 0130 00",
                       "DE02 1203 0000 0000 2020 51",
                       "GB29 NWBK 6016 1331 9268 19"]
    )
}

@available(iOS 17.0, *)
#Preview("Dark mode") {
    IBANSelectionSheetPreviewHost(initialSelection: nil)
        .preferredColorScheme(.dark)
}

@available(iOS 17.0, *)
#Preview("Dynamic Type — AX3") {
    IBANSelectionSheetPreviewHost(initialSelection: nil)
        .environment(\.sizeCategory, .accessibilityExtraLarge)
}

/**
 Wrapper view that owns the `selection` binding so previews can seed the
 sheet with a specific state. The validation-error state is reached by
 tapping the live Continue button, not via an injected preset.
 */
private struct IBANSelectionSheetPreviewHost: View {

    @State private var selection: IBANChoice?
    let printedIBANs: [String]

    init(initialSelection: IBANChoice?,
         printedIBANs: [String] = ["DE89 3704 0044 0532 0130 00"]) {
        self._selection = State(initialValue: initialSelection)
        self.printedIBANs = printedIBANs
    }

    var body: some View {
        IBANSelectionSheet(viewModel: makeViewModel(),
                           selection: $selection,
                           onContinue: { _ in /* preview has no hand-off */ })
    }

    private func makeViewModel() -> IBANSelectionSheetViewModel {
        IBANSelectionSheetViewModel(
            title: "To continue, select one of the IBANs",
            qrRowTitle: "In the QR code",
            printedRowTitle: "Printed on the document",
            footerHint: "You can still check the IBAN on the next screen.",
            continueCTA: "Continue",
            validationErrorMessage: "Select an IBAN to continue",
            continueHintWhenNoSelection: "Select an IBAN to continue",
            spellOutIBANActionName: "Spell out IBAN",
            qrIBAN: "PL12 1000 0111 0100 1000",
            printedIBANs: printedIBANs,
            giniColorScheme: UIColor.giniBankColorScheme()
        )
    }
}
#endif
