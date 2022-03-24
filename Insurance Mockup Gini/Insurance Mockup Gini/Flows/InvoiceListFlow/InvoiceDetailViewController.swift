//
//  InvoiceDetailViewController.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 24.03.2022.
//

import UIKit
import SwiftUI

final class InvoiceDetailViewController: UIViewController {
    private var hostingView: UIHostingController<InvoiceDetailView>
    let viewModel: InvoiceDetailViewModel

    init(viewModel: InvoiceDetailViewModel) {
        self.viewModel = viewModel
        hostingView = UIHostingController(rootView: InvoiceDetailView(viewModel: viewModel))
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
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

