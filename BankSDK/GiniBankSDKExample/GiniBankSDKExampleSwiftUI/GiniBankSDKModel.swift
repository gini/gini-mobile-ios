//
//  GiniBankSDKModel.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import GiniBankAPILibrary
import GiniBankSDK
import GiniCaptureSDK
import SwiftUI

protocol GiniBankSDKDelegate: AnyObject {
    func captureAnalysisDidFinishWithResults()
    func captureAnalysisDidFinishWithoutResults()
    func captureCanceled()
}

final class GiniBankSDKModel: NSObject {

    public weak var delegate: GiniBankSDKDelegate?

    var giniContentView: some View {
        return AnyView(GiniView(viewModel: self))
    }

    private func createGiniBankConfiguration() -> GiniBankConfiguration {
        let configuration = GiniBankConfiguration.shared
        // General settings
        configuration.flashToggleEnabled = true
        configuration.multipageEnabled = true
        configuration.qrCodeScanningEnabled = true
        configuration.fileImportSupportedTypes = .pdf_and_images
        // By default, the flash is disabled.
        configuration.flashOnByDefault = false
        configuration.statusBarStyle = .default

        return configuration
    }
    var trackingDelegate = TrackingDelegate()
    func createGiniUIViewController() -> UIViewController {
        let configuration = createGiniBankConfiguration()
        let client = Client(id: clientID, secret: clientPassword, domain: clientDomain)
        return GiniBank.viewController(withClient: client,
                                       importedDocuments: [],
                                       configuration: configuration,
                                       resultsDelegate: self,
                                       documentMetadata: nil,
                                       api: .default,
                                       userApi: .default,
                                       trackingDelegate: trackingDelegate)
    }
}

// MARK: - GiniCaptureResultsDelegate
extension GiniBankSDKModel: GiniCaptureResultsDelegate {

    func giniCaptureAnalysisDidFinishWith(result: GiniCaptureSDK.AnalysisResult) {
        delegate?.captureAnalysisDidFinishWithResults()
    }

    func giniCaptureDidCancelAnalysis() {
        delegate?.captureCanceled()
    }

    func giniCaptureAnalysisDidFinishWithoutResults(_ showingNoResultsScreen: Bool) {
        delegate?.captureAnalysisDidFinishWithoutResults()
    }

    func giniCaptureDidEnterManually() {
        delegate?.captureCanceled()
    }
}

// MARK: - GiniCaptureTrackingDelegate
class TrackingDelegate: GiniCaptureTrackingDelegate {

    func onAnalysisScreenEvent(event: Event<AnalysisScreenEventType>) {
        print("✏️ Analysis: \(event.type.rawValue), info: \(event.info ?? [:])")
    }

    func onOnboardingScreenEvent(event: Event<OnboardingScreenEventType>) {
        print("✏️ Onboarding: \(event.type.rawValue)")
    }

    func onCameraScreenEvent(event: Event<CameraScreenEventType>) {
        print("✏️ Camera: \(event.type.rawValue)")
    }

    func onReviewScreenEvent(event: Event<ReviewScreenEventType>) {
        print("✏️ Review: \(event.type.rawValue)")
    }
}

