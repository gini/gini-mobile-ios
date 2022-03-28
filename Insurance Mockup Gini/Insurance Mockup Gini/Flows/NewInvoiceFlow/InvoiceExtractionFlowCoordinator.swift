//
//  InvoiceExtractionFlowCoordinator.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 28.03.2022.
//

import UIKit
import GiniHealthSDK
import GiniHealthAPILibrary

protocol InvoiceExtractionFlowCoordinatorDelegate: AnyObject {
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

    func start(withExtraction extraction: [Extraction], document: Document?) {
        guard let document = document else { return }
        let viewModel = NewInvoiceDetailViewModel(results: extraction, document: document)
        viewModel.delegate = self
        let vc = NewInvoiceDetailViewController(viewModel: viewModel)
        navigationController = UINavigationController(rootViewController: vc)
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
    func didTapPayAndSaveNewInvoice(withExtraction extraction: [Extraction], document: Document?) {
        guard let document = document else { return }
        let fetchedData = DataForReview(document: document, extractions: extraction)
        let vc = PaymentReviewViewController.instantiate(with: giniHealth, data: fetchedData, trackingDelegate: self)
        self.navigationController.pushViewController(vc , animated: true)
    }

    func didTapPayAndSubmitNewInvoice() {

    }

    func didTapSubmitNewInvoice() {

    }

    func didTapSaveNewInvoice() {

    }

    func didTapCancel() {
        self.navigationController.dismiss(animated: true)
        delegate?.extractionFlowDidFinish(self)
    }
}
