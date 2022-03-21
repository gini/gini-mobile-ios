//
//  AppCoordinator.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 21.03.2022.
//

import Foundation
import UIKit

final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    fileprivate let window: UIWindow

    var rootViewController: UIViewController {
        return ViewController()
    }

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        showRootViewController()
    }

    fileprivate func showRootViewController() {
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }

    fileprivate func popToRootViewControllerIfNeeded() {
        childCoordinators.forEach { coordinator in
            coordinator.rootViewController.dismiss(animated: true, completion: nil)
            self.remove(childCoordinator: coordinator)
        }
    }
}
