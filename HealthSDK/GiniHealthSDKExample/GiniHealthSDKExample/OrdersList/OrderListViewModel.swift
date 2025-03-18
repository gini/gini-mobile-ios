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
    
    @Published var orders: [Order]
    @Published var errorMessage: String?
    @Published var successMessage: String?

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
        
        health.deletePaymentRequest(id: orderId, completion: { [weak self] result in
            switch result {
            case .success:
                self?.handlePaymentRequestDeletion(for: order)
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
            }
        })
    }
    
    func deleteOders() {
        let orderIds = orders.compactMap(\.id)
        
        health.deletePaymentRequests(ids: orderIds, completion: { [weak self] result in
            switch result {
            case .success:
                self?.orders.forEach { self?.handlePaymentRequestDeletion(for: $0) }
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
            }
        })
    }
    
    private func updateLoadedOrder(_ order: Order) {
        guard let index = orders.firstIndex(where: { $0.iban == order.iban }) else { return }
        orders[index] = order
    }
    
    private func handlePaymentRequestDeletion(for order: Order) {
        order.expirationDate = nil
        order.id = nil
        updateOrder(updatedOrder: order)
        updateLoadedOrder(order)
    }
}
