//
//  IBANsTextContainer.swift
//
//
//  Created by Valentina Iancu on 16.10.23.
//

import UIKit

final class IBANsTextContainer: UIView {
    private let configuration = GiniConfiguration.shared

    private let titleLabel = UILabel()

    init() {
        super.init(frame: .zero)
        backgroundColor = .GiniCapture.success2
        setupTitleLabel()
        addSubview(titleLabel)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.font = configuration.textStyleFonts[.caption2]
        titleLabel.textColor = UIColor.GiniCapture.light1

        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.adjustsFontForContentSizeCategory = true
    }

    func setTitle(_ title: String) {
        titleLabel.text = title
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.titleTopBottomSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.titleLeftRightSpacing)
        ])
    }

    private enum Constants {
        static let titleLeftRightSpacing: CGFloat = 8
        static let titleTopBottomSpacing: CGFloat = 12
    }
}
