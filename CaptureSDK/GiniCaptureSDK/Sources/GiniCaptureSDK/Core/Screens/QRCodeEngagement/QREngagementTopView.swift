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
        label.font = configuration.textStyleFonts[.headline]
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var stepViews: [UIView] = []
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
        for _ in 0..<3 {
            let view = UIView()
            view.layer.cornerRadius = Constants.segmentCornerRadius
            view.clipsToBounds = true
            view.backgroundColor = .lightGray
            stepViews.append(view)
            stepsStackView.addArrangedSubview(view)
        }

        let containerStack = UIStackView(arrangedSubviews: [pageLabel, stepsStackView])
        containerStack.axis = .horizontal
        containerStack.alignment = .fill
        containerStack.distribution = .fill
        containerStack.spacing = Constants.spacingBetween
        containerStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(containerStack)

        NSLayoutConstraint.activate([
            containerStack.topAnchor.constraint(equalTo: topAnchor, constant: Constants.topSpacing),
            containerStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.bottomSpacing),
            containerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalPadding),
            containerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalPadding),
            heightAnchor.constraint(equalToConstant: Constants.viewHeight)
        ])
    }

    func update(currentStep: Int, totalSteps: Int) {
        pageLabel.text = "\(currentStep) / \(totalSteps)"

        for (index, stepView) in stepViews.enumerated() {
            if index == currentStep - 1 {
                stepView.backgroundColor = .blue
            } else {
                stepView.backgroundColor = .lightGray
            }
        }
    }
}

private extension QREngagementTopView {
    enum Constants {
        static let spacingBetween: CGFloat = 8
        static let horizontalPadding: CGFloat = 16
        static let topSpacing: CGFloat = 8
        static let bottomSpacing: CGFloat = 8
        static let viewHeight: CGFloat = 44
        static let segmentCornerRadius: CGFloat = 4
    }
}
