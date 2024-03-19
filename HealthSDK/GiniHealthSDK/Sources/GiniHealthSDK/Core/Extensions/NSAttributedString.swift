//
//  NSAttributedString.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

extension NSMutableAttributedString {
    func addLinkToRange(link: String, range: NSRange, linkFont: UIFont, textToRemove: String?) {
        var attributes: [NSAttributedString.Key: Any] = [
            .font: linkFont
        ]
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
