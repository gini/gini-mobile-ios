//
//  ExtractionResultCell.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

/// A unified, fully programmatic extraction result cell used in both the SEPA and
/// cross-border payment flows. Pass `isEditable: false` to render the value as
/// a read-only, dimmed field; pass `true` to allow the user to edit it.
final class ExtractionResultCell: UITableViewCell, CodeLoadableView {

    // MARK: - Subviews

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = GiniColor(light: .white, dark: .GiniBank.dark3).uiColor()
        view.layer.cornerRadius = Constants.cornerRadius
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.titleFontSize, weight: .semibold)
        label.textColor = GiniColor(light: giniCaptureColor("Accent01"),
                                    dark: giniCaptureColor("Accent01")).uiColor()
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private(set) lazy var valueTextField: UITextField = {
        let field = UITextField()
        field.font = .systemFont(ofSize: Constants.valueFontSize)
        field.borderStyle = .none
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Configuration

    func configure(title: String,
                   value: String?,
                   isEditable: Bool,
                   returnKeyType: UIReturnKeyType = .done) {
        titleLabel.text = title
        valueTextField.text = value
        valueTextField.isEnabled = isEditable
        valueTextField.alpha = isEditable ? 1.0 : Constants.dimmedAlpha
        valueTextField.returnKeyType = returnKeyType

        let accentColor = GiniColor(light: giniCaptureColor("Accent01"),
                                    dark: giniCaptureColor("Accent01")).uiColor()
        valueTextField.textColor = isEditable ? accentColor : .gray
    }

    // MARK: - Layout

    private func setupView() {
        selectionStyle = .none
        backgroundColor = .clear

        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(valueTextField)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                   constant: Constants.outerPadding),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                    constant: -Constants.outerPadding),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor,
                                               constant: Constants.outerVerticalPadding),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                  constant: -Constants.outerVerticalPadding),

            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,
                                                constant: Constants.innerPadding),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,
                                                 constant: -Constants.innerPadding),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor,
                                            constant: Constants.innerPadding),

            valueTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,
                                                    constant: Constants.innerPadding),
            valueTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,
                                                     constant: -Constants.innerPadding),
            valueTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
                                                constant: Constants.labelToFieldSpacing),
            valueTextField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor,
                                                   constant: -Constants.innerPadding),
        ])
    }
}

// MARK: - Constants

private extension ExtractionResultCell {
    enum Constants {
        static let cornerRadius: CGFloat = 8
        static let outerPadding: CGFloat = 10
        static let outerVerticalPadding: CGFloat = 5
        static let innerPadding: CGFloat = 10
        static let labelToFieldSpacing: CGFloat = 4
        static let titleFontSize: CGFloat = 14
        static let valueFontSize: CGFloat = 16
        static let dimmedAlpha: CGFloat = 0.5
    }
}
