//
//  SkontoCoordinator.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK
import GiniBankAPILibrary

protocol SkontoCoordinatorDelegate: AnyObject {
    func didCancelAnalysis(_ coordinator: SkontoCoordinator)
    func didFinishAnalysis(_ coordinator: SkontoCoordinator,
                           _ editedExtractionResult: ExtractionResult?)
    func didTapInvoicePreview(_ coordinator: SkontoCoordinator,
                              _ viewModel: SkontoViewModel)
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

        let skontoViewModel = SkontoViewModel(skontoDiscounts: skontoDiscounts)
        skontoViewModel.delegate = self
        skontoViewController = SkontoViewController(viewModel: skontoViewModel)
    }
}

extension SkontoCoordinator: SkontoViewModelDelegate {
    func didTapInvoicePreview(on viewModel: SkontoViewModel) {
        delegate?.didTapInvoicePreview(self, viewModel)
    }

    // MARK: Temporary remove help action
//    func didTapHelp() {
//        // Should display Help screen
//    }

    func didTapBack() {
        delegate?.didCancelAnalysis(self)
    }

    func didTapProceed(on viewModel: SkontoViewModel) {
        delegate?.didFinishAnalysis(self, viewModel.editedExtractionResult)
    }
}
