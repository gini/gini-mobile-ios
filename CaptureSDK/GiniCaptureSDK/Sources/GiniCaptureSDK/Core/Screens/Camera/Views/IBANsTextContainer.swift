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
        titleLabel.font = configuration.textStyleFonts[.caption2]
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .GiniCapture.light1

        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.adjustsFontForContentSizeCategory = true
    }

    func setTitle(_ title: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.12
        paragraphStyle.alignment = .center
        let attributes: [NSAttributedString.Key: Any] = [.paragraphStyle: paragraphStyle]
        titleLabel.attributedText = NSMutableAttributedString(string: title, attributes: attributes)
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
