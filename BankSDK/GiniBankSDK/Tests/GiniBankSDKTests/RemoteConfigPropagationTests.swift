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

@Suite("Remote client-configuration propagation to GiniCaptureUserDefaultsStorage", .serialized)
@MainActor
struct RemoteConfigPropagationTests {

    init() {
        _GINIBANKAPILIBRARY_DISABLE_KEYCHAIN_PRECONDITION_FAILURE = true
    }

    @Test("unsupportedQRCodeWarningEnabled=true from remote config is written to storage")
    func propagatesUnsupportedQRCodeWarningTrue() async {
        await runStartSDK(withUnsupportedQRCodeWarningEnabled: true)

        #expect(GiniCaptureUserDefaultsStorage.unsupportedQRCodeWarningEnabled == true)
    }

    @Test("unsupportedQRCodeWarningEnabled=false from remote config is written to storage")
    func propagatesUnsupportedQRCodeWarningFalse() async {
        await runStartSDK(withUnsupportedQRCodeWarningEnabled: false)

        #expect(GiniCaptureUserDefaultsStorage.unsupportedQRCodeWarningEnabled == false)
    }

    // MARK: - Helpers

    private func runStartSDK(withUnsupportedQRCodeWarningEnabled flag: Bool) async {
        GiniCaptureUserDefaultsStorage.unsupportedQRCodeWarningEnabled = nil

        let configuration = makeClientConfiguration(unsupportedQRCodeWarningEnabled: flag)
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

        // startSDK dispatches the assignments to main asynchronously; hop once to
        // let the queued block drain before asserting.
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async { continuation.resume() }
        }

        GiniBank.closeCurrentSDK()
    }

    private func makeClientConfiguration(unsupportedQRCodeWarningEnabled: Bool) -> ClientConfiguration {
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
                            paymentScheduleHintEnabled: false,
                            unsupportedQRCodeWarningEnabled: unsupportedQRCodeWarningEnabled)
    }
}
