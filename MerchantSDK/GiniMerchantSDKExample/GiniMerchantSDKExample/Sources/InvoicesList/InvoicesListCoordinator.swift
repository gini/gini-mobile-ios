//
//  InvoicesListCoordinator.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniMerchantSDK

final class InvoicesListCoordinator: NSObject, Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var rootViewController: UIViewController {
        return invoicesListNavigationController
    }
    
    var invoicesListNavigationController: UINavigationController!
    var invoicesListViewController: InvoicesListViewController!
    
    func start(documentService: GiniMerchantSDK.DefaultDocumentService,
               hardcodedOrdersController: HardcodedOrdersControllerProtocol,
               paymentComponentsController: PaymentComponentsController,
               orders: [Order]? = nil) {
        self.invoicesListViewController = InvoicesListViewController()
        invoicesListViewController.viewModel = InvoicesListViewModel(coordinator: self,
                                                                     orders: orders,
                                                                     documentService: documentService,
                                                                     hardcodedOrdersController: hardcodedOrdersController,
                                                                     paymentComponentsController: paymentComponentsController)
        invoicesListNavigationController = RootNavigationController(rootViewController: invoicesListViewController)
        invoicesListNavigationController.modalPresentationStyle = .fullScreen
        invoicesListNavigationController.interactivePopGestureRecognizer?.delegate = nil

        invoicesListNavigationController.navigationBar.backgroundColor = .white
        invoicesListNavigationController.navigationBar.isTranslucent = false

        let appearance = UINavigationBarAppearance()
        invoicesListNavigationController.navigationBar.standardAppearance = appearance
        invoicesListNavigationController.navigationBar.scrollEdgeAppearance = appearance
        invoicesListNavigationController.navigationBar.tintColor = .label
    }
}
