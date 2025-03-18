//
//  OrderListViewController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//



import UIKit
import Combine

protocol OrderListViewControllerProtocol: AnyObject {
    func showActivityIndicator()
    func hideActivityIndicator()
    func reloadTableView()
    func showErrorAlertView(error: String)
}

final class OrderListViewController: UIViewController {

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(OrderTableViewCell.self, forCellReuseIdentifier: OrderTableViewCell.identifier)
        tableView.separatorInset = .zero
        tableView.rowHeight = Constants.rowHeight
        tableView.tableFooterView = UIView()
        return tableView
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .large
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    private var cancellables = Set<AnyCancellable>()
    
    var viewModel: OrderListViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        registerForUpdates()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
    }

    override func loadView() {
        super.loadView()
        title = viewModel.titleText
        setupTableView()
        setupNavigationBar()
    }
    
    private func setupTableView() {
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.padding),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.padding),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.padding),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.padding)
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: viewModel.cancelText,
            style: .plain,
            target: self,
            action: #selector(dismissViewControllerTapped)
        )
    }
    
    @objc func addButtonTapped() {
        let optionsSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let addorderAction = UIAlertAction(title: viewModel.customOrderText, style: .default) { _ in
            self.customOrderButtonTapped()
        }
        
        let deletePaymentRequestsAction = UIAlertAction(title: "Delete payment requests", style: .destructive) { _ in
            self.viewModel.deleteOders()
        }
        
        optionsSheet.addAction(addorderAction)
        optionsSheet.addAction(deletePaymentRequestsAction)
        
        present(optionsSheet, animated: true)
    }

    @objc func customOrderButtonTapped() {
        let newOrder = Order(amountToPay: "", recipient: "", iban: "", purpose: "")
        viewModel.orders.append(newOrder)

        let orderViewController = OrderDetailViewController(newOrder, health: viewModel.health)
        orderViewController.delegate = self
        self.navigationController?.pushViewController(orderViewController, animated: true)
    }

    @objc func dismissViewControllerTapped() {
        self.dismiss(animated: true)
    }
}

extension OrderListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: OrderTableViewCell.identifier, for: indexPath) as? OrderTableViewCell else {
            return UITableViewCell()
        }
        cell.viewModel = viewModel.orders.map { OrderCellViewModel($0) }[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let order = self.viewModel.orders[indexPath.row]
        
        guard order.canBeDeleted else {
            return nil
        }
        
        return UISwipeActionsConfiguration(actions: [UIContextualAction(style: .destructive,
                                                                        title: "Delete",
                                                                        handler: { _, _, completion in
            self.viewModel.deleteOrder(order)
            completion(true)
        })])
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        tableView.backgroundView = nil
        tableView.separatorStyle = .singleLine
        return 1
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let order = viewModel.orders[indexPath.row]

        // Instantiate InvoiceViewController with the Order instance
        let orderViewController = OrderDetailViewController(order, health: viewModel.health)
        orderViewController.delegate = self

        // Present InvoiceViewController
        self.navigationController?.pushViewController(orderViewController, animated: true)
    }
    
    private func showError(_ error: String) {
        showErrorAlertView(error: error)
    }
    
    private func registerForUpdates() {
        viewModel.$orders
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { _ in
                self.reloadTableView()
            }.store(in: &cancellables)
        
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { errorMessage in
                if let errorMessage {
                    self.showError(message: errorMessage)
                }
            }.store(in: &cancellables)
        
        viewModel.$successMessage
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { message in
                if let message {
                    self.showError(message: message)
                }
            }.store(in: &cancellables)
    }
}

extension OrderListViewController: OrderListViewControllerProtocol {
    func showActivityIndicator() {
        self.activityIndicator.startAnimating()
        self.view.addSubview(self.activityIndicator)
    }
    
    func hideActivityIndicator() {
        self.activityIndicator.stopAnimating()
    }
    
    func reloadTableView() {
        self.tableView.reloadData()
    }
    
    func showErrorAlertView(error: String) {
        let alertController = UIAlertController(title: viewModel.errorTitleText, 
                                                message: error,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alertController, animated: true)
    }
}

extension OrderListViewController: OrderDetailViewControllerDelegate {
    func didUpdateOrder(_ order: Order) {
        viewModel.updateOrder(updatedOrder: order)
    }
}

extension OrderListViewController {
    private enum Constants {
        static let padding: CGFloat = 0
        static let rowHeight: CGFloat = 80
    }
}
