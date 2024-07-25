//
//  InvoiceDetailView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

class InvoiceDetailView: UIStackView {

    static var textViews = [String: UITextView]()

    convenience init(_ items: [(String, String)]) {
        Self.textViews.removeAll()
        self.init(arrangedSubviews: items.map { Self.view(for: $0) })

        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical
        distribution = .fill
        alignment = .fill
        spacing = 0
    }

    private class func view(for text: (String, String)) -> UIView {

        let horizontalStackView = UIStackView()
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.axis = .horizontal
        horizontalStackView.distribution = .fill
        horizontalStackView.spacing = 0

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text.0
        label.numberOfLines = 0
        label.textAlignment = .left
        label.widthAnchor.constraint(equalToConstant: Constants.labelWidth - Constants.horizontalSpacing).isActive = true

        let textView = UITextView()
        textViews[text.0] = textView
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = text.1
        textView.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)

        horizontalStackView.addArrangedSubview(label)
        horizontalStackView.addArrangedSubview(textView)

        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        containerView.addSubview(horizontalStackView)

        let bottomLine = UIView()
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        bottomLine.backgroundColor = .darkGray
        containerView.addSubview(bottomLine)

        NSLayoutConstraint.activate([
            horizontalStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.paddingLeadingTrailing),
            horizontalStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.paddingLeadingTrailing),
            horizontalStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.labelTopBottom),
            horizontalStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constants.labelTopBottom),

            bottomLine.heightAnchor.constraint(equalToConstant: 0.5),
            bottomLine.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            bottomLine.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            bottomLine.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        return containerView
    }

}

extension InvoiceDetailView {
    enum Constants {
        static let paddingLeadingTrailing = 16.0
        static let labelTopBottom = 16.0
        static let horizontalSpacing = 8.0
        static let labelWidth = 100.0
    }
}
