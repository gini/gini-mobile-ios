//
//  Font+Extensions.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import SwiftUI

extension Font {
    
    /// Creates a SwiftUI `Font` from the given `UIFont`.
    ///
    /// Use this initializer when you need to reuse an existing UIKit font
    /// in SwiftUI views. It bridges the `UIFont`
    /// instance to its corresponding SwiftUI `Font` representation.
    ///
    /// - Parameter uiFont: The UIKit font to convert to a SwiftUI `Font`.
    init(uiFont: UIFont) {
        self = Font(uiFont as CTFont)
    }
}
