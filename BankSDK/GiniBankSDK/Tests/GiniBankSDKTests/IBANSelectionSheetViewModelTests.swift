//
//  IBANSelectionSheetViewModelTests.swift
//  GiniBankSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI
import Testing
import UIKit
@testable import GiniBankSDK
@testable import GiniUtilites

// Suites and tests cannot be marked `@available(iOS 16.0, *)` because Swift
// Testing's macros refuse to decorate availability-marked declarations. Each
// body uses `guard #available(iOS 16.0, *) else { return }`; on CI (iOS 26.2)
// the guard always passes.

/// Round-trip tests for `IBANSelectionSheetViewModel` — an immutable
/// configuration carrier, so the surface worth testing is "every piece the
/// sheet reads is stored by `init` verbatim." Behavior of the view itself
/// is verified via previews + manual QA.
@Suite("IBANSelectionSheetViewModel")
struct IBANSelectionSheetViewModelTests {

    private static func makeColorScheme() -> GiniColorScheme {
        UIColor.giniBankColorScheme()
    }

    private static func sentinelFont(size: CGFloat) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: .medium)
    }

    @Test("init stores every display string verbatim so the sheet reads pre-localized copy")
    func initStoresAllDisplayStrings() {
        guard #available(iOS 16.0, *) else { return }
        let viewModel = IBANSelectionSheetViewModel(
            title: "To continue, select one of the IBANs",
            qrRowTitle: "In the QR code",
            printedRowTitle: "Printed on the document",
            footerHint: "You can still check the IBAN on the next screen.",
            continueCTA: "Continue",
            validationErrorMessage: "Select an IBAN to continue",
            continueHintWhenNoSelection: "Select an IBAN to continue, then tap Continue",
            qrIBAN: "PL12 1000 0111 0100 1000",
            printedIBANs: ["DE89 3704 0044 0532 0130 00"],
            giniColorScheme: Self.makeColorScheme()
        )

        #expect(viewModel.title == "To continue, select one of the IBANs")
        #expect(viewModel.qrRowTitle == "In the QR code")
        #expect(viewModel.printedRowTitle == "Printed on the document")
        #expect(viewModel.footerHint == "You can still check the IBAN on the next screen.")
        #expect(viewModel.continueCTA == "Continue")
        #expect(viewModel.validationErrorMessage == "Select an IBAN to continue")
        #expect(viewModel.continueHintWhenNoSelection == "Select an IBAN to continue, then tap Continue")
        #expect(viewModel.qrIBAN == "PL12 1000 0111 0100 1000")
    }

    @Test("printedIBANs order is preserved exactly as the caller supplied it")
    func initPreservesPrintedIBANsOrder() {
        guard #available(iOS 16.0, *) else { return }
        let printed = ["DE89 3704 0044 0532 0130 00",
                       "DE02 1203 0000 0000 2020 51",
                       "GB29 NWBK 6016 1331 9268 19"]

        let viewModel = IBANSelectionSheetViewModel(
            title: "t",
            qrRowTitle: "q",
            printedRowTitle: "p",
            footerHint: "f",
            continueCTA: "c",
            validationErrorMessage: "v",
            continueHintWhenNoSelection: "h",
            qrIBAN: "QR",
            printedIBANs: printed,
            giniColorScheme: Self.makeColorScheme()
        )

        #expect(viewModel.printedIBANs == printed)
    }

    @Test("Single printed IBAN is accepted")
    func initAcceptsSinglePrintedIBAN() {
        guard #available(iOS 16.0, *) else { return }
        let viewModel = IBANSelectionSheetViewModel(
            title: "t",
            qrRowTitle: "q",
            printedRowTitle: "p",
            footerHint: "f",
            continueCTA: "c",
            validationErrorMessage: "v",
            continueHintWhenNoSelection: "h",
            qrIBAN: "QR",
            printedIBANs: ["DE89 3704 0044 0532 0130 00"],
            giniColorScheme: Self.makeColorScheme()
        )

        #expect(viewModel.printedIBANs.count == 1)
        #expect(viewModel.printedIBANs.first == "DE89 3704 0044 0532 0130 00")
    }

    @Test("init passes sheet and row fonts through by identity")
    func initPassesThroughSheetAndRowFonts() {
        guard #available(iOS 16.0, *) else { return }
        let sheetTitleFont = Self.sentinelFont(size: 42)
        let sheetValidationFont = Self.sentinelFont(size: 43)
        let sheetFooterFont = Self.sentinelFont(size: 44)
        let sheetContinueFont = Self.sentinelFont(size: 45)
        let rowTitleFont = Self.sentinelFont(size: 11)
        let rowContentFont = Self.sentinelFont(size: 12)
        let rowFooterFont = Self.sentinelFont(size: 13)

        let viewModel = IBANSelectionSheetViewModel(
            title: "t",
            qrRowTitle: "q",
            printedRowTitle: "p",
            footerHint: "f",
            continueCTA: "c",
            validationErrorMessage: "v",
            continueHintWhenNoSelection: "h",
            qrIBAN: "QR",
            printedIBANs: ["P1"],
            giniColorScheme: Self.makeColorScheme(),
            rowFonts: GiniOptionRow.FontConfiguration(title: rowTitleFont,
                                                      content: rowContentFont,
                                                      footer: rowFooterFont),
            sheetFonts: IBANSelectionSheetViewModel.FontConfig(title: sheetTitleFont,
                                                                validationError: sheetValidationFont,
                                                                footerHint: sheetFooterFont,
                                                                continueCTA: sheetContinueFont)
        )

        #expect(viewModel.sheetFonts.title === sheetTitleFont)
        #expect(viewModel.sheetFonts.validationError === sheetValidationFont)
        #expect(viewModel.sheetFonts.footerHint === sheetFooterFont)
        #expect(viewModel.sheetFonts.continueCTA === sheetContinueFont)
        #expect(viewModel.rowFonts.title === rowTitleFont)
        #expect(viewModel.rowFonts.content === rowContentFont)
        #expect(viewModel.rowFonts.footer === rowFooterFont)
    }
}

@Suite("IBANChoice")
struct IBANChoiceTests {

    @Test("iban property returns the associated value for both cases",
          arguments: [
            (IBANChoice.qr(iban: "QR_VALUE"), "QR_VALUE"),
            (IBANChoice.printed(iban: "PRINTED_VALUE"), "PRINTED_VALUE")
          ])
    func ibanPropertyReturnsAssociatedValue(input: IBANChoice,
                                             expected: String) {
        #expect(input.iban == expected)
    }

    @Test("qr(iban:) and printed(iban:) with the same value are not equal")
    func qrAndPrintedWithSameValueAreDistinct() {
        let qr = IBANChoice.qr(iban: "SAME")
        let printed = IBANChoice.printed(iban: "SAME")
        #expect(qr != printed)
    }
}

/// Pure state transitions behind `IBANSelectionSheet` — factored out of the
/// view so they can be tested without a view hosting harness.
@Suite("IBANSelectionSheetState")
struct IBANSelectionSheetStateTests {

    private static let qr: IBANChoice = .qr(iban: "QR_VALUE")
    private static let printed: IBANChoice = .printed(iban: "PRINTED_VALUE")

    @Test("variant returns .error for every row while the validation flag is on")
    func variantReturnsErrorWhileValidationFlagOn() {
        guard #available(iOS 16.0, *) else { return }
        #expect(IBANSelectionSheetState.variant(for: Self.qr,
                                                 selection: nil,
                                                 showValidationError: true) == .radio(.error))
        #expect(IBANSelectionSheetState.variant(for: Self.printed,
                                                 selection: Self.qr,
                                                 showValidationError: true) == .radio(.error))
    }

    @Test("variant returns .selected only for the matching choice")
    func variantReturnsSelectedForMatch() {
        guard #available(iOS 16.0, *) else { return }
        #expect(IBANSelectionSheetState.variant(for: Self.qr,
                                                 selection: Self.qr,
                                                 showValidationError: false) == .radio(.selected))
        #expect(IBANSelectionSheetState.variant(for: Self.printed,
                                                 selection: Self.qr,
                                                 showValidationError: false) == .radio(.unselected))
    }

    @Test("variant returns .unselected when nothing is selected")
    func variantReturnsUnselectedByDefault() {
        guard #available(iOS 16.0, *) else { return }
        #expect(IBANSelectionSheetState.variant(for: Self.qr,
                                                 selection: nil,
                                                 showValidationError: false) == .radio(.unselected))
    }

    @Test("select(_:) returns the new selection and clears the validation flag")
    func selectClearsValidationFlag() {
        guard #available(iOS 16.0, *) else { return }
        let (sel, err) = IBANSelectionSheetState.select(Self.printed,
                                                         currentSelection: nil,
                                                         showValidationError: true)
        #expect(sel == Self.printed)
        #expect(err == false)
    }

    @Test("select(_:) overwrites any prior selection")
    func selectReplacesPriorSelection() {
        guard #available(iOS 16.0, *) else { return }
        let (sel, _) = IBANSelectionSheetState.select(Self.printed,
                                                       currentSelection: Self.qr,
                                                       showValidationError: false)
        #expect(sel == Self.printed)
    }

    @Test("resolveContinueTap returns .confirm when a selection is present")
    func resolveContinueTapConfirmsSelection() {
        guard #available(iOS 16.0, *) else { return }
        let resolution = IBANSelectionSheetState.resolveContinueTap(selection: Self.printed)
        #expect(resolution == .confirm(Self.printed))
    }

    @Test("resolveContinueTap returns .revealError when no selection is present")
    func resolveContinueTapRevealsError() {
        guard #available(iOS 16.0, *) else { return }
        let resolution = IBANSelectionSheetState.resolveContinueTap(selection: nil)
        #expect(resolution == .revealError)
    }
}

// MARK: - IBANSelectionSheet rendering

/// Renders the SwiftUI view in a hosting controller attached to a visible
/// window so SwiftUI evaluates `body` and every styling helper. Mirrors the
/// pattern `GiniOptionRow`'s own render tests use.
@Suite("IBANSelectionSheet — body renders for every state")
@MainActor
struct IBANSelectionSheetRenderingTests {

    @Test("Renders in the default state (no selection, no validation error)")
    func rendersDefault() {
        guard #available(iOS 16.0, *) else { return }
        render(makeSheet(selection: .constant(nil)))
    }

    @Test("Renders with a selection (exercises the .selected row branch)")
    func rendersWithSelection() {
        guard #available(iOS 16.0, *) else { return }
        let printed = IBANChoice.printed(iban: "DE89 3704 0044 0532 0130 00")
        render(makeSheet(selection: .constant(printed)))
    }

    @Test("Renders with multiple printed IBANs (exercises the ForEach branch)")
    func rendersMultiplePrintedIBANs() {
        guard #available(iOS 16.0, *) else { return }
        render(makeSheet(
            selection: .constant(nil),
            printedIBANs: ["DE89 3704 0044 0532 0130 00",
                           "DE02 1203 0000 0000 2020 51",
                           "GB29 NWBK 6016 1331 9268 19"]
        ))
    }

    @Test("Renders at an accessibility Dynamic Type size (exercises the ScrollView branch)")
    func rendersAtAccessibilitySize() {
        guard #available(iOS 16.0, *) else { return }
        let sheet = makeSheet(selection: .constant(nil))
            .environment(\.dynamicTypeSize, .accessibility3)
        render(sheet)
    }

    @Test("Renders with explicit UIFonts supplied via FontConfig")
    func rendersWithExplicitFonts() {
        guard #available(iOS 16.0, *) else { return }
        let font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        let sheet = IBANSelectionSheet(
            viewModel: Self.makeViewModel(
                printedIBANs: ["DE89 3704 0044 0532 0130 00"],
                sheetFonts: IBANSelectionSheetViewModel.FontConfig(title: font,
                                                                    validationError: font,
                                                                    footerHint: font,
                                                                    continueCTA: font)
            ),
            selection: .constant(nil)
        )
        render(sheet)
    }

    // MARK: - Fixtures

    @available(iOS 16.0, *)
    private func makeSheet(selection: Binding<IBANChoice?>,
                           printedIBANs: [String] = ["DE89 3704 0044 0532 0130 00"]) -> IBANSelectionSheet {
        IBANSelectionSheet(viewModel: Self.makeViewModel(printedIBANs: printedIBANs),
                           selection: selection)
    }

    @available(iOS 16.0, *)
    private static func makeViewModel(printedIBANs: [String],
                                       sheetFonts: IBANSelectionSheetViewModel.FontConfig = .init()) -> IBANSelectionSheetViewModel {
        IBANSelectionSheetViewModel(
            title: "To continue, select one of the IBANs",
            qrRowTitle: "In the QR code",
            printedRowTitle: "Printed on the document",
            footerHint: "You can still check the IBAN on the next screen.",
            continueCTA: "Continue",
            validationErrorMessage: "Select an IBAN to continue",
            continueHintWhenNoSelection: "Select an IBAN to continue",
            qrIBAN: "PL12 1000 0111 0100 1000",
            printedIBANs: printedIBANs,
            giniColorScheme: UIColor.giniBankColorScheme(),
            sheetFonts: sheetFonts
        )
    }

    @available(iOS 16.0, *)
    private func render(_ sheet: some View) {
        let hosting = UIHostingController(rootView: sheet)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 600))
        window.rootViewController = hosting
        window.isHidden = false
        hosting.view.setNeedsLayout()
        hosting.view.layoutIfNeeded()
    }
}

// MARK: - IBANSelectionSheetPreview flag

#if DEBUG
/// `IBANSelectionSheetPreview.isEnabled` reads `UserDefaults.standard`. The
/// test flips the flag and asserts the read-side observes it.
@Suite("IBANSelectionSheetPreview — UserDefaults flag")
struct IBANSelectionSheetPreviewFlagTests {

    @Test("isEnabled defaults to false when nothing is written")
    func defaultsToFalse() {
        UserDefaults.standard.removeObject(forKey: IBANSelectionSheetPreview.userDefaultsKey)
        #expect(IBANSelectionSheetPreview.isEnabled == false)
    }

    @Test("isEnabled reflects the UserDefaults value",
          arguments: [true, false])
    func reflectsUserDefaultsValue(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: IBANSelectionSheetPreview.userDefaultsKey)
        defer { UserDefaults.standard.removeObject(forKey: IBANSelectionSheetPreview.userDefaultsKey) }
        #expect(IBANSelectionSheetPreview.isEnabled == value)
    }
}
#endif
