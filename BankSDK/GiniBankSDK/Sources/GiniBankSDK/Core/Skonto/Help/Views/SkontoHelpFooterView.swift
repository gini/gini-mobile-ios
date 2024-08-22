//
//  SkontoHelpFooterView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

class SkontoHelpFooterView: UIView {
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.help.footer.title",
                                                                   comment: "Take a photo of your invoice...")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .giniColorScheme().text.secondary.uiColor()
        titleLabel.font = configuration.textStyleFonts[.body]
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = Constants.labelNumberOfLines
        return titleLabel
    }()

    private let configuration = GiniBankConfiguration.shared

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

private extension SkontoHelpFooterView {
    enum Constants {
        static let labelNumberOfLines: Int = 0
    }
}
