//
//  GiniCaptureResultsDelegateDefaultImplTests.swift
//  GiniCapture_Tests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest
import GiniBankAPILibrary
@testable import GiniCaptureSDK

/// Guards the source-compatibility contract for
/// `GiniCaptureResultsDelegate.giniCaptureDidRequestSchedulePayment(result:)`
/// added in 4.5.0 (PP-3497). The method is `@objc optional` so integrators
/// upgrading 4.4.x → 4.5.0 whose conformers implement only the three pre-4.5
/// methods keep compiling; the SDK dispatches to it through Obj-C optional
/// method resolution and no-ops when the conformer does not implement it.
final class GiniCaptureResultsDelegateDefaultImplTests: XCTestCase {

    /// R1 — the fact that this file compiles IS the assertion: the
    /// private `Pre45CaptureResultsDelegate` below conforms to
    /// `GiniCaptureResultsDelegate` while implementing only the three
    /// pre-4.5 methods. If the fourth method loses `@objc optional`, this
    /// file stops building. The `XCTAssertTrue(true)` line is intentional
    /// and documents that intent.
    func test_optionalRequirement_compilesOnConformer_withOnlyPre45Methods() {
        let sut: GiniCaptureResultsDelegate = Pre45CaptureResultsDelegate()
        XCTAssertNotNil(sut, "The pre-4.5 conformer must instantiate as GiniCaptureResultsDelegate")
        XCTAssertTrue(true)
    }

    /// R2 — an unimplemented optional method resolves to `nil` at the
    /// call site. This is the runtime proof that the SDK's optional
    /// dispatch (`resultsDelegate?.giniCaptureDidRequestSchedulePayment?(...)`)
    /// silently no-ops for conformers who did not adopt Schedule Payment.
    func test_optionalDispatch_isNil_whenNotImplemented() {
        let sut: GiniCaptureResultsDelegate = Pre45CaptureResultsDelegate()
        let fixture = AnalysisResult(extractions: [:],
                                     lineItems: nil,
                                     images: [],
                                     document: nil,
                                     candidates: [:])

        let dispatched: Void? = sut.giniCaptureDidRequestSchedulePayment?(result: fixture)

        XCTAssertNil(dispatched,
                     "Unimplemented @objc optional method must resolve to nil at the call site")
    }

    /// R3 — a conformer that DOES implement the method receives the
    /// callback through the same optional-dispatch path. Complements the
    /// broader `NetworkingScreenApiCoordinatorTests+SchedulePaymentHint`
    /// suite in BankSDK by pinning the CaptureSDK-side contract.
    func test_optionalDispatch_invokesImplementation_whenPresent() {
        let sut: GiniCaptureResultsDelegate = SchedulePaymentAwareDelegate()
        let fixture = AnalysisResult(extractions: [:],
                                     lineItems: nil,
                                     images: [],
                                     document: nil,
                                     candidates: [:])

        let dispatched: Void? = sut.giniCaptureDidRequestSchedulePayment?(result: fixture)

        XCTAssertNotNil(dispatched,
                        "Implemented @objc optional method must resolve to a non-nil call")
        XCTAssertTrue((sut as? SchedulePaymentAwareDelegate)?.didReceiveSchedule == true,
                      "Implementation must run when present")
    }
}

/// Private test double that mirrors an integrator's 4.4.x conformer: it
/// implements ONLY the three pre-4.5 protocol methods and relies on the
/// `@objc optional` fourth method being absent.
private final class Pre45CaptureResultsDelegate: NSObject, GiniCaptureResultsDelegate {
    func giniCaptureAnalysisDidFinishWith(result: AnalysisResult) {}
    func giniCaptureDidCancelAnalysis() {}
    func giniCaptureDidEnterManually() {}
}

/// Private test double that mirrors an integrator adopting Schedule
/// Payment on 4.5.0: it implements all four methods including the optional
/// one.
private final class SchedulePaymentAwareDelegate: NSObject, GiniCaptureResultsDelegate {
    private(set) var didReceiveSchedule = false

    func giniCaptureAnalysisDidFinishWith(result: AnalysisResult) {}
    func giniCaptureDidCancelAnalysis() {}
    func giniCaptureDidEnterManually() {}
    func giniCaptureDidRequestSchedulePayment(result: AnalysisResult) {
        didReceiveSchedule = true
    }
}
