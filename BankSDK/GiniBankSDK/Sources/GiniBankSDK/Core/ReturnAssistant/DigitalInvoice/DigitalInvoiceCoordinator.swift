//
//  DigitalInvoiceCoordinator.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import GiniCaptureSDK
import UIKit

protocol DigitalInvoiceCoordinatorDelegate: AnyObject {
    func didCancelAnalysis(_ coordinator: DigitalInvoiceCoordinator)
    func didFinishAnalysis(_ coordinator: DigitalInvoiceCoordinator,
                           invoice: DigitalInvoice?,
                           analysisDelegate: AnalysisDelegate)
}

final class DigitalInvoiceCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    private var digitalInvoiceViewController: DigitalInvoiceViewController?
    private var digitalInvoiceViewModel: DigitalInvoiceViewModel?

    // TODO: This is to cope with the screen coordinator being inadequate at this point to support the return assistant step and needing a refactor.
    private weak var analysisDelegate: AnalysisDelegate?

    weak var delegate: DigitalInvoiceCoordinatorDelegate?
    weak var skontoDelegate: SkontoCoordinatorDelegate?
    var rootViewController: UIViewController {
        guard let digitalInvoiceViewController = digitalInvoiceViewController else {
            return UIViewController()
        }

        return digitalInvoiceViewController
    }

    private var navigationController: UINavigationController

    func start() {
        navigationController.pushViewController(rootViewController, animated: true)
    }

    // swiftlint:disable force_cast
    init(navigationController: UINavigationController,
         digitalInvoice: DigitalInvoice,
         analysisDelegate: AnalysisDelegate) {
        self.navigationController = navigationController
        self.analysisDelegate = analysisDelegate

        let viewModel = DigitalInvoiceViewModel(invoice: digitalInvoice)
        viewModel.delegate = self
        self.digitalInvoiceViewModel = viewModel
        self.digitalInvoiceViewController = DigitalInvoiceViewController(viewModel: viewModel)

        let extractionResult = digitalInvoice.extractionResult
        if let skontoDiscounts = try? SkontoDiscounts(extractions: extractionResult),
           GiniBankConfiguration.shared.skontoEnabled {
            let skontoViewModel = SkontoViewModel(skontoDiscounts: skontoDiscounts,
                                                  isWithDiscountSwitchAvailable: false)
            skontoViewModel.delegate = self
            self.digitalInvoiceViewModel?.skontoViewModel = skontoViewModel
        }
    }

    private func showDigitalInvoiceOnboarding() {
        let onboardingViewControllerName = "digitalInvoiceOnboardingViewController"
        let storyboard = UIStoryboard(name: "DigitalInvoiceOnboarding", bundle: giniBankBundle())
        let digitalInvoiceOnboardingViewController =
        storyboard.instantiateViewController(withIdentifier: onboardingViewControllerName)
        as! DigitalInvoiceOnboardingViewController
        digitalInvoiceOnboardingViewController.delegate = digitalInvoiceViewController
        navigationController.present(digitalInvoiceOnboardingViewController, animated: true)
    }

    // swiftlint:enable force_cast
}

extension DigitalInvoiceCoordinator: DigitalInvoiceViewModelDelagate {
    func shouldShowDigitalInvoiceOnboarding(on viewModel: DigitalInvoiceViewModel) {
        showDigitalInvoiceOnboarding()
    }

    func didTapHelp(on viewModel: DigitalInvoiceViewModel) {
        let digitalInvoiceHelViewModel = DigitalInvoiceHelpViewModel()
        let digitalInvoiceHelpViewController = DigitalInvoiceHelpViewController(viewModel: digitalInvoiceHelViewModel)

        navigationController.pushViewController(digitalInvoiceHelpViewController, animated: true)
    }

    func didTapCancel(on viewModel: DigitalInvoiceViewModel) {
        delegate?.didCancelAnalysis(self)
    }

    func didTapPay(on viewModel: DigitalInvoiceViewModel) {
        if let analysisDelegate = self.analysisDelegate {
            self.delegate?.didFinishAnalysis(self, invoice: viewModel.invoice, analysisDelegate: analysisDelegate)
        }
    }

    func didTapEdit(on viewModel: DigitalInvoiceViewModel, lineItemViewModel: DigitalLineItemTableViewCellViewModel) {
        guard let lineItem = viewModel.invoice?.lineItems[lineItemViewModel.index] else { return }
        let viewModel = EditLineItemViewModel(lineItem: lineItem, index: lineItemViewModel.index)
        viewModel.delegate = self
        let viewController = EditLineItemViewController(lineItemViewModel: viewModel)
        viewController.modalPresentationStyle = .overCurrentContext
        navigationController.present(viewController, animated: true)
    }
}

extension DigitalInvoiceCoordinator: EditLineItemViewModelDelegate {
    func didSave(lineItem: DigitalInvoice.LineItem, on viewModel: EditLineItemViewModel) {
        guard let invoice = digitalInvoiceViewModel?.invoice,
        invoice.lineItems.indices.contains(viewModel.index) else {
            return
        }

        digitalInvoiceViewModel?.invoice?.lineItems[viewModel.index] = lineItem
        if !viewModel.itemsChanged.isEmpty {
            let itemRawValues = viewModel.itemsChanged.map { return $0.rawValue }
            let eventProperties = [GiniAnalyticsProperty(key: .itemsChanged,
                                                         value: itemRawValues)]
            GiniAnalyticsManager.track(event: .saveTapped,
                                       screenName: .editReturnAssistant,
                                       properties: eventProperties)
        }

        digitalInvoiceViewController?.updateValues()
        navigationController.dismiss(animated: true) { [weak self] in
            self?.digitalInvoiceViewController?.sendAnalyticsScreenShown()
        }
    }

    func didCancel(on viewModel: EditLineItemViewModel) {
        GiniAnalyticsManager.track(event: .closeTapped, screenName: .editReturnAssistant)
        navigationController.dismiss(animated: true) { [weak self] in
            self?.digitalInvoiceViewController?.sendAnalyticsScreenShown()
        }
    }
}

extension DigitalInvoiceCoordinator: SkontoViewModelDelegate {
    func didTapHelp() {
        let helpViewController = SkontoHelpViewController()
        navigationController.pushViewController(helpViewController, animated: true)
    }

    func didTapBack() {
        self.navigationController.popViewController(animated: true)
    }

    func didTapDocumentPreview(on viewModel: SkontoViewModel) {
        skontoDelegate?.didTapDocumentPreview(self, viewModel)
    }
}
