//
//  File.swift
//  
//
//  Created by David Vizaknai on 24.02.2023.
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
    // Remove ASAP
    private var analysisDelegate: AnalysisDelegate

    weak var delegate: DigitalInvoiceCoordinatorDelegate?
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
        digitalInvoiceViewModel = viewModel
        digitalInvoiceViewController = DigitalInvoiceViewController(viewModel: digitalInvoiceViewModel!)
    }

    private func showDigitalInvoiceOnboarding() {
        let onboardingViewControllerName = "digitalInvoiceOnboardingViewController"
        let storyboard = UIStoryboard(name: "DigitalInvoiceOnboarding", bundle: giniBankBundle())
        let digitalInvoiceOnboardingViewController =
        storyboard.instantiateViewController(withIdentifier: onboardingViewControllerName)
        as! DigitalInvoiceOnboardingViewController

        navigationController.present(digitalInvoiceOnboardingViewController, animated: true)
    }
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
        delegate?.didFinishAnalysis(self, invoice: viewModel.invoice, analysisDelegate: analysisDelegate)
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
        guard let invoice = digitalInvoiceViewModel?.invoice else { return }

        if invoice.lineItems.indices.contains(viewModel.index) {
            self.digitalInvoiceViewModel?.invoice?.lineItems[viewModel.index] = lineItem
        }

        digitalInvoiceViewController?.updateValues()

        navigationController.dismiss(animated: true)
    }

    func didCancel(on viewModel: EditLineItemViewModel) {
        navigationController.dismiss(animated: true)
    }
}
