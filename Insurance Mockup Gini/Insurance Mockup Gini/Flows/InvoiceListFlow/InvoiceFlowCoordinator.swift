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
//        let viewModel = InvoiceDetailViewModel(invoiceDetail: NewInvoiceDetailViewModel(results: [], document: nil))
//        let viewController = InvoiceDetailViewController(viewModel: viewModel)

        let viewModel = InvoiceListViewModel()
        let viewController = InvoiceListViewController(viewModel: viewModel)
        navigationController = UINavigationController(rootViewController: viewController)

        navigationController.navigationBar.isHidden = true
    }
}
