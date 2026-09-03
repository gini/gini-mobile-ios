//
//  GiniCaptureResultsDelegateDefaultImplTests.swift
//  GiniCapture_Tests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest
import GiniBankAPILibrary
@testable import GiniCaptureSDK

/**
 Guards the `@objc optional` contract on `giniCaptureDidRequestSchedulePayment(result:)`
 added in 4.5.0 (PP-3497): pre-4.5 conformers keep compiling; optional dispatch no-ops
 when unimplemented and invokes the method when present.
 */
final class GiniCaptureResultsDelegateDefaultImplTests: XCTestCase {

    /** R1 — if the fourth method loses `@objc optional`, this file fails to build. */
    func test_optionalRequirement_compilesOnConformer_withOnlyPre45Methods() {
        let sut: GiniCaptureResultsDelegate = Pre45CaptureResultsDelegate()
        XCTAssertNotNil(sut)
    }

    /** R2 — an unimplemented optional method resolves to `nil` at the call site. */
    func test_optionalDispatch_isNil_whenNotImplemented() {
        let sut: GiniCaptureResultsDelegate = Pre45CaptureResultsDelegate()
        let fixture = makeFixture()

        let dispatched: Void? = sut.giniCaptureDidRequestSchedulePayment?(result: fixture)

        XCTAssertNil(dispatched)
    }

    /** R3 — an implementing conformer receives the callback via optional dispatch. */
    func test_optionalDispatch_invokesImplementation_whenPresent() {
        let sut = SchedulePaymentAwareDelegate()
        let delegate: GiniCaptureResultsDelegate = sut
        let fixture = makeFixture()

        delegate.giniCaptureDidRequestSchedulePayment?(result: fixture)

        XCTAssertTrue(sut.didReceiveSchedule)
    }

    private func makeFixture() -> AnalysisResult {
        AnalysisResult(extractions: [:],
                       lineItems: nil,
                       images: [],
                       document: nil,
                       candidates: [:])
    }
}

/** Test double: 4.4.x-shape conformer — implements only the three pre-4.5 methods. */
private final class Pre45CaptureResultsDelegate: NSObject, GiniCaptureResultsDelegate {
    func giniCaptureAnalysisDidFinishWith(result: AnalysisResult) {}
    func giniCaptureDidCancelAnalysis() {}
    func giniCaptureDidEnterManually() {}
}

/** Test double: Schedule-Payment adopter — implements all four methods. */
private final class SchedulePaymentAwareDelegate: NSObject, GiniCaptureResultsDelegate {
    private(set) var didReceiveSchedule = false

    func giniCaptureAnalysisDidFinishWith(result: AnalysisResult) {}
    func giniCaptureDidCancelAnalysis() {}
    func giniCaptureDidEnterManually() {}
    func giniCaptureDidRequestSchedulePayment(result: AnalysisResult) {
        didReceiveSchedule = true
    }
}
