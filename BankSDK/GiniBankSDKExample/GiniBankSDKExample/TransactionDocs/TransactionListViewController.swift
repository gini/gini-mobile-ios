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

    private func setupUI() {
        view.backgroundColor = GiniColor(light: .GiniBank.light2, dark: .GiniBank.dark2).uiColor()
        tableView.dataSource = self
        tableView.delegate = self

        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 65

        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constants.padding, right: 0)

        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
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
    }

    private func configureRoundedCorners(for cell: UITableViewCell, at indexPath: IndexPath, in tableView: UITableView) {
        // Ensure this logic only applies to the "transactionCell" section
        guard Section(rawValue: indexPath.section) == .transactionCell else {
            cell.contentView.layer.cornerRadius = 0
            cell.contentView.layer.maskedCorners = []
            return
        }

        let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
        let cornerRadius: CGFloat = 12

        // Reset rounded corners
        cell.contentView.layer.cornerRadius = 0
        cell.contentView.layer.maskedCorners = []
        cell.contentView.layer.masksToBounds = true // Prevent clipping issues

        if indexPath.row == 0 && numberOfRows > 1 {
            // First cell: Round top corners
            cell.contentView.layer.cornerRadius = cornerRadius
            cell.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if indexPath.row == numberOfRows - 1 {
            // Last cell: Round bottom corners
            cell.contentView.layer.cornerRadius = cornerRadius
            cell.contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }

    private func displayTransactionDetails(for transaction: Transaction) {
        let transactionDetailsViewController = TransactionDetailsViewController()
        transactionDetailsViewController.transactionData = transaction
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
        transactionDocsDataCoordinator.transactionDocs = transaction.attachments.map { attachment in
            //TODO: this is hardcoded for now, we need to get the filename from backend
            var attachmentFileName = attachment.filename + ".png"
            if attachment.filename.contains("pdf") {
                attachmentFileName = attachment.filename
            }
            let docType: TransactionDocType = (attachment.type == .image) ? .image : .document
            return TransactionDoc(documentId: attachment.documentId,
                                  fileName: attachmentFileName,
                                  type: docType)
        }

        bankSDK.handleTransactionDocsDataLoading(for: transaction.attachments[0].documentId)
        displayTransactionDetails(for: transaction)
    }

    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
}

private extension TransactionListViewController {
    enum Constants {
        static let padding: CGFloat = 16
    }
}

