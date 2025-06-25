//
//  QRCodeEducationLoadingView.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit
import Combine

final class QRCodeEducationLoadingView: UIView {

    struct Style {
        let textColor: UIColor
        let analysingTextColor: UIColor
        let useDarkAppearance: Bool

        private static let defaultTextColor = GiniColor(light: .GiniCapture.dark1,
                                                        dark: .GiniCapture.light1).uiColor()
        private static let defaultAnalysingTextColor = GiniColor(light: .GiniCapture.dark6,
                                                                 dark: .GiniCapture.light6).uiColor()

        init(textColor: UIColor = defaultTextColor,
             analysingTextColor: UIColor = defaultAnalysingTextColor,
             useDarkAppearance: Bool = false) {
            self.textColor = textColor
            self.analysingTextColor = analysingTextColor
            self.useDarkAppearance = useDarkAppearance
        }
    }

    private let giniConfiguration = GiniConfiguration.shared
    private let viewModel: QRCodeEducationLoadingViewModel
    private let style: Style
    private var cancellables = Set<AnyCancellable>()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isAccessibilityElement = false
        return imageView
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = giniConfiguration.textStyleFonts[.bodyBold]
        label.textColor = style.textColor
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.isAccessibilityElement = false
        label.numberOfLines = 0
        return label
    }()

    private lazy var animatedSuffixLabelView: GiniAnimatedSuffixLabelView = {
        let labelFont = giniConfiguration.textStyleFonts[.caption1]
        let view = GiniAnimatedSuffixLabelView(baseText: Strings.loadingBaseText,
                                               font: labelFont,
                                               textColor: style.analysingTextColor)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isAccessibilityElement = false
        return view
    }()

    init(viewModel: QRCodeEducationLoadingViewModel, style: Style = .init()) {
        self.viewModel = viewModel
        self.style = style
        super.init(frame: .zero)
        if style.useDarkAppearance {
            overrideUserInterfaceStyle = .dark
        }
        bind()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func removeFromSuperview() {
        super.removeFromSuperview()
        animatedSuffixLabelView.stopAnimating()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // Call when horizontal/vertical size class or orientation may have changed
        configureImageViewVisibility()
    }

    private func setupViews() {
        configureImageViewVisibility()

        addSubview(imageView)
        addSubview(textLabel)
        addSubview(animatedSuffixLabelView)
        animatedSuffixLabelView.startAnimating()

        if isAccessibilityDeviceWithoutNotch {
            configureWithoutNotchConstraints()
        } else {
            configureStandardNotchConstraints()
        }
    }

    private var isAccessibilityDeviceWithoutNotch: Bool {
        let isAccessibilityCategory = GiniAccessibility.isFontSizeAtLeastAccessibilityMedium
        let isIPhoneWithoutNotch = UIDevice.current.isIphone && !UIDevice.current.hasNotch
        return isIPhoneWithoutNotch && isAccessibilityCategory
    }

    private func configureImageViewVisibility() {
        // Hide image view on devices without notch and 200% font size enabled
        // Hide image view on landscape iPhone with bottom navigation bar enabled and 200% font size enabled
        let navigationBottomBarEnabled = giniConfiguration.bottomNavigationBarEnabled
        let isLandscapeWithBottomBar = navigationBottomBarEnabled && UIDevice.current.isIphoneAndLandscape
        let shouldHideImageView = isAccessibilityDeviceWithoutNotch || isLandscapeWithBottomBar
        || (isAccessibilityDeviceWithoutNotch && navigationBottomBarEnabled)

        imageView.isHidden = shouldHideImageView
    }

    private func configureWithoutNotchConstraints() {
        if isAccessibilityDeviceWithoutNotch && giniConfiguration.bottomNavigationBarEnabled {
            // Allow vertical compression so the label doesn't push other UI elements in compact layouts
            textLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        } else {
            // Prevent compression to ensure the label remains fully visible when layout space allows
            textLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        }

        NSLayoutConstraint.activate([
            // Text label positioned at top (where image would be)
            textLabel.topAnchor.constraint(equalTo: topAnchor),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            // Animated suffix label with adjusted spacing
            animatedSuffixLabelView.topAnchor.constraint(greaterThanOrEqualTo: textLabel.bottomAnchor,
                                                         constant: Constants.minTextToAnalysingSpacing),
            animatedSuffixLabelView.leadingAnchor.constraint(equalTo: leadingAnchor),
            animatedSuffixLabelView.trailingAnchor.constraint(equalTo: trailingAnchor),
            animatedSuffixLabelView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func configureStandardNotchConstraints() {
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
                                                         constant: Constants.minTextToAnalysingSpacing)
        ])

        let bottomConstraint = animatedSuffixLabelView.bottomAnchor.constraint(equalTo: bottomAnchor)
        bottomConstraint.priority = .defaultHigh
        bottomConstraint.isActive = true
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

    private func configure(with model: QRCodeEducationLoadingItem) {
        imageView.image = model.image
        textLabel.text = model.text
        let announcementArgument = model.text + "\n" + Strings.loadingAccessibilityText
        UIAccessibility.post(notification: .announcement, argument: announcementArgument)
    }
}

private extension QRCodeEducationLoadingView {
    enum Constants {
        static let imageToTextSpacing: CGFloat = 16
        static let imageToAnalysingSpacing: CGFloat = 98
        static let minTextToAnalysingSpacing: CGFloat = 16
    }
}

private extension QRCodeEducationLoadingView {
    struct Strings {
        static let loadingBaseText = NSLocalizedStringPreferredFormat("ginicapture.analysis.education.loadingText",
                                                                      comment: "analyzing")

        static let loadingAccessibilityLocalizedStringKey = "ginicapture.education.loading.accessibility"
        static let loadingAccessibilityText = NSLocalizedStringPreferredFormat(loadingAccessibilityLocalizedStringKey,
                                                                               comment: "analyzing")
    }
}
