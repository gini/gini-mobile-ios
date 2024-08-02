//
//  SkontoInvoicePreviewView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

class SkontoInvoicePreviewView: UIView {
    private lazy var imageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = GiniColor(light: .GiniBank.light2, dark: .GiniBank.dark4).uiColor()
        view.layer.cornerRadius = Constants.imageViewCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var invoicePreviewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = GiniImages.invoicePlaceholderIcon.image
        imageView.tintColor = .giniColorScheme().icons.standardTertiary.uiColor()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        let title = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.invoice.title",
                                                             comment: "Your invoice")
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
        addSubview(imageContainerView)
        imageContainerView.addSubview(invoicePreviewImageView)
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(subtitleLabel)
        addSubview(textStackView)
        addSubview(chevronImageView)

        NSLayoutConstraint.activate([
            imageContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.imageViewLeading),
            imageContainerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageContainerView.widthAnchor.constraint(equalToConstant: Constants.imageViewSize),
            imageContainerView.heightAnchor.constraint(equalToConstant: Constants.imageViewSize),

            invoicePreviewImageView.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor,
                                                             constant: Constants.imageViewPadding),
            invoicePreviewImageView.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor,
                                                              constant: -Constants.imageViewPadding),
            invoicePreviewImageView.topAnchor.constraint(equalTo: imageContainerView.topAnchor,
                                                         constant: Constants.imageViewPadding),
            invoicePreviewImageView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor,
                                                            constant: -Constants.imageViewPadding),

            textStackView.topAnchor.constraint(equalTo: topAnchor),
            textStackView.leadingAnchor.constraint(equalTo: imageContainerView.trailingAnchor,
                                                   constant: Constants.stackViewLeading),
            textStackView.trailingAnchor.constraint(lessThanOrEqualTo: chevronImageView.leadingAnchor),
            textStackView.centerYAnchor.constraint(equalTo: centerYAnchor),

            chevronImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.chevronTrailing),
            chevronImageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

private extension SkontoInvoicePreviewView {
    enum Constants {
        static let stackViewSpacing: CGFloat = 0
        static let imageViewSize: CGFloat = 40
        static let imageViewLeading: CGFloat = 0
        static let stackViewLeading: CGFloat = 12
        static let chevronTrailing: CGFloat = 8
        static let imageViewPadding: CGFloat = 7
        static let imageViewCornerRadius: CGFloat = 6
    }
}
