//
//  QREngagementProgressView.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

class QREngagementProgressView: UIView {
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
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(pageLabel)
        addSubview(stepsStackView)

        NSLayoutConstraint.activate([
            pageLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.topSpacing),
            pageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalPadding),
            pageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.bottomSpacing),

            stepsStackView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                     constant: -Constants.horizontalPadding),
            stepsStackView.leadingAnchor.constraint(equalTo: pageLabel.trailingAnchor,
                                                    constant: Constants.spacingBetween),
            stepsStackView.centerYAnchor.constraint(equalTo: pageLabel.centerYAnchor),
            stepsStackView.heightAnchor.constraint(equalToConstant: Constants.stepViewHeight)
        ])
    }

    func update(currentStep: Int, totalSteps: Int) {
        pageLabel.text = "\(currentStep) / \(totalSteps)"
        if stepsStackView.arrangedSubviews.count != totalSteps {
            setupSteps(totalSteps: totalSteps)
        }
        for (index, stepView) in stepsStackView.arrangedSubviews.enumerated() {
            stepView.backgroundColor = (index == currentStep - 1) ? Constants.selectedStepColor : Constants.stepColor
        }
    }

    private func setupSteps(totalSteps: Int) {
        stepsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for _ in 0..<totalSteps {
            let view = UIView()
            view.layer.cornerRadius = Constants.stepViewHeight / 2
            view.clipsToBounds = true
            view.backgroundColor = Constants.stepColor
            stepsStackView.addArrangedSubview(view)
        }
    }
}

private extension QREngagementProgressView {
    enum Constants {
        static let spacingBetween: CGFloat = 8
        static let horizontalPadding: CGFloat = 16
        static let topSpacing: CGFloat = 11
        static let bottomSpacing: CGFloat = 6
        static let stepViewHeight: CGFloat = 4
        static let stepColor = GiniColor(light: UIColor.GiniCapture.dark1,
                                         dark: UIColor.GiniCapture.light1).uiColor().withAlphaComponent(0.3)
        static let selectedStepColor = GiniColor(light: UIColor.GiniCapture.accent1,
                                                 dark: UIColor.GiniCapture.accent1).uiColor()
    }
}
