//
//  GiniCaptureResultsDelegateDefaultImplTests.swift
//  GiniCapture_Tests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest
import GiniBankAPILibrary
@testable import GiniCaptureSDK

/// Guards the source-compatibility default implementation of
/// `GiniCaptureResultsDelegate.giniCaptureDidRequestSchedulePayment(result:)`
/// added in 4.5.1 (PP-3497). Integrators upgrading 4.4.x → 4.5.1 whose
/// conformers implement only the three pre-4.5 methods must keep
/// compiling and get a no-op callback.
final class GiniCaptureResultsDelegateDefaultImplTests: XCTestCase {

    /// R1 — the fact that this file compiles IS the assertion: the
    /// private `Pre45CaptureResultsDelegate` below conforms to
    /// `GiniCaptureResultsDelegate` while implementing only the three
    /// pre-4.5 methods. If the default extension regresses, this file
    /// stops building. The `XCTAssertTrue(true)` line is intentional and
    /// documents that intent.
    func test_defaultImplementation_compilesOnConformer_withOnlyPre45Methods() {
        let sut: GiniCaptureResultsDelegate = Pre45CaptureResultsDelegate()
        XCTAssertNotNil(sut, "The pre-4.5 conformer must instantiate as GiniCaptureResultsDelegate")
        // Compile-time assertion: if the default extension is missing,
        // Pre45CaptureResultsDelegate no longer conforms and this file
        // fails to build.
        XCTAssertTrue(true)
    }

    /// R2 — the default implementation is a no-op: calling it on a
    /// conformer that does NOT override the method leaves the
    /// observable state (`didReceiveSchedule`) untouched and does not
    /// crash.
    func test_defaultImplementation_isNoOp_whenNotOverridden() {
        let sut = Pre45CaptureResultsDelegate()
        let fixture = AnalysisResult(extractions: [:],
                                     lineItems: nil,
                                     images: [],
                                     document: nil,
                                     candidates: [:])

        sut.giniCaptureDidRequestSchedulePayment(result: fixture)

        XCTAssertFalse(sut.didReceiveSchedule,
                       "Default no-op must not touch conformer state")
    }
}

/// Private test double that mirrors an integrator's 4.4.x conformer: it
/// implements ONLY the three pre-4.5 protocol methods and relies on the
/// default extension for `giniCaptureDidRequestSchedulePayment(result:)`.
private final class Pre45CaptureResultsDelegate: NSObject, GiniCaptureResultsDelegate {
    private(set) var didReceiveSchedule = false

    func giniCaptureAnalysisDidFinishWith(result: AnalysisResult) {}
    func giniCaptureDidCancelAnalysis() {}
    func giniCaptureDidEnterManually() {}
}
