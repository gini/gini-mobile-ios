//
//  InvoicesListViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniCaptureSDK
import GiniMerchantSDK

final class InvoicesListViewModel {
    
    private let coordinator: InvoicesListCoordinator
    private var documentService: GiniMerchantSDK.DefaultDocumentService

    private let hardcodedInvoicesController: HardcodedInvoicesControllerProtocol
    var paymentComponentsController: PaymentComponentsController

    var invoices: [InvoiceItem]

    let noInvoicesText = NSLocalizedString("example.invoicesList.missingInvoices.text", comment: "")
    let titleText = NSLocalizedString("example.invoicesList.title", comment: "")
    let customOrderText = NSLocalizedString("example.uploadInvoices.button.title", comment: "")
    let cancelText = NSLocalizedString("example.cancel.button.title", comment: "")
    let errorTitleText = NSLocalizedString("example.invoicesList.error", comment: "")

    let backgroundColor: UIColor = GiniColor(light: .white, 
                                             dark: .black).uiColor()
    let tableViewSeparatorColor: UIColor = GiniColor(light: .lightGray, 
                                                     dark: .darkGray).uiColor()
    
    private let tableViewCell: UITableViewCell.Type = InvoiceTableViewCell.self
    private var errors: [String] = []

    let dispatchGroup = DispatchGroup()
    var shouldRefetchExtractions = false
    var documentIDToRefetch: String?

    init(coordinator: InvoicesListCoordinator,
         invoices: [InvoiceItem]? = nil,
         documentService: GiniMerchantSDK.DefaultDocumentService,
         hardcodedInvoicesController: HardcodedInvoicesControllerProtocol,
         paymentComponentsController: PaymentComponentsController) {
        self.coordinator = coordinator
        self.hardcodedInvoicesController = hardcodedInvoicesController
        self.invoices = invoices ?? hardcodedInvoicesController.getInvoices()
        self.documentService = documentService
        self.paymentComponentsController = paymentComponentsController
        self.paymentComponentsController.delegate = self
    }
    
    func viewDidLoad() {
        paymentComponentsController.loadPaymentProviders()
    }
}

extension InvoicesListViewModel: PaymentComponentsControllerProtocol {
    func didFetchedPaymentProviders() {
        DispatchQueue.main.async {
            self.coordinator.invoicesListViewController.reloadTableView()
        }
    }

    func isLoadingStateChanged(isLoading: Bool) {
        DispatchQueue.main.async {
            if isLoading {
                self.coordinator.invoicesListViewController.showActivityIndicator()
            } else {
                self.coordinator.invoicesListViewController.hideActivityIndicator()
            }
        }
    }
}



extension InvoicesListViewModel: GiniMerchantTrackingDelegate {
    func onPaymentReviewScreenEvent(event: TrackingEvent<PaymentReviewScreenEventType>) {
        switch event.type {
        case .onToTheBankButtonClicked:
            print("✅ To the banking app button was tapped,\(String(describing: event.info))")
        case .onCloseButtonClicked:
            print("✅ Close screen was triggered")
        case .onCloseKeyboardButtonClicked:
            print("✅ Close keyboard was triggered")
        }
    }
}
