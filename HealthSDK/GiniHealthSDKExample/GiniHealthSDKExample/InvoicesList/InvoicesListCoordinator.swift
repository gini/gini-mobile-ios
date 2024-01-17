//
//  InvoicesListCoordinator.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import UIKit
import GiniHealthSDK

final class InvoicesListCoordinator: NSObject, Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var rootViewController: UIViewController {
        return invoicesListNavigationController
    }
    
    var invoicesListNavigationController: UINavigationController!
    private var health: GiniHealth!
    
    var invoicesListViewController: InvoicesListViewController?
    
    func start(health: GiniHealth, hardcodedInvoicesController: HardcodedInvoicesControllerProtocol) {
        self.health = health
        
        invoicesListViewController = InvoicesListViewController()
        invoicesListViewController?.viewModel = InvoicesListViewModel(coordinator: self, viewController: invoicesListViewController, giniHealth: health, hardcodedInvoicesController: hardcodedInvoicesController)
        guard let invoicesListViewController = invoicesListViewController else { return }
        invoicesListNavigationController = RootNavigationController(rootViewController: invoicesListViewController)
        invoicesListNavigationController.interactivePopGestureRecognizer?.delegate = nil
    }
}

extension InvoicesListCoordinator: InvoicesCoordinatorProtocol {
}
