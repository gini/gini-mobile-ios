//
//  DismissMessageView.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

final class DismissMessageView: UIView {

    var onTap: (() -> Void)?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        label.text = Strings.dismissTitle
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping

        label.textColor = GiniColor(light: .GiniCapture.dark6,
                                    dark: .GiniCapture.light1).uiColor()
        label.font = GiniConfiguration.shared.textStyleFonts[.bodyBold]

        label.adjustsFontForContentSizeCategory = true

        return label
    }()

    private lazy var progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.progressTintColor = .GiniCapture.accent1
        progress.trackTintColor =  GiniColor(light: .GiniCapture.light4, dark: .GiniCapture.light3).uiColor()
        progress.progress = 0.0
        progress.translatesAutoresizingMaskIntoConstraints = false
        return progress
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
        setProgress()
        setupGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupView() {
        backgroundColor = .clear
        layer.borderWidth = Constants.borderWidth
        layer.borderColor = GiniColor(light: .GiniCapture.light4, dark: .GiniCapture.light1).uiColor().cgColor
        layer.cornerRadius = Constants.cornerRadius
        layer.masksToBounds = true

        addSubview(titleLabel)
        addSubview(progressView)

        isAccessibilityElement = true
        accessibilityTraits = [.button]
        accessibilityLabel = titleLabel.text
    }

    private func setupGesture() {
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }

    // MARK: - Actions
    @objc private func handleTap() {
        onTap?()
    }

    private func setupConstraints() {
        titleLabel.giniMakeConstraints {
            $0.top.equalToSuperview().constant(Constants.verticalSpacing)
            $0.leading.equalToSuperview().constant(Constants.horizontalPadding)
            $0.trailing.equalToSuperview().constant(-Constants.horizontalPadding)
        }

        progressView.giniMakeConstraints {
            $0.top.equalTo(titleLabel.bottom).constant(Constants.verticalSpacing/2)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(Constants.progressHeight)
        }
    }

    private func setProgress(duration: TimeInterval = 3, animated: Bool = true) {

        let interval = 0.01
        var elapsed: TimeInterval = 0

        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            elapsed += interval
            self.progressView.progress = Float(elapsed / duration)
            if elapsed >= duration {
                timer.invalidate()
            }
        }
    }
}

// MARK: - Strings
private extension DismissMessageView {
    enum Strings {
        static let dismissTitle = NSLocalizedStringPreferredFormat(
            "ginicapture.dismiss.message.title",
            comment: "Title for the dismiss message view"
        )
    }

    // MARK: - Constants
    enum Constants {
        static let cornerRadius: CGFloat = 14
        static let borderWidth: CGFloat = 1
        static let progressHeight: CGFloat = 6
        static let verticalSpacing: CGFloat = 14
        static let horizontalPadding: CGFloat = 16
    }
}

#if DEBUG
import SwiftUI

struct DismissMessageView_Preview: PreviewProvider {
    static var previews: some View {
        GiniViewControllerPreview {
            let viewController = UIViewController()
            viewController.view.backgroundColor = GiniColor(light: .GiniCapture.light1,
                                                            dark: .GiniCapture.dark1).uiColor().withAlphaComponent(0.6)

            let dismissMessageView = DismissMessageView()
            viewController.view.addSubview(dismissMessageView)

            dismissMessageView.giniMakeConstraints {
                $0.center.equalToSuperview()
                $0.height.equalTo(60)
                $0.horizontal.equalToSuperview().constant(20)
            }
            return viewController
        }
        .edgesIgnoringSafeArea(.all)
    }
}
#endif
