//
//  NoResultHeader.swift
//  GiniCapture
//
//  Created by Krzysztof Kryniecki on 22/08/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import Foundation
import UIKit

class IconHeader: UIView {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var headerStack: UIStackView!

    fileprivate func configureAccessibility() {
        isAccessibilityElement = false
        accessibilityElements = [iconImageView as Any, headerLabel as Any]
        headerLabel.adjustsFontForContentSizeCategory = true
        headerLabel.isAccessibilityElement = true
        iconImageView.isAccessibilityElement = true
        iconImageView.accessibilityTraits = .image
    }

    fileprivate func configureView() {
        if UIDevice.current.isIpad {
            headerLabel.textAlignment = .center
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        configureAccessibility()
        configureView()
    }
}
