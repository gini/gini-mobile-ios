//
//  TransactionDocsView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

public protocol TransactionDocsViewDelegate: AnyObject {
    func transactionDocsViewDidUpdateContent(_ transactionDocsView: TransactionDocsView)
}

public class TransactionDocsView: UIView {

    public weak var delegate: TransactionDocsViewDelegate?

    private let configuration = GiniBankConfiguration.shared

    private var viewModel: TransactionDocsViewModel? {
        return configuration.transactionDocsDataCoordinator.getTransactionDocsViewModel()
    }

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = Constants.stackViewSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var headerView: TransactionDocsHeaderView = {
        return TransactionDocsHeaderView()
    }()

    public init() {
        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        let transactionDocs = configuration.transactionDocsDataCoordinator.transactionDocs
        let savedConfiguration = GiniBankUserDefaultsStorage.clientConfiguration
        let transactionDocsEnabled = savedConfiguration?.transactionDocsEnabled ?? false
        guard transactionDocsEnabled, configuration.transactionDocsEnabled, !transactionDocs.isEmpty else { return }

        setupStackViewContent()
        setupConstraints()
        setupViewModelBindings()
    }

    private func setupViewModelBindings() {
        guard let viewModel else { return }
        viewModel.onUpdate = { [weak self] in
            guard let self else { return }
            self.reloadStackViewContent()
            if viewModel.transactionDocs.isEmpty {
                self.stackView.removeFromSuperview()
            }
            self.delegate?.transactionDocsViewDidUpdateContent(self)
        }
    }

    private func setupConstraints() {
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setupStackViewContent() {
        stackView.addArrangedSubview(headerView)
        reloadStackViewContent()
    }

    private func reloadStackViewContent() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        stackView.addArrangedSubview(headerView)

        for transactionDoc in viewModel?.transactionDocs ?? [] {
            let transactionDocsItemView = createTransactionDocsItemView(for: transactionDoc)
            stackView.addArrangedSubview(transactionDocsItemView)
        }
    }

    private func createTransactionDocsItemView(for transactionDoc: TransactionDoc) -> TransactionDocsItemView {
        let transactionDocsItemView = TransactionDocsItemView(transactionDocsItem: transactionDoc)

        transactionDocsItemView.optionsAction = { [weak self] in
            self?.viewModel?.presentDocumentActionSheet(for: transactionDoc)
        }

        return transactionDocsItemView
    }
}

// MARK: - Constants

private extension TransactionDocsView {
    enum Constants {
        static let stackViewSpacing: CGFloat = 0
    }
}
