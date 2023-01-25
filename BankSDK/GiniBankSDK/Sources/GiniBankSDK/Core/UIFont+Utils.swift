//
//  UIFont+Utils.swift
//  
//
//  Created by Nadya Karaban on 08.08.22.
//

import UIKit
extension UIFont.TextStyle: CaseIterable {
    public static var allCases: [UIFont.TextStyle] {
        return [
          .largeTitle,
          .title1,
          .title2,
          .title3,
          .caption1,
          .caption2,
          .headline,
          .subheadline,
          .body,
          .bodyBold,
          .callout,
          .calloutBold,
          .footnote,
          .footnoteBold,
          .title2Bold
        ]
    }
}
