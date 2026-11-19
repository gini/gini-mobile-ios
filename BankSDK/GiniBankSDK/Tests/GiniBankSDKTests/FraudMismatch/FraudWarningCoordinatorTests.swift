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
@testable import GiniBankSDK

@Suite("FraudWarningCoordinator")
@MainActor
struct FraudWarningCoordinatorTests {

    @Test("start() returns a UIHostingController<FraudWarningContainer> with fullScreen + isModalInPresentation")
    func startReturnsConfiguredHostingController() {
        let coordinator = FraudWarningCoordinator(qrIBAN: "PL12 1000 0111 0100 1000",
                                                  printedIBAN: "DE89 3704 0044 0532 0130 00",
                                                  delegate: nil)

        let hosting = coordinator.start()

        #expect(hosting is UIHostingController<FraudWarningContainer>)
        #expect(hosting.modalPresentationStyle == .fullScreen)
        #expect(hosting.isModalInPresentation == true)
    }

    @Test("viewModel didTapCancel forwards to coordinator delegate")
    func viewModelCancelForwards() {
        let delegate = Mock()
        let coordinator = FraudWarningCoordinator(qrIBAN: "PL12 1000 0111 0100 1000",
                                                  printedIBAN: "DE89 3704 0044 0532 0130 00",
                                                  delegate: delegate)

        coordinator.viewModel.didTapCancel()

        #expect(delegate.cancelCount == 1)
        #expect(delegate.proceedCount == 0)
    }

    @Test("viewModel didTapProceed forwards to coordinator delegate")
    func viewModelProceedForwards() {
        let delegate = Mock()
        let coordinator = FraudWarningCoordinator(qrIBAN: "PL12 1000 0111 0100 1000",
                                                  printedIBAN: "DE89 3704 0044 0532 0130 00",
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
