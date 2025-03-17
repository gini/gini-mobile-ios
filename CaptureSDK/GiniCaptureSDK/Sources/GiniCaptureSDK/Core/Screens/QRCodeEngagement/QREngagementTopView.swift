//
//  QREngagementTopView.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

class QREngagementTopView: UIView {
    private let configuration = GiniConfiguration.shared

    private lazy var pageLabel: UILabel = {
        let label = UILabel()
        label.font = configuration.textStyleFonts[.footnoteBold]
        label.textColor = GiniColor(light: UIColor.GiniCapture.dark1,
                                    dark: UIColor.GiniCapture.light1).uiColor()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var stepsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = Constants.spacingBetween
        stack.translatesAutoresizingMaskIntoConstraints = false
        for _ in 0..<3 {
            let view = UIView()
            view.layer.cornerRadius = Constants.stepViewHeight / 2
            view.clipsToBounds = true
            view.backgroundColor = Constants.stepColor
            stack.addArrangedSubview(view)
        }
        return stack
    }()

    private lazy var poweredByLabel: UILabel = {
        let label = UILabel()
        label.text = "Powered by"
        // TODO: body-xs
        label.font = configuration.textStyleFonts[.body]
        label.textColor = GiniColor(light: UIColor.GiniCapture.dark6,
                                    dark: UIColor.GiniCapture.dark7).uiColor()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var poweredByImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = GiniCaptureImages.poweredByGiniLogo.image
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var poweredByStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [poweredByLabel, poweredByImageView])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = Constants.poweredBySpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear
        addSubview(pageLabel)
        addSubview(stepsStackView)
        addSubview(poweredByStackView)

        NSLayoutConstraint.activate([
            pageLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.topSpacing),
            pageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalPadding),

            stepsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalPadding),
            stepsStackView.leadingAnchor.constraint(equalTo: pageLabel.trailingAnchor,
                                                    constant: Constants.spacingBetween),
            stepsStackView.centerYAnchor.constraint(equalTo: pageLabel.centerYAnchor),
            stepsStackView.heightAnchor.constraint(equalToConstant: Constants.stepViewHeight),

            poweredByStackView.topAnchor.constraint(equalTo: pageLabel.bottomAnchor,
                                                    constant: Constants.poweredByTopSpacing),
            poweredByStackView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                         constant: -Constants.horizontalPadding),
            poweredByStackView.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                       constant: -Constants.bottomSpacing)
        ])
    }

    func update(currentStep: Int, totalSteps: Int) {
        pageLabel.text = "\(currentStep) / \(totalSteps)"
        for (index, stepView) in stepsStackView.arrangedSubviews.enumerated() {
            stepView.backgroundColor = (index == currentStep - 1) ? Constants.selectedStepColor : Constants.stepColor
        }
    }
}

private extension QREngagementTopView {
    enum Constants {
        static let spacingBetween: CGFloat = 8
        static let horizontalPadding: CGFloat = 16
        static let topSpacing: CGFloat = 11
        static let bottomSpacing: CGFloat = 8
        static let stepViewHeight: CGFloat = 4
        static let poweredByTopSpacing: CGFloat = 6
        static let poweredBySpacing: CGFloat = 4
        static let stepColor = GiniColor(light: UIColor.GiniCapture.dark1,
                                         dark: UIColor.GiniCapture.light1
                                         ).uiColor().withAlphaComponent(0.3)
        static let selectedStepColor = GiniColor(light: UIColor.GiniCapture.accent1,
                                                 dark: UIColor.GiniCapture.accent1
                                                 ).uiColor()
    }
}
