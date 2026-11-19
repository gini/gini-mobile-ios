//
//  IBANSelectionSheetPreview.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

#if DEBUG

import GiniCaptureSDK
import GiniUtilites
import SwiftUI
import UIKit

/**
 Developer preview for the IBAN selection sheet (`IBANSelectionSheet`).

 Intercepts the SDK's analysis-delivery paths and shows a tiny scaffolding
 view with a button that opens the sheet, so reviewers and QA can exercise
 the sheet end-to-end before the real fraud warning screen is wired in.

 Gated at runtime by `isEnabled` (UserDefaults, default `false`) and
 excluded from release builds via `#if DEBUG`.

 Toggled from the `GiniBankSDKExample` Settings screen.
 */
internal enum IBANSelectionSheetPreview {

    static let userDefaultsKey = "ginibank.example.ibanSelectionSheetPreviewEnabled"

    static var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: userDefaultsKey)
    }
}

// MARK: - Coordinator intercept

extension GiniBankNetworkingScreenApiCoordinator {

    /**
     Presents the preview over the SDK's root navigation controller when
     `IBANSelectionSheetPreview.isEnabled` is on. Calls `completion`
     immediately otherwise.
     */
    func presentIBANSelectionSheetPreview(for result: AnalysisResult,
                                          completion: @escaping () -> Void) {
        guard #available(iOS 16.0, *) else {
            completion()
            return
        }

        let host = IBANSelectionSheetPreviewHostingController(
            analysisResult: result,
            onConfirm: { host in
                host.dismiss(animated: true) { completion() }
            }
        )
        host.modalPresentationStyle = .fullScreen
        host.isModalInPresentation = true
        screenAPINavigationController.present(host, animated: true)
    }
}

// MARK: - UIKit bridge

@available(iOS 16.0, *)
internal final class IBANSelectionSheetPreviewHostingController: UIHostingController<IBANSelectionSheetPreviewView> {

    init(analysisResult: AnalysisResult,
         onConfirm: @escaping (UIViewController) -> Void) {
        super.init(rootView: IBANSelectionSheetPreviewView(analysisResult: analysisResult,
                                                           onConfirm: { /* overwritten by the next line; cannot reference self before super.init */ }))
        rootView = IBANSelectionSheetPreviewView(
            analysisResult: analysisResult,
            onConfirm: { [weak self] in
                guard let self else { return }
                onConfirm(self)
            }
        )
    }

    @MainActor @objc required dynamic init?(coder _: NSCoder) {
        fatalError("init(coder:) is not implemented for the preview scaffold")
    }
}

// MARK: - SwiftUI preview view

@available(iOS 16.0, *)
internal struct IBANSelectionSheetPreviewView: View {

    let analysisResult: AnalysisResult
    let onConfirm: () -> Void

    @State private var isShowingPicker: Bool = false
    @State private var selection: IBANChoice? = nil

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Analysis finished (preview)")
                .font(.title2.weight(.semibold))
                .multilineTextAlignment(.center)

            Text("Tap below to open the IBAN selection sheet.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Spacer()

            Button(action: { isShowingPicker = true }) {
                Text("Open IBAN selection sheet")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.accentColor)
                    )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground))
        .giniBottomSheet(isPresented: $isShowingPicker,
                         onDismiss: { selection = nil }) {
            IBANSelectionSheet(viewModel: Self.makeSheetViewModel(from: analysisResult),
                               selection: $selection,
                               onContinue: { _ in
                                   isShowingPicker = false
                                   DispatchQueue.main.async { onConfirm() }
                               })
        }
    }

    private static func makeSheetViewModel(from result: AnalysisResult) -> IBANSelectionSheetViewModel {
        let qrIBAN = result.extractions["iban"]?.value ?? "PL12 1000 0111 0100 1000"

        let candidateKey = result.extractions["iban"]?.candidates ?? "ibans"
        let printed = (result.candidates[candidateKey]?.map(\.value) ?? ["DE89 3704 0044 0532 0130 00"])
            .filter { $0.trimmingCharacters(in: .whitespaces).uppercased() != qrIBAN.trimmingCharacters(in: .whitespaces).uppercased() }
        let printedIBANs = printed.isEmpty ? ["DE89 3704 0044 0532 0130 00"] : printed

        let validationErrorMessage = NSLocalizedStringPreferredGiniBankFormat(
            "ginibank.fraud.ibanSelection.validation.selectIBAN",
            comment: "Inline error shown below the rows when the user taps Continue without picking an IBAN"
        )

        return IBANSelectionSheetViewModel(
            title: NSLocalizedStringPreferredGiniBankFormat(
                "ginibank.fraud.ibanSelection.title",
                comment: "Sheet title inviting the user to pick an IBAN before continuing"
            ),
            qrRowTitle: NSLocalizedStringPreferredGiniBankFormat(
                "ginibank.fraud.ibanSelection.row.qr.label",
                comment: "Row label for the QR code IBAN option"
            ),
            printedRowTitle: NSLocalizedStringPreferredGiniBankFormat(
                "ginibank.fraud.ibanSelection.row.printed.label",
                comment: "Row label for each printed IBAN option"
            ),
            footerHint: NSLocalizedStringPreferredGiniBankFormat(
                "ginibank.fraud.ibanSelection.footer.hint",
                comment: "Reassurance text shown below the rows, above the Continue button"
            ),
            continueCTA: NSLocalizedStringPreferredGiniBankFormat(
                "ginibank.fraud.ibanSelection.cta.continue",
                comment: "Primary CTA that confirms the user's IBAN selection"
            ),
            validationErrorMessage: validationErrorMessage,
            continueHintWhenNoSelection: validationErrorMessage,
            qrIBAN: qrIBAN,
            printedIBANs: printedIBANs,
            giniColorScheme: UIColor.giniBankColorScheme()
        )
    }
}

#endif
