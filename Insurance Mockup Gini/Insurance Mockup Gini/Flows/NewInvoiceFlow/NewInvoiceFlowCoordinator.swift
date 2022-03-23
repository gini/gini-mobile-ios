//
//  NewInvoiceFlowCoordinator.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 22.03.2022.
//

import UIKit
import GiniCaptureSDK
import GiniBankAPILibrary

final class NewInvoiceFlowCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var rootViewController: UIViewController {
        return navigationController
    }

    var navigationController: UINavigationController!

    func start() {
        let viewController = NewInvoiceFlowViewController()
        navigationController = UINavigationController(rootViewController: viewController)
    }
}
