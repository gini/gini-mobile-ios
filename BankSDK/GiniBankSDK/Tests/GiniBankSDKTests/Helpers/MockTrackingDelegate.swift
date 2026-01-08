//
//  MockTrackingDelegate.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

@testable import GiniBankAPILibrary
@testable import GiniCaptureSDK

class MockTrackingDelegate: GiniCaptureTrackingDelegate {
    func onOnboardingScreenEvent(event: Event<OnboardingScreenEventType>) {
        // This method will remain empty; no implementation is needed.
    }

    func onCameraScreenEvent(event: Event<CameraScreenEventType>) {
        // This method will remain empty; no implementation is needed.
    }

    func onReviewScreenEvent(event: Event<ReviewScreenEventType>) {
        // This method will remain empty; no implementation is needed.
    }

    func onAnalysisScreenEvent(event: Event<AnalysisScreenEventType>) {
        // This method will remain empty; no implementation is needed.
    }
}

