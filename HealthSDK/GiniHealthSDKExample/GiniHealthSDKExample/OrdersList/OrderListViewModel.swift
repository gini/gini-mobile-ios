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

    var health: GiniHealth
    private var errors: [String] = []
    
    @Published var orders: [Order]
    @Published var errorMessage: String?

    init(coordinator: OrderListCoordinator,
         orders: [Order]? = nil,
         documentService: GiniHealthSDK.DefaultDocumentService,
         hardcodedOrdersController: HardcodedOrdersControllerProtocol,
         health: GiniHealth) {
        self.coordinator = coordinator
        self.hardcodedOrdersController = hardcodedOrdersController
        self.orders = orders ?? hardcodedOrdersController.orders
        self.documentService = documentService
        self.health = health
    }

    func updateOrder(updatedOrder: Order) {
        hardcodedOrdersController.updateOrder(updatedOrder: updatedOrder)
    }
    
    func deleteOrder(_ order: Order) {
        guard let orderId = order.id else { return }
        
        health.paymentService.deletePaymentRequest(id: orderId, completion: { result in
            switch result {
            case .success:
                self.orders.removeAll(where: { $0.id == order.id })
            case .failure(let error):
                self.errors.append(error.localizedDescription)
                self.showErrorsIfAny()
            }
        })
    }
    
    private func showErrorsIfAny() {
        if !errors.isEmpty {
            let uniqueErrorMessages = Array(Set(errors))
            errorMessage = uniqueErrorMessages.joined(separator: ", ")
            errors = []
        }
    }
}
