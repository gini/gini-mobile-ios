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

    public weak var presentingViewController: UIViewController?

    private lazy var transactionDocs: [TransactionDoc] = [
        TransactionDoc(fileName: UUID().uuidString, type: .image),
        TransactionDoc(fileName: UUID().uuidString, type: .document)
    ]

    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.borderColor = Constants.containerViewBorderColor.cgColor
        view.layer.borderWidth = Constants.containerViewBorderWidth
        view.layer.cornerRadius = Constants.containerViewBorderCornerRadius
        view.backgroundColor = .giniColorScheme().bg.surface.uiColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

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

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        addSubview(containerView)
        containerView.addSubview(stackView)

        setupStackViewContent()
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,
                                               constant: Constants.stackViewPadding),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,
                                                constant: -Constants.stackViewPadding),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor,
                                           constant: Constants.stackViewPadding),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor,
                                              constant: Constants.stackViewBottomAnchor)
        ])
    }

    private func setupStackViewContent() {
        stackView.addArrangedSubview(headerView)

        for transactionDoc in transactionDocs {
            let transactionDocsItemView = createTransactionDocsItemView(for: transactionDoc)
            stackView.addArrangedSubview(transactionDocsItemView)
        }
    }

    private func createTransactionDocsItemView(for transactionDoc: TransactionDoc) -> TransactionDocsItemView {
        let transactionDocsItemView = TransactionDocsItemView(transactionDoc: transactionDoc)
        transactionDocsItemView.optionsAction = { [weak self] in
            guard let self, let presentingViewController else { return }
            let fileName = transactionDoc.fileName
            let deleteAction = { self.deleteTransactionDoc(with: fileName) }
            TransactionDocActionsBottomSheet.showDeleteAlert(on: presentingViewController,
                                                             deleteHandler: deleteAction,
                                                             cancelHandler: {})
        }
        return transactionDocsItemView
    }

    private func deleteTransactionDoc(with fileName: String) {
        transactionDocs.removeAll(where: { $0.fileName == fileName })
        if let itemView = stackView.arrangedSubviews.first(where: {
            guard let itemView = $0 as? TransactionDocsItemView else { return false }
            return itemView.transactionDoc?.fileName == fileName
        }) {
            self.stackView.removeArrangedSubview(itemView)
            itemView.removeFromSuperview()
            self.delegate?.transactionDocsViewDidUpdateContent(self)
        }
    }
}

private extension TransactionDocsView {
    enum Constants {
        static let containerViewBorderColor: UIColor = .giniColorScheme().bg.border.uiColor()
        static let containerViewBorderWidth: CGFloat = 1.0
        static let containerViewBorderCornerRadius: CGFloat = 8.0
        static let containerViewLeadingAnchor: CGFloat = 16
        static let containerViewTrailingAnchor: CGFloat = -16

        static let stackViewSpacing: CGFloat = 0
        static let stackViewPadding: CGFloat = 0
        static let stackViewBottomAnchor: CGFloat = -12
    }
}
