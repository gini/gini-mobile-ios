//
//  PoweredByGiniBadgeView.swift
//  GiniUtilites
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import UIKit

/**
 Fixed 90×23pt "Powered by Gini" badge backed by the `poweredByGiniBadge` PDF asset
 in `GiniUtilites`. A single accessibility element with the label `"Powered by Gini"`.
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
     On visibility change, mirrors `accessibilityElementsHidden` and posts a
     `layoutChanged` notification so VoiceOver drops any stale focus on the badge.
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
