//
//  QREducationLoadingView.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit
import Combine

final class QREducationLoadingView: UIView {
    
    struct Style {
        let textColor: UIColor
        let analysingTextColor: UIColor

        init(textColor: UIColor = GiniColor(light: .GiniCapture.dark1, dark: .GiniCapture.light1).uiColor(),
             analysingTextColor: UIColor = GiniColor(light: .GiniCapture.dark6, dark: .GiniCapture.dark7).uiColor()) {
            self.textColor = textColor
            self.analysingTextColor = analysingTextColor
        }
    }

    private let giniConfiguration = GiniConfiguration.shared
    private let viewModel: QREducationLoadingViewModel
    private let style: Style
    private var cancellables = Set<AnyCancellable>()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = giniConfiguration.textStyleFonts[.bodyBold]
        label.textColor = style.textColor
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isAccessibilityElement = true
        return label
    }()

    private lazy var animatedSuffixLabelView: AnimatedSuffixLabelView = {
        let view = AnimatedSuffixLabelView(
            baseText: NSLocalizedStringPreferredFormat("ginicapture.analysis.education.loadingText",
                                                       comment: "analyzing"),
            font: giniConfiguration.textStyleFonts[.body] ?? .systemFont(ofSize: 17),
            textColor: GiniColor(light: .GiniCapture.dark6, dark: .GiniCapture.dark7).uiColor()
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init(viewModel: QREducationLoadingViewModel, style: Style = Style()) {
        self.viewModel = viewModel
        self.style = style
        super.init(frame: .zero)
        bind()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func removeFromSuperview() {
        super.removeFromSuperview()
        animatedSuffixLabelView.stopAnimating()
    }

    private func setupViews() {
        addSubview(imageView)
        addSubview(textLabel)
        addSubview(animatedSuffixLabelView)
        animatedSuffixLabelView.startAnimating()

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),

            textLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor,
                                           constant: Constants.imageToTextSpacing),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            animatedSuffixLabelView.topAnchor.constraint(greaterThanOrEqualTo: imageView.bottomAnchor,
                                                constant: Constants.imageToAnalysingSpacing),
            animatedSuffixLabelView.leadingAnchor.constraint(equalTo: leadingAnchor),
            animatedSuffixLabelView.trailingAnchor.constraint(equalTo: trailingAnchor),

            animatedSuffixLabelView.topAnchor.constraint(greaterThanOrEqualTo: textLabel.bottomAnchor,
                                                constant: Constants.minTextToAnalysingSpacing),
            animatedSuffixLabelView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func bind() {
        viewModel.$currentItem
            .compactMap { $0 }
            .prefix(1)
            .sink { [weak self] _ in
                self?.setupViews()
            }
            .store(in: &cancellables)

        viewModel.$currentItem
            .compactMap { $0 }
            .sink { [weak self] item in
                self?.configure(with: item)
            }
            .store(in: &cancellables)
    }

    private func configure(with model: QREducationLoadingItem) {
        imageView.image = model.image
        textLabel.text = model.text
        textLabel.accessibilityLabel = model.text
    }
}

private extension QREducationLoadingView {
    enum Constants {
        static let imageToTextSpacing: CGFloat = 16
        static let imageToAnalysingSpacing: CGFloat = 98
        static let minTextToAnalysingSpacing: CGFloat = 16
    }
}
