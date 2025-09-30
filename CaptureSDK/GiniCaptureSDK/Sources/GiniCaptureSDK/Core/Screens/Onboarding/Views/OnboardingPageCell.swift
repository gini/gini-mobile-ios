//
//  OnboardingPageCell.swift
//  GiniCapture
//  Created by Nadya Karaban on 08.06.22.
//

import UIKit

class OnboardingPageCell: UICollectionViewCell {

    @IBOutlet weak var iconView: OnboardingImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet private weak var iconBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var topConstraint: NSLayoutConstraint?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    private func setupView() {
        isAccessibilityElement = false
        iconView.isAccessibilityElement = true
        iconView.icon?.isAccessibilityElement = false
        // Tell VoiceOver that this is a static image that doesn't need analysis
        // .image marks it as an image element
        //  .staticText indicates it's static content (no dynamic analysis needed)
        iconView.accessibilityTraits = [.image, .staticText]

        titleLabel.textColor = GiniColor(light: UIColor.GiniCapture.dark1,
                                         dark: UIColor.GiniCapture.light1).uiColor()
        titleLabel.font = GiniConfiguration.shared.textStyleFonts[.title2Bold]
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.1
        titleLabel.isAccessibilityElement = true

        descriptionLabel.textColor = GiniColor(light: UIColor.GiniCapture.dark6,
                                               dark: UIColor.GiniCapture.light6).uiColor()
        descriptionLabel.font = GiniConfiguration.shared.textStyleFonts[.subheadline]
        descriptionLabel.isAccessibilityElement = true
        descriptionLabel.adjustsFontSizeToFitWidth = true
        descriptionLabel.minimumScaleFactor = 0.1
    }

    private func calculateIconMargin() -> CGFloat {
        let largestHeightDiff: CGFloat = 265 // 932 PRO MAX - 667 SE
        let scaleFactor = (UIScreen.main.bounds.size.height - 667) / largestHeightDiff
        let diff = Constants.maxIconPadding - Constants.iconPadding

        return Constants.iconPadding + diff * min(scaleFactor, 1)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        let didVerticalTraitsChange = traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass
        let didHorizontalTraitsChange = traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass
        let shouldUpdateConstraints =  didVerticalTraitsChange || didHorizontalTraitsChange

        if shouldUpdateConstraints {
            updateConstraintsForCurrentTraits()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconView.illustrationAdapter = nil
        iconView.icon = nil
        iconView.subviews.forEach({ $0.removeFromSuperview() })
        titleLabel.text = ""
        descriptionLabel.text = ""
    }

    func updateConstraintsForCurrentTraits() {
        if UIDevice.current.isIpad {
            if UIDevice.current.isLandscape {
                topConstraint?.constant = Constants.compactTopPadding
                iconBottomConstraint.constant = calculateIconMargin()
            } else {
                topConstraint?.constant = Constants.regularTopPadding
                iconBottomConstraint.constant = Constants.maxIconPadding
            }
        } else if UIDevice.current.isPortrait() {
            topConstraint?.constant = Constants.compactTopPadding
            iconBottomConstraint.constant = calculateIconMargin()
        }
    }
}

private extension OnboardingPageCell {
    enum Constants {
        static let compactTopPadding: CGFloat = 85
        static let regularTopPadding: CGFloat = 150
        static let iconPadding: CGFloat = 30
        static let maxIconPadding: CGFloat = 58
    }
}
