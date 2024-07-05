//
//  SkontoCoordinator.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import GiniCaptureSDK
import UIKit

protocol SkontoCoordinatorDelegate: AnyObject {
    func didCancelAnalysis(_ coordinator: SkontoCoordinator)
    func didFinishAnalysis(_ coordinator: SkontoCoordinator)
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

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController

        let skontoViewModel = SkontoViewModel(isSkontoApplied: true,
                                              skontoValue: 3.0,
                                              date: Date(),
                                              priceWithoutSkonto: .init(value: 99.99, currencyCode: "EUR"))

        skontoViewModel.delegate = self
        skontoViewController = SkontoViewController(viewModel: skontoViewModel)
    }
}

extension SkontoCoordinator: SkontoViewModelDelegate {
    func didTapHelp() {
        // Should display Help screen
    }

    func didTapBack() {
        delegate?.didCancelAnalysis(self)
    }

    func didTapProceed(on viewModel: SkontoViewModel) {
        // TODO: maybe we need to do something more
        delegate?.didFinishAnalysis(self)
    }
}
