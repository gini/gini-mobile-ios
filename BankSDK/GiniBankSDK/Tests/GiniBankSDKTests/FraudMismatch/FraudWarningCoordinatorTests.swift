//
//  FraudWarningCoordinatorTests.swift
//  GiniBankSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit
import Testing
import GiniUtilites
@testable import GiniBankSDK

@Suite("FraudWarningCoordinator")
@MainActor
struct FraudWarningCoordinatorTests {

    private static let stubQRIBAN = "PL12 1000 0111 0100 1000"
    private static let stubPrintedIBAN = "DE89 3704 0044 0532 0130 00"

    @Test("start() returns a GiniBottomSheetPresentable hosting controller with isModalInPresentation")
    func startReturnsConfiguredHostingController() {
        let coordinator = FraudWarningCoordinator(qrIBAN: Self.stubQRIBAN,
                                                  printedIBAN: Self.stubPrintedIBAN,
                                                  delegate: nil)

        let hosting: GiniBottomSheetViewController = coordinator.start()

        #expect(hosting is FraudWarningBottomSheetController)
        #expect(hosting is UIHostingController<FraudWarningContainer>)
        #expect(hosting.isModalInPresentation == true)
        #expect(hosting.shouldShowDragIndicator == true)
    }

    @Test("init forwards qrIBAN and printedIBAN to the constructed VM")
    func initForwardsIBANsToViewModel() {
        let coordinator = FraudWarningCoordinator(qrIBAN: Self.stubQRIBAN,
                                                  printedIBAN: Self.stubPrintedIBAN,
                                                  delegate: nil)

        #expect(coordinator.viewModel.qrIBAN == Self.stubQRIBAN)
        #expect(coordinator.viewModel.printedIBAN == Self.stubPrintedIBAN)
    }

    @Test("viewModel didTapCancel forwards to coordinator delegate")
    func viewModelCancelForwards() {
        let delegate = Mock()
        let coordinator = FraudWarningCoordinator(qrIBAN: Self.stubQRIBAN,
                                                  printedIBAN: Self.stubPrintedIBAN,
                                                  delegate: delegate)

        coordinator.viewModel.didTapCancel()

        #expect(delegate.cancelCount == 1)
        #expect(delegate.proceedCount == 0)
    }

    @Test("viewModel didTapProceed forwards to coordinator delegate")
    func viewModelProceedForwards() {
        let delegate = Mock()
        let coordinator = FraudWarningCoordinator(qrIBAN: Self.stubQRIBAN,
                                                  printedIBAN: Self.stubPrintedIBAN,
                                                  delegate: delegate)

        coordinator.viewModel.didTapProceed()

        #expect(delegate.proceedCount == 1)
        #expect(delegate.cancelCount == 0)
    }
}

private final class Mock: FraudWarningCoordinatorDelegate {
    var cancelCount = 0
    var proceedCount = 0

    func fraudWarningCoordinatorDidCancel(_ coordinator: FraudWarningCoordinator) {
        cancelCount += 1
    }

    func fraudWarningCoordinatorDidProceed(_ coordinator: FraudWarningCoordinator) {
        proceedCount += 1
    }
}
