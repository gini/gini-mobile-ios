//
//  GiniAnimatedSuffixLabelView.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit
import Combine

final class GiniAnimatedSuffixLabelView: UIView {
    private let textLabel = UILabel()
    private let suffixLabel = UILabel()

    private var animationCancellable: AnyCancellable?
    private var currentStep: Int = 0

    private let baseText: String
    private let suffixSymbol: String
    private let maxSteps: Int
    private let animationInterval: TimeInterval

    init(baseText: String = "",
         suffixSymbol: String = ".",
         maxSteps: Int = 3,
         animationInterval: TimeInterval = 0.4,
         font: UIFont?,
         textColor: UIColor) {

        self.baseText = baseText
        self.suffixSymbol = suffixSymbol
        self.maxSteps = maxSteps
        self.animationInterval = animationInterval

        super.init(frame: .zero)

        setupLabels(font: font, textColor: textColor)
        setupAccessibility()

        let suffixWidth = calculateMaxSuffixWidth(font: font)
        setupLayout(suffixWidth: suffixWidth)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupLabels(font: UIFont?, textColor: UIColor) {
        textLabel.text = baseText
        textLabel.font = font
        textLabel.textColor = textColor
        textLabel.translatesAutoresizingMaskIntoConstraints = false

        suffixLabel.text = ""
        suffixLabel.font = font
        suffixLabel.textColor = textColor
        suffixLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(textLabel)
        addSubview(suffixLabel)
    }

    private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityLabel = baseText
    }

    private func setupLayout(suffixWidth: CGFloat) {
        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -suffixWidth / 2),
            textLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            suffixLabel.leadingAnchor.constraint(equalTo: textLabel.trailingAnchor, constant: 2),
            suffixLabel.centerYAnchor.constraint(equalTo: textLabel.centerYAnchor)
        ])
    }

    private func calculateMaxSuffixWidth(font: UIFont?) -> CGFloat {
        guard let font else { return 0 }
        let fullSuffix = String(repeating: suffixSymbol, count: maxSteps)
        return (fullSuffix as NSString).size(withAttributes: [.font: font]).width
    }

    // MARK: - Animation control

    func startAnimating() {
        stopAnimating()

        animationCancellable = Timer
            .publish(every: animationInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateSuffix()
            }
    }

    func stopAnimating() {
        animationCancellable?.cancel()
        animationCancellable = nil
        currentStep = 0
        suffixLabel.text = ""
    }

    private func updateSuffix() {
        currentStep = (currentStep + 1) % (maxSteps + 1)
        let suffix = String(repeating: suffixSymbol, count: currentStep)
        suffixLabel.text = suffix
        accessibilityLabel = baseText + suffix
    }

    deinit {
        stopAnimating()
    }
}
