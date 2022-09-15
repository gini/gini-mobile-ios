//
//  OnboardingPageCell.swift
//  GiniCapture
//  Created by Nadya Karaban on 08.06.22.
//

import Foundation
import UIKit

class OnboardingPageCell: UICollectionViewCell {
    static var identifier: String = "onboardingPageCellIdentifier"

    @IBOutlet weak var iconView: OnboardingImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var fullText: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func configureCell() {}
}
