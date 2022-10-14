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
        iconView.icon = nil
        iconView.illustrationAdapter = nil
        title.text = ""
        fullText.text = ""
    }
}
