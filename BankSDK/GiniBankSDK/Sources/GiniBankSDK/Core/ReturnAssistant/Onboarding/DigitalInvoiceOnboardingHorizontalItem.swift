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
    private lazy var infoStackView: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [
                firstLabel,
                secondLabel,
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
                doneButton,
            ]
        )
        stack.spacing = 40
        stack.axis = .vertical
        stack.alignment = .center

        stack.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.widthAnchor.constraint(equalToConstant: 276),
            doneButton.widthAnchor.constraint(equalToConstant: 170),
            doneButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        return stack
    }()

    private lazy var rightStackViewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(rightStackView)
        NSLayoutConstraint.activate([
            rightStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            rightStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        return view
    }()

    private var topImage: UIImage {
        return prefferedImage(named: "digital_invoice_onboarding_icon") ?? UIImage()
    }

    private var firstLabelText: String {
        return  NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.onboarding.text1",
                                                         comment: "title for digital invoice onboarding screen")
    }

    private var secondLabelText: String {
        return NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.onboarding.text2",
                                                        comment: "second label title for digital invoice onboarding screen")
    }

    private var doneButtonTitle: String {
        return NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.onboarding.getStartedButton",
                                                        comment: "get started button title for digital invoice onboarding screen")
    }

    init(with configuration: GiniBankConfiguration, frame: CGRect = .zero, onDone: @escaping () -> Void) {
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
        secondLabel.textColor = GiniColor(light: .GiniBank.dark6, dark: .GiniBank.dark7).uiColor()
        secondLabel.adjustsFontForContentSizeCategory = true

        // done button
        doneButton.addTarget(self, action: #selector(doneAction(_:)), for: .touchUpInside)
        doneButton.setTitle(doneButtonTitle, for: .normal)
        doneButton.titleLabel?.font = configuration.textStyleFonts[.bodyBold]
        doneButton.titleLabel?.adjustsFontForContentSizeCategory = true
        doneButton.configure(with: configuration.primaryButtonConfiguration)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = GiniColor(light: UIColor.GiniBank.light2, dark: UIColor.GiniBank.dark2).uiColor()

        addSubview(topImageView)
        addSubview(rightStackViewContainer)

        topImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topImageView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.paddingLarge),
            topImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.paddingLarge),
            topImageView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: Constants.paddingLarge),
            topImageView.widthAnchor.constraint(equalToConstant: 220),

            rightStackViewContainer.topAnchor.constraint(equalTo: topAnchor),
            rightStackViewContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            rightStackViewContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            rightStackViewContainer.leadingAnchor.constraint(equalTo: topImageView.trailingAnchor)
        ])
    }

    @objc func doneAction(_ sender: UIButton!) {
        onDone()
    }
}

private extension DigitalInvoiceOnboardingHorizontalItem {
    enum Constants {
        static let paddingLarge: CGFloat = 56
    }
}
