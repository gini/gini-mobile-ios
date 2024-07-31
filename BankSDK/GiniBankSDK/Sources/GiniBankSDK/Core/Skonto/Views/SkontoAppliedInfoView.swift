//
//  SkontoInfoMessageView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

class SkontoAppliedInfoView: UIView {
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = GiniImages.infoMessageIcon.image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = configuration.textStyleFonts[.caption1]
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let configuration = GiniBankConfiguration.shared

    private var viewModel: SkontoViewModel

    init(viewModel: SkontoViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
        bindViewModel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .giniColorScheme().chips.assistEnabled.uiColor()
        layer.cornerRadius = Constants.cornerRadius
        layer.masksToBounds = true
        addSubview(imageView)
        addSubview(label)
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor,
                                           constant: Constants.imageVerticalPadding),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor,
                                              constant: -Constants.imageVerticalPadding),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                               constant: Constants.imageHorizontalPadding),
            imageView.widthAnchor.constraint(equalToConstant: Constants.imageSize),
            imageView.heightAnchor.constraint(equalToConstant: Constants.imageSize),

            label.topAnchor.constraint(greaterThanOrEqualTo: topAnchor,
                                       constant: Constants.labelVerticalPadding),
            label.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor,
                                          constant: -Constants.labelVerticalPadding),
            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor,
                                           constant: Constants.labelHorizontalPadding),
            label.trailingAnchor.constraint(equalTo: trailingAnchor,
                                            constant: -Constants.labelHorizontalPadding),
            label.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }

    private func bindViewModel() {
        configure()
        viewModel.addStateChangeHandler { [weak self] in
            guard let self else { return }
            self.configure()
        }
    }

    private func configure() {
        updateLabelText()
        updateColors()
    }

    private func updateLabelText() {
        let edgeCase = viewModel.edgeCase
        let text: String

        switch edgeCase {
        case .expired:
            let localizedText = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.infobanner.edgecase.expired.message",
                                                                         comment: "The %@ discount has expired.")
            text = String.localizedStringWithFormat(localizedText,
                                                    viewModel.formattedPercentageDiscounted)
        case .paymentToday:
            let localizedText = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.infobanner.edgecase.today.message",
                                                                         comment: "Pay today: %@ discount.")
            text = String.localizedStringWithFormat(localizedText,
                                                    viewModel.formattedPercentageDiscounted)
        case .payByCash:
            let localizedText = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.infobanner.edgecase.cash.message",
                                                                         comment: "A %@ discount is available...")
            text = String.localizedStringWithFormat(localizedText,
                                                    viewModel.formattedPercentageDiscounted,
                                                    viewModel.localizedRemainingDays)
        default:
            let localizedText = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.infobanner.default.message",
                                                                         comment: "Pay in %@: %@ Skonto discount.")
            text = String.localizedStringWithFormat(localizedText,
                                                    viewModel.localizedRemainingDays,
                                                    viewModel.formattedPercentageDiscounted)
        }

        label.text = text
        label.accessibilityValue = text
    }

    private func updateColors() {
        let edgeCase = viewModel.edgeCase
        let tintColor: UIColor
        let backgroundColor: UIColor

        switch edgeCase {
        case .expired:
            tintColor = GiniColor(light: .GiniBank.error2, dark: .GiniBank.error2).uiColor()
            backgroundColor = GiniColor(light: .GiniBank.error5, dark: .GiniBank.error5).uiColor()
        case .paymentToday, .payByCash:
            tintColor = GiniColor(light: .GiniBank.warning2, dark: .GiniBank.warning2).uiColor()
            backgroundColor = GiniColor(light: .GiniBank.warning5, dark: .GiniBank.warning5).uiColor()
        default:
            tintColor = .giniColorScheme().chips.textAssistEnabled.uiColor()
            backgroundColor = .giniColorScheme().chips.assistEnabled.uiColor()
        }

        label.textColor = tintColor
        imageView.tintColor = tintColor
        self.backgroundColor = backgroundColor
    }
}

private extension SkontoAppliedInfoView {
    enum Constants {
        static let imageVerticalPadding: CGFloat = 10
        static let imageHorizontalPadding: CGFloat = 10
        static let imageSize: CGFloat = 24
        static let labelHorizontalPadding: CGFloat = 8
        static let labelVerticalPadding: CGFloat = 10
        static let cornerRadius: CGFloat = 8
    }
}
