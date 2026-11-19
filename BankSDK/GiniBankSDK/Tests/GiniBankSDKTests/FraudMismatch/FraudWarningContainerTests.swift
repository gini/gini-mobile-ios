//
//  FraudWarningContainerTests.swift
//  GiniBankSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit
import Testing
@testable import GiniBankSDK

@Suite("FraudWarningContainer")
@MainActor
struct FraudWarningContainerTests {

    @Test("showPicker runs without crashing")
    func showPickerRuns() {
        let viewModel = FraudWarningViewModel(qrIBAN: "qr",
                                              printedIBAN: "pr",
                                              delegate: nil)
        var container = FraudWarningContainer(viewModel: viewModel)
        container.showPicker()
    }

    @Test("handleConfirm fires viewModel.didTapProceed exactly once")
    func handleConfirmFiresProceed() {
        let delegate = CountingVMDelegate()
        let viewModel = FraudWarningViewModel(qrIBAN: "qr",
                                              printedIBAN: "pr",
                                              delegate: delegate)
        var container = FraudWarningContainer(viewModel: viewModel)
        container.handleConfirm()
        #expect(delegate.proceedCount == 1)
        #expect(delegate.cancelCount == 0)
    }
}

private final class CountingVMDelegate: FraudWarningViewModelDelegate {
    var cancelCount = 0
    var proceedCount = 0
    func fraudWarningViewModelDidCancel(_ viewModel: FraudWarningViewModel) { cancelCount += 1 }
    func fraudWarningViewModelDidProceed(_ viewModel: FraudWarningViewModel) { proceedCount += 1 }
}
