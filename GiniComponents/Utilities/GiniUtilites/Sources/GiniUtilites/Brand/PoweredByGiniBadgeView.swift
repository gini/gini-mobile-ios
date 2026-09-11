//
//  PoweredByGiniBadgeView.swift
//  GiniUtilites
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import UIKit

/**
 A self-contained "Powered by Gini" ingredient-brand badge.

 Wraps the `poweredByGiniBadge` PDF asset shipped inside `GiniUtilites` as a
 fixed-size, theme-agnostic view (white pill background with the pink `gini`
 wordmark). The badge is not localized and does not scale with Dynamic Type —
 it is a brand mark, not text.

 The view groups itself as a single accessibility element that VoiceOver
 announces as `"Powered by Gini"`; the inner image is intentionally excluded
 from focus.
 */
public final class PoweredByGiniBadgeView: UIView {

    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "poweredByGiniBadge",
                                                   in: .module,
                                                   with: nil))
        imageView.contentMode = .scaleAspectFit
        imageView.isAccessibilityElement = false
        return imageView
    }()

    public init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        isAccessibilityElement = true
        accessibilityLabel = "Powered by Gini"
        accessibilityTraits = .image
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override var intrinsicContentSize: CGSize {
        Constants.badgeSize
    }
}

private extension PoweredByGiniBadgeView {
    enum Constants {
        static let badgeSize = CGSize(width: 90, height: 23)
    }
}
