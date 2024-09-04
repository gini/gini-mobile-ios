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
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = Constants.stackViewSpacing
        stackView.backgroundColor = .clear
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var headerView: TransactionDocsHeaderView = {
        return TransactionDocsHeaderView()
    }()

    private lazy var footerView: TransactionDocsFooterView = {
        let footerView = TransactionDocsFooterView()
        footerView.addButtonAction = { [weak self] in
            self?.addTransactionDoc()
        }
        return footerView
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
        backgroundColor = .giniColorScheme().bg.surface.uiColor()
        addSubview(containerView)
        containerView.addSubview(stackView)

        setupStackViewContent()
        setupConstraints()
    }

    private func setupStackViewContent() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        stackView.addArrangedSubview(headerView)

        for (index, transactionDoc) in transactionDocs.enumerated() {
            let transactionDocsItemView = TransactionDocsItemView(transactionDoc: transactionDoc)
            transactionDocsItemView.optionsAction = { [weak self] in
                guard let self, let presentingViewController  else { return }
                let deleteAction = { self.deleteTransactionDoc(at: index) }
                TransactionDocActionsBottomSheet.showDeleteAlert(on: presentingViewController,
                                                                 deleteHandler: deleteAction,
                                                                 cancelHandler: {})
            }
            stackView.addArrangedSubview(transactionDocsItemView)
        }

        stackView.addArrangedSubview(footerView)
        delegate?.transactionDocsViewDidUpdateContent(self)
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
                                              constant: -Constants.stackViewPadding)
        ])
    }

    @objc private func addTransactionDoc() {
        transactionDocs.append(.init(fileName: UUID().uuidString, type: .document))
        setupStackViewContent()
    }

    private func deleteTransactionDoc(at index: Int) {
        transactionDocs.remove(at: index)
        setupStackViewContent()
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
    }
}
