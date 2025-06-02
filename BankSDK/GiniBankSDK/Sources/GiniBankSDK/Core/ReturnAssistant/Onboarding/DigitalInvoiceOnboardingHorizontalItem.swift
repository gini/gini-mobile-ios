//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

class DigitalInvoiceOnboardingHorizontalItem: UIView {
    private let onDone: () -> Void
    private let topImageView: OnboardingImageView
    private let firstLabel: UILabel
    private let secondLabel: UILabel
    private let doneButton: MultilineTitleButton
    private lazy var configuration: GiniBankConfiguration = GiniBankConfiguration.shared

    private lazy var infoStackView: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [
                firstLabel,
                secondLabel
            ]
        )
        stack.spacing = 12
        stack.axis = .vertical
        stack.alignment = .center
        return stack
    }()

    private lazy var rightStackView: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [
                infoStackView,
                doneButton
            ]
        )
        stack.spacing = Constants.stackViewItemSpacing
        stack.axis = .vertical
        stack.alignment = .center

        stack.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.widthAnchor.constraint(equalToConstant: Constants.stackViewWidth),
            doneButton.widthAnchor.constraint(greaterThanOrEqualToConstant: Constants.doneButtonMinWidth),
            doneButton.heightAnchor.constraint(equalToConstant: Constants.doneButtonHeight)
        ])
        return stack
    }()

    private lazy var rightStackViewContainerScrollable: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true

        scrollView.addSubview(rightStackView)

        NSLayoutConstraint.activate([
            rightStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            rightStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            rightStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            rightStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            rightStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        return scrollView
    }()

    private var topImage: UIImage {
        return prefferedImage(named: "digital_invoice_onboarding_icon") ?? UIImage()
    }

    private var firstLabelText: String {
        return  NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.onboarding.text1",
                                                         comment: "title for digital invoice onboarding screen")
    }

    private var secondLabelText: String {
        let key = "ginibank.digitalinvoice.onboarding.text2"
        let comment = "second label title for digital invoice onboarding screen"
        return NSLocalizedStringPreferredGiniBankFormat(key, comment: comment)
    }

    private var doneButtonTitle: String {
        let key = "ginibank.digitalinvoice.onboarding.getStartedButton"
        let comment = "get started button title for digital invoice onboarding screen"
        return NSLocalizedStringPreferredGiniBankFormat(key, comment: comment)
    }

    init(frame: CGRect = .zero, onDone: @escaping () -> Void) {
        topImageView = .init()

        firstLabel = .init()
        firstLabel.numberOfLines = 0

        secondLabel = .init()
        secondLabel.numberOfLines = 0
        secondLabel.textAlignment = .center

        doneButton = .init()
        self.onDone = onDone
        super.init(frame: frame)
        // image
        if let adapter = configuration.digitalInvoiceOnboardingIllustrationAdapter {
            topImageView.illustrationAdapter = adapter
        } else {
            topImageView.illustrationAdapter = ImageOnboardingIllustrationAdapter()
            topImageView.icon = topImage
        }
        topImageView.isAccessibilityElement = true
        topImageView.accessibilityValue = firstLabelText
        topImageView.setupView()

        // title
        firstLabel.text = firstLabelText
        firstLabel.font = configuration.textStyleFonts[.title2Bold]
        firstLabel.textColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()
        firstLabel.adjustsFontForContentSizeCategory = true

        // description
        secondLabel.text = secondLabelText
        secondLabel.font = configuration.textStyleFonts[.subheadline]
        secondLabel.textColor = GiniColor(light: .GiniBank.dark6, dark: .GiniBank.light6).uiColor()
        secondLabel.adjustsFontForContentSizeCategory = true

        // done button
        doneButton.addTarget(self, action: #selector(doneAction(_:)), for: .touchUpInside)
        doneButton.setTitle(doneButtonTitle, for: .normal)
        doneButton.titleLabel?.font = configuration.textStyleFonts[.bodyBold]
        doneButton.titleLabel?.adjustsFontForContentSizeCategory = true
        doneButton.configure(with: configuration.primaryButtonConfiguration)
        doneButton.isHidden = shouldHideButton()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = GiniColor(light: UIColor.GiniBank.light2, dark: UIColor.GiniBank.dark2).uiColor()

        addSubview(topImageView)
        addSubview(rightStackViewContainerScrollable)

        topImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topImageView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.paddingLarge),
            topImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.paddingLarge),
            topImageView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor,
                                                  constant: Constants.paddingLarge),
            topImageView.widthAnchor.constraint(equalToConstant: 220),

            // Constraints for the scroll view itself
            rightStackViewContainerScrollable.topAnchor.constraint(equalTo: topImageView.topAnchor),
            rightStackViewContainerScrollable.bottomAnchor.constraint(equalTo: bottomAnchor),
            rightStackViewContainerScrollable.leadingAnchor.constraint(equalTo: topImageView.trailingAnchor,
                                                                       constant: Constants.horizontalSpacingBetweenImageViewAndText),
            rightStackViewContainerScrollable.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
        ])
    }

    @objc func doneAction(_ sender: UIButton!) {
        onDone()
    }
}

private extension DigitalInvoiceOnboardingHorizontalItem {
    enum Constants {
        static let paddingLarge: CGFloat = 56
        static let horizontalSpacingBetweenImageViewAndText: CGFloat = 10
        static let stackViewWidth: CGFloat = 276
        static let stackViewItemSpacing: CGFloat = 40
        static let doneButtonMinWidth: CGFloat = 170
        static let doneButtonHeight: CGFloat = 50
    }

    func shouldHideButton() -> Bool {
        return (GiniBankConfiguration.shared.digitalInvoiceOnboardingNavigationBarBottomAdapter != nil)
    }
}
