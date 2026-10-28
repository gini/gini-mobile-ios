//
//  RemoteConfigPropagationTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import Testing
@testable import GiniBankAPILibrary
@testable import GiniBankSDK
@testable import GiniCaptureSDK

extension GiniConfigurationSharedStateSuite {
    @Suite("Remote client-configuration propagation to GiniCaptureUserDefaultsStorage", .serialized)
    @MainActor
    struct RemoteConfigPropagationTests {

        init() {
            _GINIBANKAPILIBRARY_DISABLE_KEYCHAIN_PRECONDITION_FAILURE = true
        }

        @Test("unsupportedQRCodeWarningEnabled=true from remote config is written to storage")
        func propagatesUnsupportedQRCodeWarningTrue() async {
            await runStartSDK(resetStorage: { GiniCaptureUserDefaultsStorage.unsupportedQRCodeWarningEnabled = nil },
                              configuration: makeClientConfiguration(unsupportedQRCodeWarningEnabled: true))

            #expect(GiniCaptureUserDefaultsStorage.unsupportedQRCodeWarningEnabled == true)
        }

        @Test("unsupportedQRCodeWarningEnabled=false from remote config is written to storage")
        func propagatesUnsupportedQRCodeWarningFalse() async {
            await runStartSDK(resetStorage: { GiniCaptureUserDefaultsStorage.unsupportedQRCodeWarningEnabled = nil },
                              configuration: makeClientConfiguration(unsupportedQRCodeWarningEnabled: false))

            #expect(GiniCaptureUserDefaultsStorage.unsupportedQRCodeWarningEnabled == false)
        }

        @Test("ingredientBrandScreens=[\"Analysis\"] from remote config is written to storage")
        func propagatesIngredientBrandScreensAnalysis() async {
            await runStartSDK(resetStorage: { GiniCaptureUserDefaultsStorage.ingredientBrandScreens = nil },
                              configuration: makeClientConfiguration(ingredientBrandScreens: ["Analysis"]))

            #expect(GiniCaptureUserDefaultsStorage.ingredientBrandScreens == ["Analysis"])
        }

        @Test("ingredientBrandScreens=[] from remote config is written to storage")
        func propagatesIngredientBrandScreensEmpty() async {
            await runStartSDK(resetStorage: { GiniCaptureUserDefaultsStorage.ingredientBrandScreens = nil },
                              configuration: makeClientConfiguration(ingredientBrandScreens: []))

            #expect(GiniCaptureUserDefaultsStorage.ingredientBrandScreens == [])
        }

        @Test("weroQRCodeScanningEnabled=true from remote config is written to storage")
        func propagatesWeroQRCodeScanningEnabledTrue() async {
            await runStartSDK(resetStorage: { GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled = nil },
                              configuration: makeClientConfiguration(weroQRCodeScanningEnabled: true))

            #expect(GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled == true)
        }

        @Test("weroQRCodeScanningEnabled=false from remote config is written to storage")
        func propagatesWeroQRCodeScanningEnabledFalse() async {
            await runStartSDK(resetStorage: { GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled = nil },
                              configuration: makeClientConfiguration(weroQRCodeScanningEnabled: false))

            #expect(GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled == false)
        }

        // MARK: - Helpers

        /**
         Resets the targeted storage slot, boots the SDK with the given
         remote-config response, drains the main-queue dispatch, and tears
         the SDK back down. Shared by every propagation case so the per-flag
         boilerplate stays in one place.
         */
        private func runStartSDK(resetStorage: () -> Void,
                                 configuration: ClientConfiguration) async {
            resetStorage()
            let configService = MockClientConfigurationService(result: .success(configuration))

            let coordinator = GiniBankNetworkingScreenApiCoordinator(
                resultsDelegate: MockCaptureResultsDelegate(),
                configuration: GiniBankConfiguration(),
                documentMetadata: nil,
                trackingDelegate: nil,
                captureNetworkService: MockCaptureNetworkService(),
                configurationService: configService
            )

            _ = coordinator.startSDK(withDocuments: nil, animated: false)

            /// startSDK dispatches the assignments to main asynchronously; hop once to
            /// let the queued block drain before asserting.
            await withCheckedContinuation { continuation in
                DispatchQueue.main.async { continuation.resume() }
            }

            GiniBank.closeCurrentSDK()
        }

        private func makeClientConfiguration(unsupportedQRCodeWarningEnabled: Bool = false,
                                             ingredientBrandScreens: [String] = [],
                                             weroQRCodeScanningEnabled: Bool = false) -> ClientConfiguration {
            ClientConfiguration(clientID: "test",
                                userJourneyAnalyticsEnabled: false,
                                skontoEnabled: false,
                                returnAssistantEnabled: false,
                                transactionDocsEnabled: false,
                                instantPaymentEnabled: false,
                                qrCodeEducationEnabled: false,
                                eInvoiceEnabled: false,
                                savePhotosLocallyEnabled: false,
                                alreadyPaidHintEnabled: false,
                                paymentDueHintEnabled: false,
                                creditNoteHintEnabled: false,
                                paymentScheduleHintEnabled: false,
                                unsupportedQRCodeWarningEnabled: unsupportedQRCodeWarningEnabled,
                                ingredientBrandScreens: ingredientBrandScreens,
                                weroQRCodeScanningEnabled: weroQRCodeScanningEnabled)
        }
    }
}
