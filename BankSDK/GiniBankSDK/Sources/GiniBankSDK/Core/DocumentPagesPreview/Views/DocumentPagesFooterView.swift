//
//  DocumentPagesFooterView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

final class DocumentPagesFooterView: UIView {

    private lazy var footerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        stackView.spacing = Constants.stackViewItemSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let configuration = GiniBankConfiguration.shared

    init() {
        super.init(frame: .zero)
        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .GiniBank.dark1.withAlphaComponent(0.5)
        addSubview(footerStackView)
    }

    private func setupConstraints() {
        let bottomSafeAreaHeight = UIApplication.shared.safeAreaInsets.bottom
        let stackViewBottomConstraint = bottomSafeAreaHeight + Constants.stackViewBottomPadding
        NSLayoutConstraint.activate([
            footerStackView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                     constant: Constants.stackViewDefaultPadding),
            footerStackView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                      constant: -Constants.stackViewDefaultPadding),
            footerStackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.stackViewDefaultPadding),
            footerStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -stackViewBottomConstraint)
        ])
    }

    func updateFooter(with items: [String]) {
        footerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for item in items {
            let label = UILabel()
            label.text = item
            label.font = configuration.textStyleFonts[.footnote]
            label.textColor = .GiniBank.light1
            label.translatesAutoresizingMaskIntoConstraints = false
            footerStackView.addArrangedSubview(label)
        }
    }
}

private extension DocumentPagesFooterView {
    enum Constants {
        static let stackViewBottomPadding: CGFloat = 25
        static let stackViewDefaultPadding: CGFloat = 16
        static let stackViewItemSpacing: CGFloat = 4
    }
}
