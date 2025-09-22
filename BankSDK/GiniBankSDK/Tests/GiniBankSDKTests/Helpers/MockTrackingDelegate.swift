//
//  MockTrackingDelegate.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

@testable import GiniBankAPILibrary
@testable import GiniCaptureSDK

class MockTrackingDelegate: GiniCaptureTrackingDelegate {
    func onOnboardingScreenEvent(event: Event<OnboardingScreenEventType>) {
    }

    func onCameraScreenEvent(event: Event<CameraScreenEventType>) {
    }

    func onReviewScreenEvent(event: Event<ReviewScreenEventType>) {
    }

    func onAnalysisScreenEvent(event: Event<AnalysisScreenEventType>) {
    }
}

