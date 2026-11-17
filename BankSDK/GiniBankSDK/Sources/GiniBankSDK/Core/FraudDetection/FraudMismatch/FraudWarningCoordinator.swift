//
//  FraudWarningCoordinator.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import UIKit
import SwiftUI

/**
 Owns the fraud warning screen's ViewModel and the `UIHostingController` that
 hosts the SwiftUI composition, and forwards user intent to its parent via
 `FraudWarningCoordinatorDelegate`.

 Acts as the ViewModel's own delegate so the Coordinator is the single point
 that observes button taps and reports them upwards; the parent coordinator
 is responsible for presenting / dismissing the returned view controller and
 for keeping the `FraudWarningCoordinator` retained for the lifetime of the
 presentation.
 */
@MainActor
final class FraudWarningCoordinator: FraudWarningViewModelDelegate {

    /** The parent that receives user-resolution callbacks. Weak to avoid a cycle. */
    weak var delegate: FraudWarningCoordinatorDelegate?

    /** The ViewModel backing the hosted SwiftUI view. */
    let viewModel: FraudWarningViewModel

    /**
     - Parameter delegate: the parent that will be notified when the user
       resolves the warning. Retained weakly.
     */
    init(delegate: FraudWarningCoordinatorDelegate?) {
        self.delegate = delegate
        self.viewModel = FraudWarningViewModel(delegate: nil)
        self.viewModel.delegate = self
    }

    /**
     Builds the modal `UIViewController` that presents the fraud warning.

     - Returns: a `UIHostingController<FraudWarningContainer>` configured for
       `.fullScreen` presentation with `isModalInPresentation = true` so the
       user cannot dismiss the modal with a swipe — only the Cancel and
       Proceed buttons resolve it.
     */
    func start() -> UIViewController {
        let container = FraudWarningContainer(viewModel: viewModel)
        let hosting = UIHostingController(rootView: container)
        hosting.modalPresentationStyle = .fullScreen
        hosting.isModalInPresentation = true
        return hosting
    }

    // MARK: - FraudWarningViewModelDelegate

    func fraudWarningViewModelDidCancel(_ viewModel: FraudWarningViewModel) {
        delegate?.fraudWarningCoordinatorDidCancel(self)
    }

    func fraudWarningViewModelDidProceed(_ viewModel: FraudWarningViewModel) {
        delegate?.fraudWarningCoordinatorDidProceed(self)
    }
}
