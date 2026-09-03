//
//  NSAttributedString.swift
//  GiniUtilites
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

extension NSMutableAttributedString {
    public func addLinkToRange(link: String, color: UIColor, range: NSRange, linkFont: UIFont, textToRemove: String?) {
        var attributes: [NSAttributedString.Key: Any] = [.font: linkFont, .foregroundColor: color]
        if range.length > 0, let url = URL(string: link) {
            attributes[.link] = url
            self.addAttributes(attributes, range: range)
            if let textToRemove {
                self.mutableString.replaceOccurrences(of: textToRemove,
                                                      with: "",
                                                      options: .caseInsensitive,
                                                      range: range)
            }
        }
    }
}
