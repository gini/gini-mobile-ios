//
//  NSRegularExpression.swift
//  
//
//  Copyright © 2023 Gini GmbH. All rights reserved.
//

import Foundation

extension NSRegularExpression {
    convenience init(_ pattern: String, options: NSRegularExpression.Options = []) {
        do {
            try self.init(pattern: pattern, options: options)
        } catch {
            preconditionFailure("Illegal regular expression pattern: \(pattern).")
        }
    }
}
