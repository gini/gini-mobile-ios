//
//  FraudWarningCoordinator.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import UIKit
import SwiftUI
import GiniUtilites

/**
 Hosting controller for the fraud warning that conforms to
 `GiniBottomSheetPresentable`. Presented via
 `configureBottomSheet(shouldIncludeLargeDetent: true) + present(…)`;
 `presentAsBottomSheet(from:)` isn't used because it hardcodes `.medium`.
 */
final class FraudWarningBottomSheetController: UIHostingController<FraudWarningContainer>, GiniBottomSheetPresentable {

    var shouldShowDragIndicator: Bool { false }
    var shouldShowInFullScreenInLandscapeMode: Bool { false }
}

/**
 Owns the fraud warning ViewModel + hosting controller and forwards user
 intent upward via `FraudWarningCoordinatorDelegate`. The parent coordinator
 is responsible for presenting / dismissing the returned view controller and
 for keeping the `FraudWarningCoordinator` retained for the presentation.
 */
@MainActor
final class FraudWarningCoordinator: FraudWarningViewModelDelegate {

    /** Weak to avoid a retain cycle with the parent coordinator. */
    weak var delegate: FraudWarningCoordinatorDelegate?

    let viewModel: FraudWarningViewModel

    init(content: FraudWarningContent,
         delegate: FraudWarningCoordinatorDelegate? = nil) {
        self.delegate = delegate
        self.viewModel = FraudWarningViewModel(content: content,
                                               delegate: nil)
        self.viewModel.delegate = self
    }

    /**
     `isModalInPresentation = true` blocks swipe-to-dismiss so only Cancel
     and Proceed resolve the warning — otherwise the parked delivery tuple
     would leak with no terminal callback.
     */
    func start() -> GiniBottomSheetViewController {
        let container = FraudWarningContainer(viewModel: viewModel)
        let hosting = FraudWarningBottomSheetController(rootView: container)
        hosting.isModalInPresentation = true
        return hosting
    }

    // MARK: - FraudWarningViewModelDelegate

    func fraudWarningViewModelDidCancel(_: FraudWarningViewModel) {
        delegate?.fraudWarningCoordinatorDidCancel(self)
    }

    func fraudWarningViewModelDidProceed(_: FraudWarningViewModel) {
        delegate?.fraudWarningCoordinatorDidProceed(self)
    }
}
