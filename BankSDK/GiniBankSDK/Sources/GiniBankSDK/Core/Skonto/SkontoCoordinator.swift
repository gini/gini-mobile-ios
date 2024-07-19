//
//  SkontoCoordinator.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import GiniCaptureSDK
import UIKit
import GiniBankAPILibrary

protocol SkontoCoordinatorDelegate: AnyObject {
    func didCancelAnalysis(_ coordinator: SkontoCoordinator)
    func didFinishAnalysis(_ coordinator: SkontoCoordinator,
                           _ editiedExtractionResult: ExtractionResult?)
}

final class SkontoCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    private var skontoViewController: SkontoViewController?

    weak var delegate: SkontoCoordinatorDelegate?

    var rootViewController: UIViewController {
        guard let skontoViewController else {
            return UIViewController()
        }

        return skontoViewController
    }

    private var navigationController: UINavigationController

    func start() {
        navigationController.pushViewController(rootViewController, animated: true)
    }

    init(_ navigationController: UINavigationController,
         _ skontoDiscounts: SkontoDiscounts) {
        self.navigationController = navigationController

        let skontoViewModel = SkontoViewModel(skontoDiscounts: skontoDiscounts,
                                              amountToPay: skontoDiscounts.totalAmountToPay)
        skontoViewModel.delegate = self
        skontoViewController = SkontoViewController(viewModel: skontoViewModel)
    }
}

extension SkontoCoordinator: SkontoViewModelDelegate {
    // MARK: Temporary remove help action
//    func didTapHelp() {
//        // Should display Help screen
//    }

    func didTapBack() {
        delegate?.didCancelAnalysis(self)
    }

    func didTapProceed(on viewModel: SkontoViewModel) {
        delegate?.didFinishAnalysis(self, viewModel.editiedExtractionResult)
    }
}
