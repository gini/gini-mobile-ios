//
//  HomeScreenCoordinator.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 21.03.2022.
//

import UIKit

final class HomeScreenCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var rootViewController: UIViewController {
        return navigationController
    }

    var navigationController: UINavigationController!

    func start() {
        let viewController = HomeScreenViewController()
        navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.isHidden = true
    }
}
