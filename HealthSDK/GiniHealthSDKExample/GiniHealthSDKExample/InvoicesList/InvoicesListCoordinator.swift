//
//  InvoicesListCoordinator.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniHealthSDK

final class InvoicesListCoordinator: NSObject, Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var rootViewController: UIViewController {
        return invoicesListNavigationController
    }
    
    var invoicesListNavigationController: UINavigationController!
    var invoicesListViewController: InvoicesListViewController!
    
    func start(documentService: DefaultDocumentService,
               hardcodedInvoicesController: HardcodedInvoicesControllerProtocol,
               health: GiniHealth,
               invoices: [DocumentWithExtractions]? = nil,
               shouldUseAlternativeNavigation: Bool) {
        self.invoicesListViewController = InvoicesListViewController()
        invoicesListViewController.viewModel = InvoicesListViewModel(coordinator: self,
                                                                     invoices: invoices,
                                                                     documentService: documentService,
                                                                     hardcodedInvoicesController: hardcodedInvoicesController,
                                                                     health: health,
                                                                     shouldUseAlternativeNavigation: shouldUseAlternativeNavigation)
        invoicesListNavigationController = RootNavigationController(rootViewController: invoicesListViewController)
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(named: "background")
        invoicesListNavigationController.navigationBar.standardAppearance = appearance
        invoicesListNavigationController.navigationBar.scrollEdgeAppearance = appearance
        invoicesListNavigationController.navigationBar.tintColor = .label
        invoicesListNavigationController.modalPresentationStyle = .fullScreen
        invoicesListNavigationController.interactivePopGestureRecognizer?.delegate = nil
    }
}
