//
//  NewInvoiceFlowViewController.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 22.03.2022.
//

import UIKit

protocol NewInvoiceFlowViewControllerDelegate: AnyObject {
    func didSelectNewInvoice()
}

final class NewInvoiceFlowViewController: UIViewController {
    private lazy var button = UIButton(type: .custom)
    weak var delegate: NewInvoiceFlowViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        button.setTitle("Add new invoice", for: .normal)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        view.addSubview(button)
        setupConstraints()
    }

    private func setupConstraints() {
        button.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: view.topAnchor),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    @objc
    private func didTapButton() {
        delegate?.didSelectNewInvoice()
    }
}
