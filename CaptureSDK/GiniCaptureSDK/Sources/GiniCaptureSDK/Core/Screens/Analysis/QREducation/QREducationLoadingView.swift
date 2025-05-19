//
//  QREducationLoadingView.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit
import Combine

final class QREducationLoadingView: UIView {
    private let giniConfiguration = GiniConfiguration.shared
    private let viewModel: QREducationLoadingViewModel
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
        label.textColor = GiniColor(light: .GiniCapture.dark1, dark: .GiniCapture.light1).uiColor()
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isAccessibilityElement = true
        return label
    }()

    private lazy var dotLoadingView: DotLoadingView = {
        let view = DotLoadingView(
            baseText: NSLocalizedStringPreferredFormat("ginicapture.analysis.education.loadingText",
                                                       comment: "analyzing"),
            font: giniConfiguration.textStyleFonts[.body] ?? .systemFont(ofSize: 17),
            textColor: GiniColor(light: .GiniCapture.dark6, dark: .GiniCapture.dark7).uiColor()
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init(viewModel: QREducationLoadingViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        bind()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func removeFromSuperview() {
        super.removeFromSuperview()
        dotLoadingView.stopAnimating()
    }

    private func setupViews() {
        addSubview(imageView)
        addSubview(textLabel)
        addSubview(dotLoadingView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),

            textLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor,
                                           constant: Constants.imageToTextSpacing),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            dotLoadingView.topAnchor.constraint(greaterThanOrEqualTo: imageView.bottomAnchor,
                                                constant: Constants.imageToAnalysingSpacing),
            dotLoadingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dotLoadingView.trailingAnchor.constraint(equalTo: trailingAnchor),

            dotLoadingView.topAnchor.constraint(greaterThanOrEqualTo: textLabel.bottomAnchor,
                                                constant: Constants.minTextToAnalysingSpacing),
            dotLoadingView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func bind() {
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
        dotLoadingView.startAnimating()
    }
}

private extension QREducationLoadingView {
    enum Constants {
        static let imageToTextSpacing: CGFloat = 16
        static let imageToAnalysingSpacing: CGFloat = 98
        static let minTextToAnalysingSpacing: CGFloat = 16
    }
}
