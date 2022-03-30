//
//  DocumentViewController.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 29.03.2022.
//

import UIKit
import SwiftUI

final class DocumentViewController: UIViewController {
    private var hostingView: UIHostingController<DocumentView>
    var viewModel: DocumentViewModel

    init(viewModel: DocumentViewModel) {
        self.viewModel = viewModel
        hostingView = UIHostingController(rootView: DocumentView(viewModel: viewModel))
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
