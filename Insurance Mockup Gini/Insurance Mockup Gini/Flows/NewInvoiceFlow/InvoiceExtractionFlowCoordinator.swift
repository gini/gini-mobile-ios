//
//  InvoiceExtractionFlowCoordinator.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 28.03.2022.
//

import SwiftUI
import UIKit
import GiniHealthSDK
import GiniHealthAPILibrary

protocol InvoiceExtractionFlowCoordinatorDelegate: AnyObject {
    func extractionFlowDidSelectSave(invoice: Invoice)
    func extractionFlowDidFinish(_ coordinator: InvoiceExtractionFlowCoordinator)
}

final class InvoiceExtractionFlowCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var rootViewController: UIViewController {
        return navigationController
    }

    var giniHealth: GiniHealth

    weak var delegate: InvoiceExtractionFlowCoordinatorDelegate?
    var navigationController: UINavigationController!

    init(giniHealth: GiniHealth) {
        self.giniHealth = giniHealth
    }

    func start(withInvoice invoice: Invoice) {
        let viewModel = NewInvoiceDetailViewModel(invoice: invoice, healthSDK: giniHealth)
        viewModel.delegate = self
        let vc = NewInvoiceDetailViewController(viewModel: viewModel)
        navigationController = UINavigationController(rootViewController: vc)
    }

    func showConfirmationScreen(ofType type: ConfirmationType) {
        let viewModel = ConfirmationViewModel(type: type)
        let viewController = ConfirmationViewController(viewModel: viewModel)
        viewModel.delegate = self
        viewController.modalPresentationStyle = .fullScreen
        navigationController.present(viewController, animated: true)
    }

    func showDocumentScreen(with image: Image) {
        let viewModel = DocumentViewModel(image: image)
        viewModel.delegate = self
        let viewController = DocumentViewController(viewModel: viewModel)
        viewController.modalPresentationStyle = .fullScreen
        navigationController.present(viewController , animated: true)
    }
}

extension InvoiceExtractionFlowCoordinator: ConfirmationViewModelDelegate {
    func didTapContinue() {
        self.navigationController.popToRootViewController(animated: true)
        delegate?.extractionFlowDidFinish(self)
    }
}

// MARK: GiniHealthTrackingDelegate

extension InvoiceExtractionFlowCoordinator: GiniHealthTrackingDelegate {
    func onPaymentReviewScreenEvent(event: TrackingEvent<PaymentReviewScreenEventType>) {
        switch event.type {
        case .onNextButtonClicked:
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


extension InvoiceExtractionFlowCoordinator: NewInvoiceDetailViewModelDelegate {
    func saveNewInvoice(invoice: Invoice) {
        delegate?.extractionFlowDidSelectSave(invoice: invoice)
        showConfirmationScreen(ofType: .save)
    }

    func didTapPayAndSaveNewInvoice(withExtraction extraction: [Extraction], document: Document?) {
        guard let document = document else { return }
        let fetchedData = DataForReview(document: document, extractions: extraction)
        let vc = PaymentReviewViewController.instantiate(with: giniHealth, data: fetchedData, trackingDelegate: self)
        self.navigationController.pushViewController(vc , animated: true)
    }

    func didTapSendInvoice() {
        showConfirmationScreen(ofType: .reimbursment)
    }

    func didTapCancel() {
        self.navigationController.dismiss(animated: true)
        delegate?.extractionFlowDidFinish(self)
    }

    func didSelectDocument(_ image: Image) {
        showDocumentScreen(with: image)
    }
}

extension InvoiceExtractionFlowCoordinator: DocumentViewModelDelegate {
    func didTapClose() {
        navigationController.dismiss(animated: true)
    }
}
