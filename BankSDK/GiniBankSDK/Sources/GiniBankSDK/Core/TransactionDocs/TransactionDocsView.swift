//
//  TransactionDocsView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

/// A delegate protocol for `TransactionDocsView` to notify about updates in the content.
/// Conforming types are notified when the content in the `TransactionDocsView` is updated.
public protocol TransactionDocsViewDelegate: AnyObject {

    /// Notifies the delegate that the content in the `TransactionDocsView` has been updated.
    /// - Parameter transactionDocsView: The `TransactionDocsView` instance that triggered the update.
    func transactionDocsViewDidUpdateContent(_ transactionDocsView: TransactionDocsView)
}

/// A view that displays a list of documents attached to a transaction and allows interaction with them.
/// The `TransactionDocsView` class is responsible for rendering attached documents,
/// binding to a view model, and notifying its delegate when the content is updated.
public class TransactionDocsView: UIView {

    /// The delegate that is notified when the view's content is updated.
    public weak var delegate: TransactionDocsViewDelegate?

    private let configuration = GiniBankConfiguration.shared

    // Cast the coordinator to the internal protocol to access internal properties and methods
    private var internalTransactionDocsDataCoordinator: TransactionDocsDataInternalProtocol? {
        return configuration.transactionDocsDataCoordinator as? TransactionDocsDataInternalProtocol
    }

    private var viewModel: TransactionDocsViewModel? {
        return internalTransactionDocsDataCoordinator?.getTransactionDocsViewModel()
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

    /// Initializes a new instance of `TransactionDocsView`.
    public init() {
        super.init(frame: .zero)
        commonInit()
    }

    /// This initializer is required by `UIView` but is not supported in `TransactionDocsView`.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        guard let internalTransactionDocsDataCoordinator = internalTransactionDocsDataCoordinator else { return }
        let transactionDocs = internalTransactionDocsDataCoordinator.transactionDocs
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
        stackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }

        stackView.addArrangedSubview(headerView)

        for transactionDoc in viewModel?.transactionDocs ?? [] {
            let transactionDocsItemView = createTransactionDocsItemView(for: transactionDoc)
            stackView.addArrangedSubview(transactionDocsItemView)
        }
    }

    private func createTransactionDocsItemView(for transactionDoc: TransactionDoc) -> TransactionDocsItemView {
        let transactionDocsItemView = TransactionDocsItemView(transactionDocsItem: transactionDoc)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(didTapToPreviewDocument(_:)))
        transactionDocsItemView.addGestureRecognizer(tapGestureRecognizer)

        transactionDocsItemView.optionsAction = { [weak self] in
            self?.viewModel?.presentDocumentActionSheet(for: transactionDoc)
        }

        return transactionDocsItemView
    }

    // MARK: - Actions
    @objc private func didTapToPreviewDocument(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view as? TransactionDocsItemView,
              let documentId = tappedView.transactionDocsItem?.documentId else { return }
        viewModel?.handlePreviewDocument(for: documentId)
    }
}

// MARK: - Constants

private extension TransactionDocsView {
    enum Constants {
        static let stackViewSpacing: CGFloat = 0
    }
}
