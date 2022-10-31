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

    override func awakeFromNib() {
        super.awakeFromNib()
        title.textColor = GiniColor(
            light: UIColor.GiniCapture.accent1,
            dark: UIColor.GiniCapture.accent1
        ).uiColor()
        fullText.textColor = GiniColor(
            light: UIColor.GiniCapture.dark6,
            dark: UIColor.GiniCapture.dark7
        ).uiColor()
    }

    func configureCell() {}

    override func prepareForReuse() {
        super.prepareForReuse()
        iconView.illustrationAdapter = nil
        iconView.icon = nil
        iconView.subviews.forEach({ $0.removeFromSuperview() })
        title.text = ""
        fullText.text = ""
    }
}
