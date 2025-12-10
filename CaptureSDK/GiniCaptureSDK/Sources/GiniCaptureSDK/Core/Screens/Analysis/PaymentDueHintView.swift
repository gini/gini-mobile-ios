//
//  PaymentDueHintView.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

final class PaymentDueHintView: UIView {

    private lazy var infoIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image =  Images.hintIcon
        imageView.tintColor = .GiniCapture.warning2
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .GiniCapture.warning2
        label.font = GiniConfiguration.shared.textStyleFonts[.caption1]

        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
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
        container.layer.borderColor = UIColor.GiniCapture.warning2.cgColor
        container.layer.cornerRadius = Constants.cornerRadius
        container.backgroundColor = .GiniCapture.warning5
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

        tipContainerView.isAccessibilityElement = true
    }

    func configure(withDueDate dueDate: String) {

        /// part of text appear bold on UI  (e.g "Tip:")
        let prefixTip = Strings.hintPrefix

        /// hint text
        let tipText = Strings.hint

        /// formated string with prefix and due date
        let tipTextFormat = String(format: tipText, prefixTip, dueDate)

        let attributedText = NSMutableAttributedString(string: tipTextFormat)

        if let boldFont = GiniConfiguration.shared.textStyleFonts[.footnoteBold] {
            let prefixRange = (tipTextFormat as NSString).range(of: prefixTip)
            attributedText.addAttribute(.font, value: boldFont, range: prefixRange)
        }

        tipLabel.attributedText = attributedText

        tipContainerView.accessibilityLabel = tipTextFormat
        tipContainerView.accessibilityTraits = [.staticText]
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

private extension PaymentDueHintView {

    // MARK: - Constants
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

    // MARK: - Constants
    struct Constants {
        static let iconSize: CGFloat = 18
        static let iconTextSpacing: CGFloat = 8
        static let cornerRadius: CGFloat = 8
        static let contentPadding: CGFloat = 10
    }

    // MARK: - Images
    struct Images {
        static var hintIcon: UIImage? { UIImageNamedPreferred(named: "hintInfoIcon") }
    }
}

#if DEBUG
import SwiftUI

struct PaymentDueHintView_Preview: PreviewProvider {
    static var previews: some View {
        GiniViewControllerPreview {
            let viewController = UIViewController()
            let hintView = PaymentDueHintView()
            hintView.configure(withDueDate: "22-12-2023")

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
