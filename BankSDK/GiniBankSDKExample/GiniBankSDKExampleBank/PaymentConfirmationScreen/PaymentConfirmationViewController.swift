//
//  PaymentConfirmationViewController.swift
//  GinBankSDKExampleBank
//
//  Created by David Vizaknai on 01.04.2022.
//

import SwiftUI
import UIKit

class PaymentConfirmationViewController: UIViewController {
    private var hostingView: UIHostingController<PaymentConfirmationView>
    private var viewModel: PaymentConfirmationViewModel

    init(viewModel: PaymentConfirmationViewModel) {
        self.viewModel = viewModel
        hostingView = UIHostingController(rootView: PaymentConfirmationView(viewModel: viewModel))
        super.init(nibName: nil, bundle: nil)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }

    private func setupView() {
        hostingView.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingView.view)
    }

    private func setupConstraints() {
        let constraints = [
            hostingView.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
    }
}
