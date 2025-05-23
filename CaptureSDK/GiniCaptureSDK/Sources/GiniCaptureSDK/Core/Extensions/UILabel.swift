//
//  UILabel.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 10/30/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit

extension UILabel {
    func textHeight(forWidth width: CGFloat) -> CGFloat {
        guard let text = self.text, let font = font else {
            return 0
        }

        let maxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        return text.boundingRect(with: maxSize,
                                 options: .usesLineFragmentOrigin,
                                 attributes: [NSAttributedString.Key.font: font],
                                 context: nil).size.height
    }

    /**
     Enables font scaling with a minimum size of 10pt.

     - Adjusts the font size to fit the label’s width.
     - Sets the minimum scale factor to `10 / font.pointSize`.
     For example:
     - If font size is 20pt → minimumScaleFactor = 0.5
     - If font size is 15pt → minimumScaleFactor ≈ 0.67
     - Ensures the font never shrinks below 10pt.
     - Supports Dynamic Type for accessibility.
     */
    public func enableScaling(minimumScaleFactor: CGFloat = 10) {
        adjustsFontSizeToFitWidth = true
        self.minimumScaleFactor = minimumScaleFactor / font.pointSize
        adjustsFontForContentSizeCategory = true
    }
}
