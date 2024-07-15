//
//  SkontoInvoicePreviewView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

class SkontoInvoicePreviewView: UIView {
    private lazy var invoicePreviewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = GiniImages.invoicePlaceholderIcon.image
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        let title = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.invoice.title",
                                                             comment: "Invoice")
        label.text = title
        label.accessibilityValue = title
        label.textColor = .giniColorScheme().text.primary.uiColor()
        label.font = configuration.textStyleFonts[.footnoteBold]
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        let title = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.invoice.subtitle",
                                                             comment: "Tap to view")
        label.text = title
        label.accessibilityValue = title
        label.textColor = .giniColorScheme().text.tertiary.uiColor()
        label.font = configuration.textStyleFonts[.footnote]
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = GiniImages.chevronRight.image
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Constants.stackViewSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let configuration = GiniBankConfiguration.shared

    private var viewModel: SkontoViewModel

    init(viewModel: SkontoViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(invoicePreviewImageView)
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(subtitleLabel)
        addSubview(textStackView)
        addSubview(chevronImageView)

        NSLayoutConstraint.activate([
            invoicePreviewImageView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                             constant: Constants.imageViewLeading),
            invoicePreviewImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            invoicePreviewImageView.widthAnchor.constraint(equalToConstant: Constants.imageViewSize),
            invoicePreviewImageView.heightAnchor.constraint(equalToConstant: Constants.imageViewSize),

            textStackView.topAnchor.constraint(equalTo: topAnchor),
            textStackView.leadingAnchor.constraint(equalTo: invoicePreviewImageView.trailingAnchor,
                                                   constant: Constants.stackViewLeading),
            textStackView.trailingAnchor.constraint(lessThanOrEqualTo: chevronImageView.leadingAnchor),
            textStackView.centerYAnchor.constraint(equalTo: centerYAnchor),

            chevronImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Constants.chevronTrailing),
            chevronImageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

private extension SkontoInvoicePreviewView {
    enum Constants {
        static let titleFontSize: CGFloat = 17
        static let subtitleFontSize: CGFloat = 13
        static let stackViewSpacing: CGFloat = 0
        static let imageViewSize: CGFloat = 40
        static let imageViewLeading: CGFloat = 0
        static let stackViewLeading: CGFloat = 12
        static let chevronTrailing: CGFloat = 0
    }
}
