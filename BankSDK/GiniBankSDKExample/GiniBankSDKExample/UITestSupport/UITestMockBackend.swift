//
//  UITestMockBackend.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import GiniBankAPILibrary
import GiniCaptureSDK

// Test scaffolding must never ship in the production binary; UI test runs
// (locally and on BrowserStack) always build the Debug configuration.
#if DEBUG

/**
 UI-test-only mock backend replacing the Gini API for deterministic UI tests.

 Manual test cases that rewrite backend responses with Charles cannot run on
 BrowserStack (no proxy on real devices). This class replaces the network layer
 through the SDK's public custom-networking entry point instead: it serves a canned
 analysis outcome selected by scenario name, and a `ClientConfiguration` assembled
 from generic flag overrides — any backend flag combination without new code.

 Activation — pass launch arguments from a UI test:

     app.launchArguments += ["-UITestMockScenario", "creditNote",
                             "-UITestMockClientConfig", "creditNoteHintEnabled=true"]

 `ScreenAPICoordinator` picks it up via `fromLaunchArguments()`. Never active in
 normal app runs. Unknown scenario names or flag keys fail loudly with
 `preconditionFailure` — a typo must fail loudly in every build configuration
 and never silently test the wrong behaviour.

 Extending: add a case to `UITestMockScenario` with its payload (or error).
 The client configuration needs no extension — every flag is overridable via
 `-UITestMockClientConfig "flagA=true,flagB=false"`; unlisted flags default to false.

 Limits: `layout`/`pages`/`documentPage` keep the protocol's no-op defaults, so
 flows that await a document preview (TransactionDocs preview) are not supported —
 keep `transactionDocsEnabled` overridden to false or extend those methods first.
 The real pipeline (auth, upload mechanics) is bypassed; keep real-backend smoke
 tests alongside mock-based ones.
 */

/**
 Named analysis outcomes served by `UITestMockBackend`.
 */
enum UITestMockScenario: String {

    /**
     A credit note: filled payment fields plus the `businessDocType == "creditnote"`
     marker the SDK's credit note gate checks.
     */
    case creditNote

    /**
     A plain invoice: same payment fields, no document-type marker, no feature
     screens (no line items, no discounts).
     */
    case invoice

    /**
     The analysis request fails — drives the SDK's error screen deterministically.
     */
    case analysisError

    /**
     The canned outcome delivered by `analyse`.
     */
    var analysisOutcome: Result<ExtractionResult, GiniError> {
        switch self {
        case .creditNote:
            return .success(UITestMockBackend.extractionResult(withBusinessDocType: "creditnote"))
        case .invoice:
            return .success(UITestMockBackend.extractionResult(withBusinessDocType: nil))
        case .analysisError:
            return .failure(.noResponse)
        }
    }
}

/**
 The mock service implementing both SDK networking protocols, driven by launch arguments.
 */
final class UITestMockBackend {

    /**
     The scenario whose canned outcome `analyse` delivers.
     */
    private let scenario: UITestMockScenario

    /**
     Flag overrides applied over the all-false baseline `ClientConfiguration`.
     */
    private let clientConfigurationOverrides: [String: Bool]

    /**
     The single fake API document handed back for every upload/analysis.
     */
    private let mockDocument: Document

    init(scenario: UITestMockScenario,
         clientConfigurationOverrides: [String: Bool]) {
        self.scenario = scenario
        self.clientConfigurationOverrides = clientConfigurationOverrides

        /// The literal is known-valid; force-unwrap so any future breakage fails
        /// loudly instead of silently rerouting tests to a `.noResponse` fallback.
        let url = URL(string: "https://pay-api.gini.net/documents/ui-test-mock-0000")!
        let links = Document.Links(giniAPIDocumentURL: url)
        mockDocument = Document(creationDate: Date(),
                                id: "ui-test-mock-0000",
                                name: "uiTestMockDocument",
                                links: links,
                                sourceClassification: .scanned)
    }

    /**
     Creates the mock backend when the `-UITestMockScenario` launch argument is present.
     - Returns: A configured instance, or `nil` outside mock-backend UI test runs.
     */
    static func fromLaunchArguments() -> UITestMockBackend? {
        guard let scenarioName = UserDefaults.standard.string(forKey: "UITestMockScenario") else {
            return nil
        }
        guard let scenario = UITestMockScenario(rawValue: scenarioName) else {
            /// A typo'd scenario would otherwise silently test the wrong behaviour.
            preconditionFailure("Unknown UITestMockScenario: \(scenarioName)")
        }
        let overridesString = UserDefaults.standard.string(forKey: "UITestMockClientConfig")
        return UITestMockBackend(scenario: scenario,
                                 clientConfigurationOverrides: parseClientConfigurationOverrides(from: overridesString))
    }

    // MARK: - Client configuration assembly

    /**
     Every overridable `ClientConfiguration` flag key.
     */
    private static let knownConfigurationFlags: Set<String> = [
        "userJourneyAnalyticsEnabled",
        "skontoEnabled",
        "returnAssistantEnabled",
        "transactionDocsEnabled",
        "instantPaymentEnabled",
        "qrCodeEducationEnabled",
        "eInvoiceEnabled",
        "savePhotosLocallyEnabled",
        "alreadyPaidHintEnabled",
        "paymentDueHintEnabled",
        "creditNoteHintEnabled",
        "paymentScheduleHintEnabled",
        "unsupportedQRCodeWarningEnabled"
    ]

    /**
     Parses `"flagA=true,flagB=false"` into flag overrides, validating every key
     and value against the known `ClientConfiguration` flags.
     - Parameters:
       - string: The raw launch-argument value; `nil` or empty yields no overrides.
     - Returns: The parsed overrides; an invalid entry traps via `preconditionFailure`.
     */
    private static func parseClientConfigurationOverrides(from string: String?) -> [String: Bool] {
        guard let string, !string.isEmpty else { return [:] }
        var overrides: [String: Bool] = [:]
        for entry in string.split(separator: ",") {
            let pair = entry.split(separator: "=", maxSplits: 1).map {
                $0.trimmingCharacters(in: .whitespaces)
            }
            guard pair.count == 2,
                  knownConfigurationFlags.contains(pair[0]),
                  let value = Bool(pair[1]) else {
                /// A typo'd flag would otherwise silently test the wrong configuration.
                preconditionFailure("Invalid UITestMockClientConfig entry: \(entry)")
            }
            overrides[pair[0]] = value
        }
        return overrides
    }

    /**
     Reads an overridden flag value, defaulting to false when not overridden.
     - Parameters:
       - key: The `ClientConfiguration` flag name.
     - Returns: The effective flag value.
     */
    private func flag(_ key: String) -> Bool {
        clientConfigurationOverrides[key] ?? false
    }

    // MARK: - Canned payloads

    /**
     Builds a filled payment-extraction payload, optionally marked with a business
     document type (e.g. `"creditnote"`).
     - Parameters:
       - businessDocType: The `businessDocType` extraction value, or `nil` to omit it.
     - Returns: The canned extraction result.
     */
    static func extractionResult(withBusinessDocType businessDocType: String?) -> ExtractionResult {
        var extractions = [
            Extraction(box: nil,
                       candidates: "ibans",
                       entity: "iban",
                       value: "DE74700500000000028273",
                       name: "iban"),
            Extraction(box: nil,
                       candidates: nil,
                       entity: "text",
                       value: "UI Test Recipient GmbH",
                       name: "paymentRecipient"),
            Extraction(box: nil,
                       candidates: nil,
                       entity: "text",
                       value: "Backend mock UI test",
                       name: "paymentPurpose"),
            Extraction(box: nil,
                       candidates: "amounts",
                       entity: "amount",
                       value: "42.00:EUR",
                       name: "amountToPay")
        ]
        if let businessDocType {
            extractions.append(Extraction(box: nil,
                                          candidates: nil,
                                          entity: "text",
                                          value: businessDocType,
                                          name: "businessDocType"))
        }
        return ExtractionResult(extractions: extractions,
                                lineItems: [],
                                returnReasons: [],
                                candidates: [:])
    }
}

// MARK: - GiniCaptureNetworkService

extension UITestMockBackend: GiniCaptureNetworkService {

    func upload(document: GiniCaptureDocument,
                metadata: Document.Metadata?,
                completion: @escaping UploadDocumentCompletion) {
        print("🧪 UI test mock backend - upload")
        completion(.success(mockDocument))
    }

    func analyse(partialDocuments: [PartialDocumentInfo],
                 metadata: Document.Metadata?,
                 cancellationToken: CancellationToken,
                 completion: @escaping (Result<(document: Document, extractionResult: ExtractionResult), GiniError>) -> Void) {
        print("🧪 UI test mock backend - analyse (scenario: \(scenario.rawValue))")
        switch scenario.analysisOutcome {
        case .success(let extractionResult):
            completion(.success((document: mockDocument, extractionResult: extractionResult)))
        case .failure(let error):
            completion(.failure(error))
        }
    }

    func delete(document: Document,
                completion: @escaping (Result<String, GiniError>) -> Void) {
        print("🧪 UI test mock backend - delete")
        completion(.success(document.id))
    }

    func cleanup() {
        print("🧪 UI test mock backend - cleanup")
    }

    func sendFeedback(document: Document,
                      updatedExtractions: [Extraction],
                      updatedCompoundExtractions: [String: [[Extraction]]]?,
                      completion: @escaping (Result<Void, GiniError>) -> Void) {
        print("🧪 UI test mock backend - send feedback")
        completion(.success(()))
    }

    func log(errorEvent: ErrorEvent,
             completion: @escaping (Result<Void, GiniError>) -> Void) {
        print("🧪 UI test mock backend - log error event")
        completion(.success(()))
    }
}

// MARK: - ClientConfigurationServiceProtocol

extension UITestMockBackend: ClientConfigurationServiceProtocol {

    func fetchConfigurations(completion: @escaping CompletionResult<ClientConfiguration>) {
        print("🧪 UI test mock backend - client configuration (overrides: \(clientConfigurationOverrides))")
        let configuration = ClientConfiguration(clientID: "ui-test-mock",
                                                userJourneyAnalyticsEnabled: flag("userJourneyAnalyticsEnabled"),
                                                skontoEnabled: flag("skontoEnabled"),
                                                returnAssistantEnabled: flag("returnAssistantEnabled"),
                                                transactionDocsEnabled: flag("transactionDocsEnabled"),
                                                instantPaymentEnabled: flag("instantPaymentEnabled"),
                                                qrCodeEducationEnabled: flag("qrCodeEducationEnabled"),
                                                eInvoiceEnabled: flag("eInvoiceEnabled"),
                                                savePhotosLocallyEnabled: flag("savePhotosLocallyEnabled"),
                                                alreadyPaidHintEnabled: flag("alreadyPaidHintEnabled"),
                                                paymentDueHintEnabled: flag("paymentDueHintEnabled"),
                                                creditNoteHintEnabled: flag("creditNoteHintEnabled"),
                                                paymentScheduleHintEnabled: flag("paymentScheduleHintEnabled"),
                                                unsupportedQRCodeWarningEnabled: flag("unsupportedQRCodeWarningEnabled"))
        completion(.success(configuration))
    }
}

#endif
