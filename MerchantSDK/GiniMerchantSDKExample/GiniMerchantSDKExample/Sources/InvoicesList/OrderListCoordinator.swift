//
//  OrderListCoordinator.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniMerchantSDK

final class OrderListCoordinator: NSObject, Coordinator {

    var childCoordinators: [Coordinator] = []
    var rootViewController: UIViewController {
        orderListNavigationController
    }

    var orderListNavigationController: UINavigationController!
    var orderListViewController: OrderListViewController!

    func start(documentService: GiniMerchantSDK.DefaultDocumentService,
               hardcodedOrdersController: HardcodedOrdersControllerProtocol,
               paymentComponentsController: PaymentComponentsController,
               orders: [Order]? = nil) {
        self.orderListViewController = OrderListViewController()
        orderListViewController.viewModel = OrderListViewModel(coordinator: self,
                                                               orders: orders,
                                                               documentService: documentService,
                                                               hardcodedOrdersController: hardcodedOrdersController,
                                                               paymentComponentsController: paymentComponentsController)
        orderListNavigationController = RootNavigationController(rootViewController: orderListViewController)
        orderListNavigationController.modalPresentationStyle = .fullScreen
        orderListNavigationController.interactivePopGestureRecognizer?.delegate = nil

        orderListNavigationController.navigationBar.backgroundColor = .white
        orderListNavigationController.navigationBar.isTranslucent = false

        let appearance = UINavigationBarAppearance()
        orderListNavigationController.navigationBar.standardAppearance = appearance
        orderListNavigationController.navigationBar.scrollEdgeAppearance = appearance
        orderListNavigationController.navigationBar.tintColor = .label
    }
}
