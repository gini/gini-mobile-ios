//
//  OrderListCoordinator.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//



import UIKit
import GiniHealthSDK

final class OrderListCoordinator: NSObject, Coordinator {

    var childCoordinators: [Coordinator] = []
    var rootViewController: UIViewController {
        orderListNavigationController
    }

    var orderListNavigationController: UINavigationController!
    var orderListViewController: OrderListViewController!

    func start(documentService: GiniHealthSDK.DefaultDocumentService,
               hardcodedOrdersController: HardcodedOrdersControllerProtocol,
               health: GiniHealth,
               orders: [Order]? = nil,
               shouldUseAlternativeNavigation: Bool) {
        self.orderListViewController = OrderListViewController()
        orderListViewController.viewModel = OrderListViewModel(coordinator: self,
                                                               orders: orders,
                                                               documentService: documentService,
                                                               hardcodedOrdersController: hardcodedOrdersController,
                                                               health: health,
                                                               shouldUseAlternativeNavigation: shouldUseAlternativeNavigation)
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
