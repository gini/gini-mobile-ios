//
//  TransactionListViewController.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//


import UIKit
import GiniBankSDK
import GiniCaptureSDK
import GiniBankAPILibrary

class TransactionListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let tableView = UITableView()

    private var transactions: [Transaction] = []
    private var bankSDK: GiniBank

    private let transactionDocsDataCoordinator = GiniBankConfiguration.shared.transactionDocsDataCoordinator

    init() {
        let apiLib = GiniBankAPI.Builder(client: CredentialsManager.fetchClientFromBundle()).build()
        bankSDK = GiniBank(with: apiLib)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    private func setupUI() {
        view.backgroundColor = GiniColor(light: .GiniBank.light2, dark: .GiniBank.dark2).uiColor()
        tableView.dataSource = self
        tableView.delegate = self

        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Constants.estimatedRowHeight

        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInset = Constants.tableContentInset

        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = Constants.sectionHeaderTopPadding
        }

        tableView.register(TransactionCell.self)
        tableView.register(TransactionListTableViewHeader.self)

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.padding),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.padding),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.padding),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])


        let cancelButton = GiniBarButton(ofType: .cancel)
        cancelButton.addAction(self, #selector(closeButtonTapped))
        navigationItem.leftBarButtonItem = cancelButton.barButton
    }

    private func loadData() {
        let fileManager = FileManagerHelper(fileName: "transaction_list.json")
        // Read transactions (automatically creates an empty file if it doesn't exist)
        let transactions: [Transaction] = fileManager.read()
        self.transactions = transactions.sorted { $0.date > $1.date }

       transactionDocsDataCoordinator.presentingViewController = navigationController

        let mappedTransactions = self.transactions.map { transaction in
            GiniTransaction(
                identifier: transaction.identifier,
                transactionDocs: transaction.attachments.map { attachment in
                    GiniTransactionDoc(
                        documentId: attachment.documentId,
                        originalFileName: attachment.filename
                    )
                }
            )
        }

        // Set mapped transactions inside the SDK
        transactionDocsDataCoordinator.setTransactions(mappedTransactions)
    }

    private func configureRoundedCorners(for cell: UITableViewCell, at indexPath: IndexPath, in tableView: UITableView) {
        // Ensure this logic only applies to the "transactionCell" section
        guard Section(rawValue: indexPath.section) == .transactionCell else {
            cell.contentView.layer.cornerRadius = 0
            cell.contentView.layer.maskedCorners = []
            return
        }

        let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)

        // Reset rounded corners
        cell.contentView.layer.cornerRadius = 0
        cell.contentView.layer.maskedCorners = []
        cell.contentView.layer.masksToBounds = true // Prevent clipping issues

        switch indexPath.row {
            case 0 where numberOfRows == 1:
                // If only one cell, round all corners
                cell.contentView.layer.cornerRadius = Constants.cornerRadius
                cell.contentView.layer.maskedCorners = Constants.allCorners
            case 0:
                // First cell: Round top corners
                cell.contentView.layer.cornerRadius = Constants.cornerRadius
                cell.contentView.layer.maskedCorners = Constants.topCorners
            case numberOfRows - 1:
                // Last cell: Round bottom corners
                cell.contentView.layer.cornerRadius = Constants.cornerRadius
                cell.contentView.layer.maskedCorners = Constants.bottomCorners
            default:
                break
        }
    }

    private func displayTransactionDetails(for transaction: Transaction) {
        let transactionDetailsViewController = TransactionDetailsViewController()
        transactionDetailsViewController.transactionData = transaction
        transactionDetailsViewController.delegate = self
        navigationController?.pushViewController(transactionDetailsViewController, animated: true)
    }

    // MARK: - TableViewDataSource and TableViewDelegate
    // MARK: - UITableViewDelegate
    enum Section: Int, CaseIterable {
        case titleCell
        case transactionCell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
            case .titleCell: return 1
            case .transactionCell: return transactions.count
            default: break
        }
        return 0
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section) {
            case .titleCell:
                let cell = tableView.dequeueReusableCell() as TransactionListTableViewHeader
                return cell
            case .transactionCell:
                let cell = tableView.dequeueReusableCell() as TransactionCell
                cell.configure(with: transactions[indexPath.row], isLastCell: indexPath.row == transactions.count - 1)
                return cell
            default: break
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        configureRoundedCorners(for: cell, at: indexPath, in: tableView)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard Section(rawValue: indexPath.section) == .transactionCell else { return }
        tableView.deselectRow(at: indexPath, animated: true)
        let index = indexPath.row
        let transaction = transactions[index]

        transactionDocsDataCoordinator.setSelectedTransaction(transaction.identifier)
        // please note that setSelectedTransaction should be called before handleTransactionDocsDataLoading
        if !transaction.attachments.isEmpty {
            // do this only if there is a document attached to the transaction to load

            // for now there is one document per transaction that's why we always use the first attachement object
            bankSDK.handleTransactionDocsDataLoading(for: transaction.attachments[0].documentId)
        }
        displayTransactionDetails(for: transaction)
    }

    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
}

extension TransactionListViewController: TransactionDetailsViewDelegate {
    func transactionDetailsViewDidUpdate(_ transaction: Transaction) {
        // Find the transaction by matching unique fields (date + paymentReference + paymentRecipient)
        if let index = transactions.firstIndex(where: {
            $0.date == transaction.date &&
            $0.paymentReference == transaction.paymentReference &&
            $0.paymentRecipient == transaction.paymentRecipient
        }) {
            transactions[index] = transaction
        }

        // Save updated transactions list to file
        let fileManager = FileManagerHelper(fileName: "transaction_list.json")
        fileManager.write(transactions) // Persist updated transactions
    }
}

private extension TransactionListViewController {
    enum Constants {
        static let padding: CGFloat = 16
        static let sectionHeaderTopPadding: CGFloat = 0
        static let estimatedRowHeight: CGFloat = 65
        static let tableContentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constants.padding, right: 0)
        static let cornerRadius: CGFloat = 12
        static let allCorners: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner,
                                               .layerMinXMaxYCorner, .layerMinXMaxYCorner]
        static let topCorners: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        static let bottomCorners: CACornerMask = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
}

