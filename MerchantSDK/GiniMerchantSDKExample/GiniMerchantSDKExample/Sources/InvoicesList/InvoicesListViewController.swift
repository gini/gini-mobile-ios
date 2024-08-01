//
//
//  InvoicesListViewController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

protocol InvoicesListViewControllerProtocol: AnyObject {
    func showActivityIndicator()
    func hideActivityIndicator()
    func reloadTableView()
    func showErrorAlertView(error: String)
}

final class InvoicesListViewController: UIViewController {
    
    // MARK: - Variables
    private lazy var invoicesTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(InvoiceTableViewCell.self, forCellReuseIdentifier: InvoiceTableViewCell.identifier)
        tableView.separatorColor = viewModel.tableViewSeparatorColor
        tableView.separatorInset = .zero
        tableView.rowHeight = Constants.rowHeight
        tableView.tableFooterView = UIView()
        return tableView
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        if #available(iOS 13.0, *) {
            activityIndicator.style = .large
        } else {
            activityIndicator.style = .gray
        }
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    var viewModel: InvoicesListViewModel!
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        invoicesTableView.reloadData()
    }

    override func loadView() {
        super.loadView()
        title = viewModel.titleText
        view.backgroundColor = viewModel.backgroundColor
        setupTableView()
        setupNavigationBar()
    }
    
    private func setupTableView() {
        if #available(iOS 15.0, *) {
            invoicesTableView.sectionHeaderTopPadding = 0
         }
        view.addSubview(invoicesTableView)

        NSLayoutConstraint.activate([
            invoicesTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.padding),
            invoicesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.padding),
            invoicesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.padding),
            invoicesTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.padding)
        ])
    }
    
    private func setupNavigationBar() {
        let uploadInvoiceItem = UIBarButtonItem(title: viewModel.customOrderText,
                                                style: .plain,
                                                target: self,
                                                action: #selector(customOrderButtonTapped))
        self.navigationItem.rightBarButtonItem = uploadInvoiceItem

        let cancelItem = UIBarButtonItem(title: viewModel.cancelText,
                                         style: .plain,
                                         target: self,
                                         action: #selector(dismissViewControllerTapped))
        self.navigationItem.leftBarButtonItem = cancelItem
    }
    
    @objc func customOrderButtonTapped() {
        let newInvoice = InvoiceItem(amountToPay: "", recipient: "", iban: "", purpose: "")
        viewModel.invoices.append(newInvoice)

        let invoiceViewController = InvoiceDetailViewController(invoice: newInvoice, paymentComponentsController: viewModel.paymentComponentsController)
        self.navigationController?.pushViewController(invoiceViewController, animated: true)
    }

    @objc func dismissViewControllerTapped() {
        self.dismiss(animated: true)
    }
}

extension InvoicesListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.invoices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: InvoiceTableViewCell.identifier, for: indexPath) as? InvoiceTableViewCell else {
            return UITableViewCell()
        }
        let invoiceTableViewCellModel = viewModel.invoices.map { InvoiceTableViewCellModel(invoice: $0,
                                                                                           paymentComponentsController: viewModel.paymentComponentsController) }[indexPath.row]
        cell.viewModel = invoiceTableViewCellModel
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if viewModel.invoices.isEmpty {
            let label = UILabel()
            label.text = viewModel.noInvoicesText
            label.textAlignment = .center
            tableView.backgroundView = label
            tableView.separatorStyle = .none
            return 0
        } else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
            return 1
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let invoice = viewModel.invoices[indexPath.row]

        // Instantiate InvoiceViewController with the Invoice instance
        let invoiceViewController = InvoiceDetailViewController(invoice: invoice, paymentComponentsController: viewModel.paymentComponentsController)

        // Present InvoiceViewController
        self.navigationController?.pushViewController(invoiceViewController, animated: true)
    }
}

extension InvoicesListViewController: InvoicesListViewControllerProtocol {
    func showActivityIndicator() {
        self.activityIndicator.startAnimating()
        self.view.addSubview(self.activityIndicator)
    }
    
    func hideActivityIndicator() {
        self.activityIndicator.stopAnimating()
    }
    
    func reloadTableView() {
        self.invoicesTableView.reloadData()
    }
    
    func showErrorAlertView(error: String) {
        let alertController = UIAlertController(title: viewModel.errorTitleText, 
                                                message: error,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alertController, animated: true)
    }
}

extension InvoicesListViewController {
    private enum Constants {
        static let padding: CGFloat = 0
        static let rowHeight: CGFloat = 80
    }
}
