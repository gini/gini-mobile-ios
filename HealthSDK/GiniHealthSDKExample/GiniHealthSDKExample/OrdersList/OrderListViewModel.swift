//
//  OrderListViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//



import UIKit
import GiniCaptureSDK
import GiniHealthSDK

final class OrderListViewModel {

    private let coordinator: OrderListCoordinator
    private var documentService: GiniHealthSDK.DefaultDocumentService
    private let hardcodedOrdersController: HardcodedOrdersControllerProtocol

    let noInvoicesText = NSLocalizedString("gini.health.example.invoicesList.missingInvoices.text", comment: "")
    let titleText = NSLocalizedString("gini.health.example.invoicesList.title", comment: "")
    let customOrderText = NSLocalizedString("gini.health.example.custom.order.button.title", comment: "")
    let cancelText = NSLocalizedString("gini.health.example.cancel.button.title", comment: "")
    let errorTitleText = NSLocalizedString("gini.health.example.invoicesList.error", comment: "")

    private var errors: [String] = []

    var paymentComponentsController: PaymentComponentsController
    var orders: [Order]

    init(coordinator: OrderListCoordinator,
         orders: [Order]? = nil,
         documentService: GiniHealthSDK.DefaultDocumentService,
         hardcodedOrdersController: HardcodedOrdersControllerProtocol,
         paymentComponentsController: PaymentComponentsController) {
        self.coordinator = coordinator
        self.hardcodedOrdersController = hardcodedOrdersController
        self.orders = orders ?? hardcodedOrdersController.orders
        self.documentService = documentService
        self.paymentComponentsController = paymentComponentsController
    }
    
    func viewDidLoad() {}
}
