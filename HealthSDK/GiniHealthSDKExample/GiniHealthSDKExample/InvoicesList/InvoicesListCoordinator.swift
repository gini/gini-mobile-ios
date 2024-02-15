//
//  InvoicesListCoordinator.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniHealthAPILibrary

final class InvoicesListCoordinator: NSObject, Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var rootViewController: UIViewController {
        return invoicesListNavigationController
    }
    
    var invoicesListNavigationController: UINavigationController!
    var invoicesListViewController: InvoicesListViewController!
    
    func start(documentService: DefaultDocumentService, hardcodedInvoicesController: HardcodedInvoicesControllerProtocol) {
        self.invoicesListViewController = InvoicesListViewController()
        invoicesListViewController.viewModel = InvoicesListViewModel(coordinator: self,
                                                                     documentService: documentService,
                                                                     hardcodedInvoicesController: hardcodedInvoicesController)
        invoicesListNavigationController = RootNavigationController(rootViewController: invoicesListViewController)
        invoicesListNavigationController.interactivePopGestureRecognizer?.delegate = nil
    }
}
