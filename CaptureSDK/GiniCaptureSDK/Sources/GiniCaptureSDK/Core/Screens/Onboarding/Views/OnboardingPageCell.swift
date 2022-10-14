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
