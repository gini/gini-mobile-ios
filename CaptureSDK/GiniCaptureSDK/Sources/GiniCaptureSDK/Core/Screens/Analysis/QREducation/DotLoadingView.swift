//
//  DotLoadingView.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit
import Combine

class DotLoadingView: UIView {
    private let textLabel = UILabel()
    private let animatedDotsLabel = UILabel()

    private var animationCancellable: AnyCancellable?
    private var currentDotCount = 0

    private let baseText: String
    private let dotSymbol: String
    private let maxDots: Int
    private let animationInterval: TimeInterval

    init(baseText: String = "",
         dotSymbol: String = ".",
         maxDots: Int = 3,
         animationInterval: TimeInterval = 0.4,
         font: UIFont = UIFont.systemFont(ofSize: 17),
         textColor: UIColor = .label) {

        self.baseText = baseText
        self.dotSymbol = dotSymbol
        self.maxDots = maxDots
        self.animationInterval = animationInterval

        super.init(frame: .zero)

        setupLabels(font: font, textColor: textColor)
        setupAccessibility()

        let maxDotsWidth = calculateMaxDotsWidth(font: font)
        setupLayout(dotWidth: maxDotsWidth)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupLabels(font: UIFont, textColor: UIColor) {
        textLabel.text = baseText
        textLabel.font = font
        textLabel.textColor = textColor
        textLabel.translatesAutoresizingMaskIntoConstraints = false

        animatedDotsLabel.text = ""
        animatedDotsLabel.font = font
        animatedDotsLabel.textColor = textColor
        animatedDotsLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(textLabel)
        addSubview(animatedDotsLabel)
    }

    private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityLabel = baseText
    }

    private func setupLayout(dotWidth: CGFloat) {
        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -dotWidth / 2),
            textLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            animatedDotsLabel.leadingAnchor.constraint(equalTo: textLabel.trailingAnchor, constant: 2),
            animatedDotsLabel.centerYAnchor.constraint(equalTo: textLabel.centerYAnchor)
        ])
    }

    private func calculateMaxDotsWidth(font: UIFont) -> CGFloat {
        let dotsString = String(repeating: dotSymbol, count: maxDots)
        return (dotsString as NSString).size(withAttributes: [.font: font]).width
    }

    // MARK: - Animation control

    func startAnimating() {
        stopAnimating()

        animationCancellable = Timer
            .publish(every: animationInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateDots()
            }
    }

    func stopAnimating() {
        animationCancellable?.cancel()
        animationCancellable = nil
        currentDotCount = 0
        animatedDotsLabel.text = ""
    }

    private func updateDots() {
        currentDotCount = (currentDotCount + 1) % (maxDots + 1)
        let dots = String(repeating: dotSymbol, count: currentDotCount)
        animatedDotsLabel.text = dots
        accessibilityLabel = baseText + dots
    }

    deinit {
        stopAnimating()
    }
}
