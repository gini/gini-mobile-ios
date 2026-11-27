//
//  FraudWarningViewModelDelegate.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation

/**
 Coordinator-facing contract for `FraudWarningViewModel`, implemented by the
 owning `FraudWarningCoordinator`.

 Each method fires exactly once per user tap; `viewModel` lets the receiver
 assert the sender's identity (Sonar `swift:S1172`). The ViewModel itself
 does not debounce taps — the integration seam above the Coordinator is
 where single-callback guarantees for the integrator are enforced.
 */
@MainActor
protocol FraudWarningViewModelDelegate: AnyObject {

    /** User tapped the Cancel button on the fraud warning. */
    func fraudWarningViewModelDidCancel(_ viewModel: FraudWarningViewModel)

    /** User tapped the Proceed button on the fraud warning. */
    func fraudWarningViewModelDidProceed(_ viewModel: FraudWarningViewModel)
}
