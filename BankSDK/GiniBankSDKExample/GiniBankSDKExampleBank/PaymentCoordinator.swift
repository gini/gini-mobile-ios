//
//  PaymentCoordinator.swift
//  GiniBankSDKExample
//
//  Created by David Vizaknai on 01.04.2022.
//

import Foundation
import UIKit
import GiniBankAPILibrary

final class PaymentCordinator {
    var rootViewController: UIViewController {
        return navigationController
    }

    private var navigationController: UINavigationController!

    private var apiLib: GiniBankAPI

    init(apiLib: GiniBankAPI) {
        self.apiLib = apiLib
    }

    func start() {
        let viewModel = PaymentViewModel(with: apiLib)
        viewModel.delegate = self
        let paymentViewController = PaymentViewController(viewModel: viewModel)

        navigationController = UINavigationController(rootViewController: paymentViewController)
    }

    func showConfirmationScreen(with paymentRequest: ResolvedPaymentRequest) {
        let viewModel = PaymentConfirmationViewModel(with: apiLib, paymentRequest: paymentRequest)
        let viewController = PaymentConfirmationViewController(viewModel: viewModel)

        viewController.modalPresentationStyle = .fullScreen        
        navigationController.present(viewController, animated: true)
    }
}

extension PaymentCordinator: PaymentViewModelDelegate {
    func paymentViewModelDidFinishPayment(_ paymentViewModel: PaymentViewModel, with paymentRequest: ResolvedPaymentRequest) {
        showConfirmationScreen(with: paymentRequest)
    }
}

