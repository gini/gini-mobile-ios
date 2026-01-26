//
//  GiniBottomSheetModifier.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI

struct GiniBottomSheetModifier: ViewModifier {
    
    private let contentHeight: CGFloat
    
    init(contentHeight: CGFloat) {
        self.contentHeight = max(contentHeight, Constants.minimumHeight)
    }
    
    func body(content: Content) -> some View {
        if #available(iOS 16.4, *) {
            content
                .presentationDetents([.height(contentHeight)])
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled(true)
                .presentationBackgroundInteraction(.enabled(upThrough: .height(contentHeight)))
                .presentationCompactAdaptation(.sheet)
        } else if #available(iOS 16.0, *) {
            content
                .presentationDetents([.height(contentHeight)])
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled(true)
        } else if #available(iOS 15.0, *) {
            content
                .interactiveDismissDisabled(true)
        } else {
            content
        }
    }
    
    private struct Constants {
        
        static let minimumHeight: CGFloat = 300
    }
}
