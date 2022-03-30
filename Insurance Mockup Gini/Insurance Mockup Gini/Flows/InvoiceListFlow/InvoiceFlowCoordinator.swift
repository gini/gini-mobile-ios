//
//  InvoiceFlowCoordinator.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 21.03.2022.
//

import UIKit
import SwiftUI
import GiniHealthSDK

protocol InvoiceFlowCoordinatorDelegate: AnyObject {
    func updateInvoicePaymentId(for invoiceID: String, paymentID: String)
}

final class InvoiceFlowCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var rootViewController: UIViewController {
        return navigationController
    }

    private var dataModel: InvoiceListDataModel
    private var giniHealth: GiniHealth
    private var currentInvoice: Invoice?

    weak var delegate: InvoiceFlowCoordinatorDelegate?

    var navigationController: UINavigationController!

    init(dataModel: InvoiceListDataModel, health: GiniHealth) {
        self.dataModel = dataModel
        self.giniHealth = health
//        self.giniHealth.delegate = self
    }

    func start() {
        let viewModel = InvoiceListViewModel(dataModel: dataModel)
        viewModel.delegate = self
        let viewController = InvoiceListViewController(viewModel: viewModel)
        navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen

        navigationController.navigationBar.isHidden = true
    }

    func addNewInvoice(invoice: Invoice) {
        dataModel.addNewInvoice(invoice: invoice)
    }

    func showInvoiceDetailAndChangePaymentStatus(with id: String) {
        guard let invoiceID = dataModel.invoiceData.first(where: { $0.paymentRequestID == id })?.invoiceID else { return }
        dataModel.markInvoicePayed(forInvoiceWith: invoiceID)
        didSelectInvoice(with: invoiceID)
    }

    func showInvoiceDetail(with invoiceId: String) {
        didSelectInvoice(with: invoiceId)
    }

    func showPaymentScreen(for invoice: Invoice) {
        guard let document = invoice.document else { return }
        let fetchedData = DataForReview(document: document, extractions: invoice.extractions)
        giniHealth.delegate = self
        let vc = PaymentReviewViewController.instantiate(with: giniHealth, data: fetchedData, trackingDelegate: self)
        navigationController.present(vc , animated: true)
    }

    func showDocumentScreen(with image: Image) {
        let viewModel = DocuementViewModel(image: image)
        viewModel.delegate = self
        let vc = DocuementViewController(viewModel: viewModel)
        navigationController.present(vc , animated: true)
    }
}

extension InvoiceFlowCoordinator: InvoiceListViewModelDelegate {
    func didSelectInvoice(with id: String) {
        guard let invoice = dataModel.invoiceData.first(where: { $0.invoiceID == id }) else { return }
        let viewModel = InvoiceDetailViewModel(invoice: invoice, giniHealth: giniHealth)
        viewModel.delegate = self
        let viewController = InvoiceDetailViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension InvoiceFlowCoordinator: DocuementViewModelDelegate {
    func didTapClose() {
        navigationController.dismiss(animated: true)
    }
}

extension InvoiceFlowCoordinator: InvoiceDetailViewModelDelegate {
    func didSelectShowReimbursmentDoc() {
        let reimbursmentDoc = Image("reimbursmentDoc")
        showDocumentScreen(with: reimbursmentDoc)
    }

    func didSelectDocument(_ image: Image) {
        showDocumentScreen(with: image)
    }

    func didTapBack() {
        navigationController.popViewController(animated: true)
    }

    func didSelectPay(invoice: Invoice) {
        currentInvoice = invoice
        showPaymentScreen(for: invoice)
    }
}

// MARK: GiniHealthTrackingDelegate

extension InvoiceFlowCoordinator: GiniHealthTrackingDelegate {
    func onPaymentReviewScreenEvent(event: TrackingEvent<PaymentReviewScreenEventType>) {
        switch event.type {
        case .onNextButtonClicked:
            navigationController.dismiss(animated: true)
            navigationController.popToRootViewController(animated: true)
            print("📝 Next button was tapped")
        case .onCloseButtonClicked:
            print("📝 Close screen was triggered")
        case .onCloseKeyboardButtonClicked:
            print("📝 Close keyboard was triggered")
        case .onBankSelectionButtonClicked:
            print("📝 Bank selection button was tapped")
        }
    }
}

// MARK: GiniHealthDelegate

extension InvoiceFlowCoordinator: GiniHealthDelegate {
    func shouldHandleErrorInternally(error: GiniHealthError) -> Bool {
        switch error {
        case .noInstalledApps:
            // shows own error
            let alertViewController = UIAlertController(title: "",
                                                        message: "We didn't find any banking apps installed which support Gini Pay",
                                                        preferredStyle: .alert)

            alertViewController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                alertViewController.dismiss(animated: true, completion: nil)
            })
            navigationController.present(alertViewController, animated: true, completion: nil)

            return false
        default:
            return true
        }
    }


    func didCreatePaymentRequest(paymentRequestID: String) {
        guard let invoice = currentInvoice else { return }
        delegate?.updateInvoicePaymentId(for: invoice.invoiceID, paymentID: paymentRequestID)
        currentInvoice = nil
    }
}
