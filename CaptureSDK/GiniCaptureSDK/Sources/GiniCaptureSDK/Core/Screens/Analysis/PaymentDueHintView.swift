//
//  PaymentDueHintView.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

final class PaymentDueHintView: UIView {

    // MARK: - Subviews
    private lazy var infoIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image =  UIImageNamedPreferred(named: "hintInfoIcon")
        imageView.tintColor = GiniColor(light: .GiniCapture.warning2,
                                        dark: .GiniCapture.warning4).uiColor()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = GiniColor(light: .GiniCapture.warning2,
                                    dark: .GiniCapture.warning4).uiColor()
        label.font = GiniConfiguration.shared.textStyleFonts[.caption1]

        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false

        let fullText = Strings.hint
        let attributedText = NSMutableAttributedString(string: fullText)

        if let boldFont = GiniConfiguration.shared.textStyleFonts[.caption1SemiBold] {
            let prefixRange = (fullText as NSString).range(of: Strings.hintPrefix)
            attributedText.addAttribute(.font,
                                        value: boldFont,
                                        range: prefixRange)
        }
        label.attributedText = attributedText
        return label
    }()

    private lazy var tipHorizontalStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [infoIcon, tipLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = Constants.iconTextSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var tipContainerView: UIView = {
        let container = UIView()
        container.layer.borderWidth = 1
        container.layer.borderColor = GiniColor(light: .GiniCapture.warning2,
                                                dark: .GiniCapture.warning4).uiColor().cgColor
        container.layer.cornerRadius = Constants.cornerRadius
        container.backgroundColor = GiniColor(light: .GiniCapture.warning5,
                                              dark: .GiniCapture.warning1).uiColor()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(tipHorizontalStack)
        return container
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupView() {
        backgroundColor = .clear
        addSubview(tipContainerView)
    }

    private func setupConstraints() {

        // Container view
        tipContainerView.giniMakeConstraints {
            $0.top.equalTo(top)
            $0.leading.equalTo(leading)
            $0.trailing.equalTo(trailing)
            $0.bottom.equalTo(bottom)
        }

        // Stack inside container
        tipHorizontalStack.giniMakeConstraints {
            $0.top.equalTo(tipContainerView.top).constant(Constants.contentPadding)
            $0.leading.equalTo(tipContainerView.leading).constant(Constants.contentPadding)
            $0.trailing.equalTo(tipContainerView.trailing).constant(-Constants.contentPadding)
            $0.bottom.equalTo(tipContainerView.bottom).constant(-Constants.contentPadding)
        }

        // Info icon fixed size
        infoIcon.giniMakeConstraints {
            $0.width.equalTo(Constants.iconSize)
            $0.height.equalTo(Constants.iconSize)
        }
    }
}

extension PaymentDueHintView {
    struct Strings {
        static let suggestionKey = "ginicapture.payment.due.hint.suggestion"
        static let suggestionComment = "Hint suggestions"
        static let hint = NSLocalizedStringPreferredFormat(suggestionKey,
                                                           comment: suggestionComment)

        static let prefixKey = "ginicapture.payment.due.hint.prefix"
        static let prefixComment = "Hint Prefix"
        static let hintPrefix = NSLocalizedStringPreferredFormat(prefixKey,
                                                                 comment: prefixComment)
    }
}

// MARK: - Constants

private extension PaymentDueHintView {
    struct Constants {
        static let iconSize: CGFloat = 18
        static let iconTextSpacing: CGFloat = 8
        static let cornerRadius: CGFloat = 8
        static let contentPadding: CGFloat = 10
    }
}

#if DEBUG
import SwiftUI

struct PaymentDueHintView_Preview: PreviewProvider {
    static var previews: some View {
        GiniViewControllerPreview {
            let viewController = UIViewController()
            let hintView = PaymentDueHintView()

            viewController.view.backgroundColor = GiniColor(light: .GiniCapture.light2,
                                                            dark: .GiniCapture.dark2).uiColor()
            viewController.view.addSubview(hintView)

            hintView.giniMakeConstraints {
                $0.center.equalToSuperview()
                $0.horizontal.equalToSuperview().constant(20)
            }

            return viewController
        }
        .edgesIgnoringSafeArea(.all)
    }
}
#endif

/*
 public func waitForContinueOrTimeout(timeout: TimeInterval = 4.0) async {
 await withCheckedContinuation { continuation in
 var didContinue = false

 // Store the continuation to call once
 let callOnce: () -> Void = {
 guard !didContinue else { return }
 didContinue = true
 continuation.resume()
 }

 // Button tap
 self.continueButtonTapped = {
 callOnce()
 }

 // Timeout
 DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
 callOnce()
 }
 }
 }

 */
