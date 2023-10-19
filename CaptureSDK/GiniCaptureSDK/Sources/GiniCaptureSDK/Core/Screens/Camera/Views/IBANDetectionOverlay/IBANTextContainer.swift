//
//  IBANTextContainer.swift
//
//
//  Created by Valentina Iancu on 16.10.23.
//

import UIKit

final class IBANTextContainer: UIView {
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
        let widthConstraint = widthAnchor.constraint(equalToConstant: Constants.labelWidth)
        widthConstraint.priority = .init(750)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.labelTopMargin),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.labelLeftMargin),
            widthConstraint
        ])
    }

    private enum Constants {
        static let labelLeftMargin: CGFloat = 8
        static let labelTopMargin: CGFloat = 12
        static let labelWidth: CGFloat = UIDevice.current.isIpad ? 290 : 189
    }
}
