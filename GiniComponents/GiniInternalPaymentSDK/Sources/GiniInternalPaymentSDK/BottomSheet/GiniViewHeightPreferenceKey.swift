//
//  GiniViewHeightPreferenceKey.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI

struct GiniViewHeightPreferenceKey: PreferenceKey {
    
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
