//
//  InvoiceFlowCoordinator.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 21.03.2022.
//

import UIKit

final class InvoiceFlowCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var rootViewController: UIViewController {
        return navigationController
    }

    var navigationController: UINavigationController!

    func start() {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .green
        navigationController = UINavigationController(rootViewController: viewController)
    }
}
