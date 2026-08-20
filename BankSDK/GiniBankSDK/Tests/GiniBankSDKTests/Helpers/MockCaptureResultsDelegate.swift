//
//  MockCaptureResultsDelegate.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

@testable import GiniBankAPILibrary
@testable import GiniCaptureSDK

class MockCaptureResultsDelegate: GiniCaptureResultsDelegate {
    private(set) var closeCalled: Bool = false
    private(set) var scheduleRequestedResults: [AnalysisResult] = []

    func giniCaptureAnalysisDidFinishWith(result: AnalysisResult) {
        // This method will remain empty; no implementation is needed.
    }

    func giniCaptureDidCancelAnalysis() {
        closeCalled = true
    }

    func giniCaptureDidEnterManually() {
        // This method will remain empty; no implementation is needed.
    }

    func giniCaptureDidRequestSchedulePayment(result: AnalysisResult) {
        scheduleRequestedResults.append(result)
    }
}
