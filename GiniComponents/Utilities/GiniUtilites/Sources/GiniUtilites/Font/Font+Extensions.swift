//
//  Font+Extensions.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI

/** SwiftUI `Font` extensions for bridging UIKit fonts into SwiftUI views. */
public extension Font {
    
    /**
     Creates a SwiftUI `Font` from the given `UIFont`.
     
     Use this initializer when you need to reuse an existing UIKit font
     in SwiftUI views. It bridges the `UIFont`
     instance to its corresponding SwiftUI `Font` representation.
     
     - Parameter giniFont: The UIKit font to convert to a SwiftUI `Font`.
     */
    init(giniFont: UIFont) {
        self = Font(giniFont as CTFont)
    }
}
