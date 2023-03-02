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
    private var didShowOnboardInCurrentSession = false

    private var onboardingWillBeShown: Bool {
        let key = "ginibank.defaults.digitalInvoiceOnboardingShowed"
        return UserDefaults.standard.object(forKey: key) == nil ? true : false
    }

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
        if onboardingWillBeShown && !didShowOnboardInCurrentSession {
            let storyboard = UIStoryboard(name: "DigitalInvoiceOnboarding", bundle: giniBankBundle())
            let digitalInvoiceOnboardingViewController = storyboard.instantiateViewController(withIdentifier: "digitalInvoiceOnboardingViewController") as! DigitalInvoiceOnboardingViewController

            navigationController.present(digitalInvoiceOnboardingViewController, animated: true)
            didShowOnboardInCurrentSession = true
        }
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
        let viewController = LineItemDetailsViewController()
        viewController.lineItem = viewModel.invoice?.lineItems[lineItemViewModel.index]
        viewController.returnReasons = viewModel.invoice?.returnReasons
        viewController.lineItemIndex = lineItemViewModel.index
        viewController.returnAssistantConfiguration = ReturnAssistantConfiguration.shared
        viewController.delegate = self

        navigationController.pushViewController(viewController, animated: true)
    }
}

extension DigitalInvoiceCoordinator: LineItemDetailsViewControllerDelegate {
    func didSaveLineItem(lineItemDetailsViewController: LineItemDetailsViewController, lineItem: DigitalInvoice.LineItem, index: Int, shouldPopViewController: Bool) {

        if shouldPopViewController {
            navigationController.popViewController(animated: true)
        }
        guard let invoice = digitalInvoiceViewModel?.invoice else { return }

        if invoice.lineItems.indices.contains(index) {
            self.digitalInvoiceViewModel?.invoice?.lineItems[index] = lineItem
        } else {
            self.digitalInvoiceViewModel?.invoice?.lineItems.append(lineItem)
        }

        digitalInvoiceViewController?.updateValues()
    }
}
