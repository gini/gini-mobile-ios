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
    func didTapDocumentPreview(_ coordinator: Coordinator,
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
    func didTapHelp() {
        let helpViewController = SkontoHelpViewController()
        navigationController.pushViewController(helpViewController, animated: true)
    }
    func didTapDocumentPreview(on viewModel: SkontoViewModel) {
        delegate?.didTapDocumentPreview(self, viewModel)
    }

    func didTapBack() {
        delegate?.didCancelAnalysis(self)
    }

    func didTapProceed(on viewModel: SkontoViewModel) {
        var eventProperties: [GiniAnalyticsProperty] = []
        if let edgeCaseAnalyticsValue = viewModel.edgeCase?.analyticsValue {
            eventProperties.append(GiniAnalyticsProperty(key: .edgeCaseType,
                                                         value: edgeCaseAnalyticsValue))
        }
        GiniAnalyticsManager.track(event: .proceedTapped,
                                   screenName: .skonto,
                                   properties: eventProperties)
        delegate?.didFinishAnalysis(self, viewModel.editedExtractionResult)
    }
}
