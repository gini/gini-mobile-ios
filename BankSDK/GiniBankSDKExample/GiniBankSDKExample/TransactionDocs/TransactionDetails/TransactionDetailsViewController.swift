//
//  TransactionDetailsViewController.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//


import UIKit
import GiniBankSDK
import GiniCaptureSDK

class TransactionDetailsViewController: UIViewController {

    var transactionData: Transaction?

    private let tableView = UITableView()
    private var numberOfSections = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        numberOfSections = (transactionData?.attachments.isEmpty ?? true) ? 1 : 2
        title = NSLocalizedStringPreferredFormat("transaction.details.title",
                                                 fallbackKey: "Transaction Details",
                                                 comment: "Title for the transaction details screen",
                                                 isCustomizable: true)
    }

    private func setupUI() {
        view.backgroundColor = .white
        tableView.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self

        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 65

        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false

        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }

        tableView.register(TransactionDetailCell.self)
        tableView.register(AttachmentsTableViewCell.self)

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.tableViewTopPadding),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.padding),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.padding),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Constants.padding)
        ])
    }
}

private extension TransactionDetailsViewController {
    enum Constants {
        static let tableViewTopPadding: CGFloat = 17
        static let padding: CGFloat = 16
    }
}

extension TransactionDetailsViewController:  UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if numberOfSections == 1 {
            return transactionData?.transactionInfo.count ?? 0
        }
        return section == 0 ? transactionData?.transactionInfo.count ?? 0 : 1
    }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell() as TransactionDetailCell
            let detail = transactionData?.transactionInfo[indexPath.row]
            cell.configure(with: detail?.title ?? "", value: detail?.value ?? "")
            return cell
        } else {
            let cell = tableView.dequeueReusableCell() as AttachmentsTableViewCell
            cell.configure(delegate: self)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
extension TransactionDetailsViewController: TransactionDocsViewDelegate {
    func transactionDocsViewDidUpdateContent(_ attachmentsView: TransactionDocsView) {
        numberOfSections = (transactionData?.attachments.isEmpty ?? true) ? 1 : 2
        tableView.reloadData()
    }
}
