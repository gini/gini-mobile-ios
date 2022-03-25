//
//  NewInvoiceFlowCoordinator.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 22.03.2022.
//

import UIKit
import GiniCaptureSDK
import GiniBankAPILibrary

// Dummy coordinator for placeholder on the tabbar coordinator 

final class NewInvoiceFlowCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var rootViewController: UIViewController {
        return navigationController
    }

    var navigationController: UINavigationController!

    func start() {
        let viewController = UIViewController()
        navigationController = UINavigationController(rootViewController: viewController)
    }
}
