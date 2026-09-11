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

    /**
     Two-part VoiceOver hardening for `isHidden`:

     1. Mirror `isHidden` into `accessibilityElementsHidden` so the badge
        subtree is explicitly excluded from the a11y tree — UIKit's default
        is to exclude hidden views, but VoiceOver can read a cached label
        mid-swipe when the state flips underneath it.
     2. Post a `layoutChanged` notification so VoiceOver drops its stale
        focus cursor (which may still be pointing at the badge from a prior
        swipe) and re-scans the current a11y hierarchy. Without this,
        swiping after the badge hides can still announce "Powered by Gini"
        because VoiceOver's cursor position hasn't been invalidated.

     Both effects are gated on actual state change so cycling banners that
     re-assign `isHidden = true` repeatedly don't spam VoiceOver.
     */
    public override var isHidden: Bool {
        didSet {
            guard isHidden != oldValue else { return }
            accessibilityElementsHidden = isHidden
            UIAccessibility.post(notification: .layoutChanged, argument: nil)
        }
    }
}

private extension PoweredByGiniBadgeView {
    enum Constants {
        static let badgeSize = CGSize(width: 90, height: 23)
    }
}
