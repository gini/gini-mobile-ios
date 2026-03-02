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
    weak var invoicesListViewController: InvoicesListViewController?
    weak var parentCoordinator: Coordinator?
    
    func start(documentService: DefaultDocumentService,
               hardcodedInvoicesController: HardcodedInvoicesControllerProtocol,
               health: GiniHealth,
               invoices: [DocumentWithExtractions]? = nil,
               shouldUseAlternativeNavigation: Bool) {
        let viewController = InvoicesListViewController()
        viewController.viewModel = InvoicesListViewModel(coordinator: self,
                                                         invoices: invoices,
                                                         documentService: documentService,
                                                         hardcodedInvoicesController: hardcodedInvoicesController,
                                                         health: health,
                                                         shouldUseAlternativeNavigation: shouldUseAlternativeNavigation)
        self.invoicesListViewController = viewController
        invoicesListNavigationController = RootNavigationController(rootViewController: viewController)
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(named: "background")
        invoicesListNavigationController.navigationBar.standardAppearance = appearance
        invoicesListNavigationController.navigationBar.scrollEdgeAppearance = appearance
        invoicesListNavigationController.navigationBar.tintColor = .label
        invoicesListNavigationController.modalPresentationStyle = .fullScreen
        invoicesListNavigationController.interactivePopGestureRecognizer?.delegate = nil
    }
    
    func removeFromParent() {
        print("🔵 InvoicesListCoordinator.removeFromParent() called")
        parentCoordinator?.remove(childCoordinator: self)
    }
    
    deinit {
        print("✅ InvoicesListCoordinator deinitialized")
    }
}
