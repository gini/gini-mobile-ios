//
//  String+Utils.swift
//  GiniHealth
//
//  Created by Nadya Karaban on 19.05.21.
//

import Foundation
public extension String {
    var numberValue: NSNumber? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.number(from: self)
    }
}
