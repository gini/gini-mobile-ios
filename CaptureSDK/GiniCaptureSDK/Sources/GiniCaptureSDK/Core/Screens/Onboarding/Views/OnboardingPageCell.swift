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
        if UIDevice.current.isIpad {
            iconMargin.constant = 66
        } else {
            let largestHeightDiff: CGFloat = 265 
            let diff = (UIScreen.main.bounds.size.height - 667) / largestHeightDiff
            iconMargin.constant = 40 + 26 * min(diff, 1) // 66 for iPhone Pro max,
        }
    }

    override func layoutSubviews() {
        if UIDevice.current.isIpad {
            if UIApplication.shared.statusBarOrientation.isLandscape {
                topConstraint.constant = Constants.topMargin.rawValue
            } else {
                topConstraint.constant = Constants.topIPadMargin.rawValue
            }
        } else {
            topConstraint.constant = Constants.topMargin.rawValue
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
