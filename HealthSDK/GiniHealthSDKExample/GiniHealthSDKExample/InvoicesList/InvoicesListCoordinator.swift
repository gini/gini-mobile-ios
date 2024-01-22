//
//  InvoicesListCoordinator.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import UIKit
import GiniHealthSDK
import GiniCaptureSDK

final class InvoicesListCoordinator: NSObject, Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var rootViewController: UIViewController {
        return invoicesListNavigationController
    }
    
    var invoicesListNavigationController: UINavigationController!
    private var health: GiniHealth!
    
    var invoicesListViewController: InvoicesListViewController?
    
    func start(health: GiniHealth, hardcodedInvoicesController: HardcodedInvoicesControllerProtocol, giniConfiguration: GiniHealthConfiguration) {
        self.health = health
        
        invoicesListViewController = InvoicesListViewController()
        invoicesListViewController?.viewModel = InvoicesListViewModel(coordinator: self, viewController: invoicesListViewController, giniHealth: health, hardcodedInvoicesController: hardcodedInvoicesController, giniConfiguration: giniConfiguration)
        guard let invoicesListViewController = invoicesListViewController else { return }
        invoicesListNavigationController = RootNavigationController(rootViewController: invoicesListViewController)
        invoicesListNavigationController.interactivePopGestureRecognizer?.delegate = nil
    }
}

extension InvoicesListCoordinator: InvoicesCoordinatorProtocol {
}
