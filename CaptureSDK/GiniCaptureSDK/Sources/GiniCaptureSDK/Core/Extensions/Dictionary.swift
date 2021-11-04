//
//  Dictionary.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 10/23/18.
//

import Foundation

public extension Optional where Wrapped == [NSAttributedString.Key: Any] {
    var dictionary: [String: Any]? {
        guard let self = self else { return nil }
        return Dictionary(uniqueKeysWithValues: self.map { (key: NSAttributedString.Key, value: Any) in
                (key.rawValue, value)
            }
        )
    }
}
