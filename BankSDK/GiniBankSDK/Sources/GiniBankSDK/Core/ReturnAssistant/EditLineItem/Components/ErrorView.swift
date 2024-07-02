//
//  ErrorView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

final class ErrorView: UIView {
	private lazy var configuration = GiniBankConfiguration.shared

	private let contentView = UIView()

	private lazy var errorLabel: UILabel = {
		let label = UILabel()
		label.adjustsFontForContentSizeCategory = true
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .GiniBank.error3
		if let font = configuration.textStyleFonts[.caption2] {
			if font.pointSize > Constants.maximumFontSize {
				label.font = font.withSize(Constants.maximumFontSize)
			} else {
				label.font = font
			}
		}

		return label
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
		setupConstraints()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupView() {
		backgroundColor = .clear
		addSubview(contentView)
		addSubview(errorLabel)
	}

	private func setupConstraints() {
		NSLayoutConstraint.activate([
			contentView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
			contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
			contentView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: 0),
			errorLabel.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
			errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.errorHorizontalPadding),
			errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.errorHorizontalPadding),
			errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
		])
	}

	func set(errorTitle: String) {
		errorLabel.text = errorTitle
	}
}

private extension ErrorView {
	enum Constants {
		static let maximumFontSize: CGFloat = 20
		static let errorHorizontalPadding: CGFloat = 16
		static let errorVerticalPadding: CGFloat = 4
	}
}
