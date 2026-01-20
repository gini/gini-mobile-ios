//
//  GiniBottomSheetModifier.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI

struct GiniBottomSheetModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        if #available(iOS 16.4, *) {
            content
                .presentationDetents([.fraction(0.45)])
                .presentationDragIndicator(.automatic)
                .interactiveDismissDisabled(true)
                .presentationBackgroundInteraction(.enabled)
        } else {
            if #available(iOS 15.0, *) {
                content
                    .interactiveDismissDisabled(true)
            } else {
                content
            }
        }
    }
}
