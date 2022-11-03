//
//  OnboardingPageCell.swift
//  GiniCapture
//  Created by Nadya Karaban on 08.06.22.
//

import Foundation
import UIKit

class OnboardingPageCell: UICollectionViewCell {

    @IBOutlet weak var iconView: OnboardingImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var fullText: UILabel!

    @IBOutlet weak var topConstraint: NSLayoutConstraint!

    @IBOutlet weak var iconMargin: NSLayoutConstraint!

    private enum Constants: CGFloat {
        case topMargin = 85
        case topIPadMargin = 150
        case iconMargin = 30
        case maxIconMargin = 58
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    private func setupView() {
        title.textColor = GiniColor(
            light: UIColor.GiniCapture.dark1,
            dark: UIColor.GiniCapture.light1
        ).uiColor()
        fullText.textColor = GiniColor(
            light: UIColor.GiniCapture.dark6,
            dark: UIColor.GiniCapture.dark7
        ).uiColor()
    }

    private func calculateIconMargin() -> CGFloat {
        let largestHeightDiff: CGFloat = 265 // 932 PRO MAX - 667 SE
        let scaleFactor = (UIScreen.main.bounds.size.height - 667) / largestHeightDiff
        let diff = Constants.maxIconMargin.rawValue - Constants.iconMargin.rawValue
        return Constants.iconMargin.rawValue + diff * min(scaleFactor, 1)
    }

    override func layoutSubviews() {
        if UIDevice.current.isIpad {
            if UIApplication.shared.statusBarOrientation.isLandscape {
                topConstraint.constant = Constants.topMargin.rawValue
                iconMargin.constant = calculateIconMargin()
            } else {
                topConstraint.constant = Constants.topIPadMargin.rawValue
                iconMargin.constant = Constants.maxIconMargin.rawValue
            }
        } else {
            topConstraint.constant = Constants.topMargin.rawValue
            iconMargin.constant = calculateIconMargin()
        }
        super.layoutSubviews()
    }

    func configureCell() {

    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconView.illustrationAdapter = nil
        iconView.icon = nil
        iconView.subviews.forEach({ $0.removeFromSuperview() })
        title.text = ""
        fullText.text = ""
    }
}
