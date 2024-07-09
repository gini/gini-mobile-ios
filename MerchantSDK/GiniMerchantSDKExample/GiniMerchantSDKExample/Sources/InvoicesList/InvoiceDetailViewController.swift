//
//  InvoiceDetailViewController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

final class InvoiceDetailViewController: UIViewController {

    private let invoice: DocumentWithExtractions

    init(invoice: DocumentWithExtractions) {
        self.invoice = invoice
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var invoiceNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "Invoice number: \n\(invoice.documentID)"
        label.textColor = .black
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var dueDateLabel: UILabel = {
        let label = UILabel()
        label.text = "Due date: \n\(invoice.paymentDueDate ?? "")"
        label.textColor = .black
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.text = "Amount: \n\(invoice.amountToPay ?? "")"
        label.textColor = .black
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var payNowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Pay now", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(payNowButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        view.addSubview(invoiceNumberLabel)
        view.addSubview(dueDateLabel)
        view.addSubview(amountLabel)
        view.addSubview(payNowButton)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Invoice number label constraints
            invoiceNumberLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            invoiceNumberLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            invoiceNumberLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Due date label constraints
            dueDateLabel.topAnchor.constraint(equalTo: invoiceNumberLabel.bottomAnchor, constant: 20),
            dueDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dueDateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Amount label constraints
            amountLabel.topAnchor.constraint(equalTo: dueDateLabel.bottomAnchor, constant: 20),
            amountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            amountLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Pay now button constraints
            payNowButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            payNowButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            payNowButton.widthAnchor.constraint(equalToConstant: 100),
            payNowButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc private func payNowButtonTapped() {
        // Handle the button tap event
        print("Pay now button tapped")
    }
}
