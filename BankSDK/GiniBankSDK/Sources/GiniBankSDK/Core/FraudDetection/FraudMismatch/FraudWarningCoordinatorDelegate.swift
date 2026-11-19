//
//  FraudWarningCoordinatorDelegate.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation

/**
 Parent-coordinator contract for `FraudWarningCoordinator`.

 The parent coordinator conforms to this and uses the callbacks to resume the
 enclosing flow once the user resolves the fraud warning. Exactly one callback
 fires per presentation; `coordinator` lets the receiver assert the sender's
 identity and release any references it is holding.
 */
protocol FraudWarningCoordinatorDelegate: AnyObject {

    /** User tapped Cancel — the parent coordinator should end the flow. */
    func fraudWarningCoordinatorDidCancel(_ coordinator: FraudWarningCoordinator)

    /** User tapped Proceed — the parent coordinator should continue the flow. */
    func fraudWarningCoordinatorDidProceed(_ coordinator: FraudWarningCoordinator)
}
