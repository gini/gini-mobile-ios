//
//  FraudWarningViewModel.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation

/**
 ViewModel for the fraud warning screen.

 Carries user intent (tap Cancel / tap Proceed) up to the owning Coordinator
 via a weak delegate. Imports no UIKit — binding to SwiftUI happens through
 `@ObservedObject` at the view layer. The VM is intentionally "dumb": it
 does not track whether a resolution is already in flight, because the single-
 terminal-callback guarantee for the SDK's results delegate is enforced one
 layer above this type.
 */
@MainActor
final class FraudWarningViewModel: ObservableObject {

    /** Parent that receives tap callbacks. Weak to avoid a retain cycle with the Coordinator. */
    weak var delegate: FraudWarningViewModelDelegate?

    /**
     - Parameter delegate: the Coordinator that will be notified of taps.
       Retained weakly; the Coordinator is responsible for its own lifetime.
     */
    init(delegate: FraudWarningViewModelDelegate?) {
        self.delegate = delegate
    }

    /** User tapped the Cancel button. Forwards to the delegate; does no local state change. */
    func didTapCancel() {
        delegate?.fraudWarningViewModelDidCancel(self)
    }

    /** User tapped the Proceed button. Forwards to the delegate; does no local state change. */
    func didTapProceed() {
        delegate?.fraudWarningViewModelDidProceed(self)
    }
}
