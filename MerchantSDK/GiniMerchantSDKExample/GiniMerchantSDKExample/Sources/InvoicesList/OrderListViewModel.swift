//
//  OrderListViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniCaptureSDK
import GiniMerchantSDK

final class OrderListViewModel {

    private let coordinator: OrderListCoordinator
    private var documentService: GiniMerchantSDK.DefaultDocumentService
    private let hardcodedOrdersController: HardcodedOrdersControllerProtocol

    let noInvoicesText = NSLocalizedString("example.invoicesList.missingInvoices.text", comment: "")
    let titleText = NSLocalizedString("example.invoicesList.title", comment: "")
    let customOrderText = NSLocalizedString("example.uploadInvoices.button.title", comment: "")
    let cancelText = NSLocalizedString("example.cancel.button.title", comment: "")
    let errorTitleText = NSLocalizedString("example.invoicesList.error", comment: "")

    private var errors: [String] = []

    var paymentComponentsController: PaymentComponentsController
    var orders: [Order]

    init(coordinator: OrderListCoordinator,
         orders: [Order]? = nil,
         documentService: GiniMerchantSDK.DefaultDocumentService,
         hardcodedOrdersController: HardcodedOrdersControllerProtocol,
         paymentComponentsController: PaymentComponentsController) {
        self.coordinator = coordinator
        self.hardcodedOrdersController = hardcodedOrdersController
        self.orders = orders ?? hardcodedOrdersController.orders
        self.documentService = documentService
        self.paymentComponentsController = paymentComponentsController
        self.paymentComponentsController.delegate = self
    }
    
    func viewDidLoad() {
        paymentComponentsController.loadPaymentProviders()
    }
}

extension OrderListViewModel: PaymentComponentsControllerProtocol {
    func didFetchedPaymentProviders() {
        DispatchQueue.main.async {
            self.coordinator.orderListViewController.reloadTableView()
        }
    }

    func isLoadingStateChanged(isLoading: Bool) {
        DispatchQueue.main.async {
            if isLoading {
                self.coordinator.orderListViewController.showActivityIndicator()
            } else {
                self.coordinator.orderListViewController.hideActivityIndicator()
            }
        }
    }
}
