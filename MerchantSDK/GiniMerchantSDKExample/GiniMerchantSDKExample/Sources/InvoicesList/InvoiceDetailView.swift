//
//  InvoiceDetailView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

@MainActor
class InvoiceDetailView: UIStackView {

    static var textFields = [String: UITextField]()

    convenience init(_ items: [(String, String)]) {
        Self.textFields.removeAll()
        self.init(arrangedSubviews: items.map { Self.view(for: $0) })

        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical
        distribution = .fill
        alignment = .fill
        spacing = Constants.verticalSpacing
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
        label.widthAnchor.constraint(equalToConstant: Constants.labelWidth).isActive = true
        horizontalStackView.addArrangedSubview(label)

        let textField = textFields[text.0, default: UITextField()]
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.text = text.1
        textField.clearButtonMode = .whileEditing
        textField.font = .systemFont(ofSize: UIFont.labelFontSize)
        horizontalStackView.addArrangedSubview(textField)

        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        containerView.addSubview(horizontalStackView)

        let bottomLine = UIView()
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        bottomLine.backgroundColor = .lightGray
        containerView.addSubview(bottomLine)

        let views = ["horizontalStackView": horizontalStackView, "bottomLine": bottomLine]
        NSLayoutConstraint.activate(["H:|-(paddingX)-[horizontalStackView]-(paddingX)-|",
                                     "V:|-(paddingY)-[horizontalStackView]-(paddingY)-|",
                                     "H:|-(paddingX)-[bottomLine]|",
                                     "V:[bottomLine(lineHeight)]-(lineOffset)-|"].flatMap {
            NSLayoutConstraint.constraints(withVisualFormat: $0, options: [], metrics: Constants.metrics, views: views)
        })
        return containerView
    }
}

extension InvoiceDetailView {
    enum Constants {
        static let labelWidth = 92.0
        static let verticalSpacing = 1.0
        static let metrics: [String: CGFloat] = ["paddingX": 16.0, "paddingY": 16.0, "lineHeight": 0.5, "lineOffset": -0.5]
    }
}
