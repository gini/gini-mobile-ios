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
    override func awakeFromNib() {
        super.awakeFromNib()
        title.textColor = GiniColor(
            light: UIColor.GiniCapture.dark1,
            dark: UIColor.GiniCapture.light1
        ).uiColor()
        fullText.textColor = GiniColor(
            light: UIColor.GiniCapture.dark6,
            dark: UIColor.GiniCapture.dark7
        ).uiColor()
    }

    override func layoutSubviews() {
        if UIDevice.current.isIpad {
            if UIApplication.shared.statusBarOrientation.isLandscape {
                topConstraint.constant = 85
            } else {
                topConstraint.constant = 150
            }
        } else {
            topConstraint.constant = 85
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
