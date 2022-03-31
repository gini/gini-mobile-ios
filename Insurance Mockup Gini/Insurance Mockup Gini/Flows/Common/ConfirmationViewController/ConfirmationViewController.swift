//
//  ConfirmationViewController.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 30.03.2022.
//

import SwiftUI
import UIKit

final class ConfirmationViewController: UIViewController {
    private var hostingView: UIHostingController<ConfirmationView>
    var viewModel: ConfirmationViewModel

    init(viewModel: ConfirmationViewModel) {
        self.viewModel = viewModel
        hostingView = UIHostingController(rootView: ConfirmationView(viewModel: viewModel))
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()

        viewModel.shouldDismiss = { [weak self] in
            self?.dismiss(animated: false, completion: {
                self?.viewModel.delegate?.didTapContinue()
            })
        }
    }

    private func setupView() {
        addChild(hostingView)
        view.addSubview(hostingView.view)
        view.backgroundColor = UIColor(Style.NewInvoice.backgroundColor)
        hostingView.view.insetsLayoutMarginsFromSafeArea = false
        setupConstraints()
    }

    private func setupConstraints() {
        hostingView.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hostingView.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
