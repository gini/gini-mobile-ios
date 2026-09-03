//
//  GiniHeightPreferenceKey.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI

public struct GiniHeightPreferenceKey: PreferenceKey {
    
    public static var defaultValue: CGFloat = .zero
    
    public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
