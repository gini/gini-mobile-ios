//
//  PoweredByGiniBadgeView.swift
//  GiniUtilites
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import UIKit

/**
 A fixed 90×23pt "Powered by Gini" ingredient-brand badge backed by the
 `poweredByGiniBadge` PDF asset shipped in `GiniUtilites`. The view exposes
 itself as a single accessibility element labelled `"Powered by Gini"` with
 the `.image` trait.
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

    /**
     Creates a new `PoweredByGiniBadgeView` sized to its 90×23pt intrinsic content
     size, with the badge image already installed and accessibility configured.
     */
    public init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        imageView.giniMakeConstraints { $0.edges.equalToSuperview() }

        isAccessibilityElement = true
        accessibilityLabel = Strings.accessibilityLabel
        accessibilityTraits = .image
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override var intrinsicContentSize: CGSize {
        Constants.badgeSize
    }

    /**
     On visibility change, mirrors `accessibilityElementsHidden`. When the badge
     transitions to hidden, posts a `layoutChanged` notification so VoiceOver drops
     any stale focus that was on the badge. No notification is posted on show, to
     avoid moving VoiceOver focus while the screen is appearing or being restored.
     */
    public override var isHidden: Bool {
        didSet {
            guard isHidden != oldValue else { return }
            accessibilityElementsHidden = isHidden
            guard isHidden else { return }
            UIAccessibility.post(notification: .layoutChanged, argument: nil)
        }
    }
}

private extension PoweredByGiniBadgeView {
    enum Constants {
        static let badgeSize = CGSize(width: 90, height: 23)
    }

    enum Strings {
        /// Brand mark — intentionally not localized (PP-2570 spec R11).
        static let accessibilityLabel = "Powered by Gini"
    }
}
