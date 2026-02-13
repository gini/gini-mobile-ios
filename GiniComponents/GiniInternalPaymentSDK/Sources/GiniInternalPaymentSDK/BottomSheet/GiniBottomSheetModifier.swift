//
//  GiniBottomSheetModifier.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI

struct GiniBottomSheetModifier: ViewModifier {
    
    private let contentHeight: CGFloat
    private let collapsedHeight: CGFloat
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    private var isLandscape: Bool {
            verticalSizeClass == .compact
        }
    
    init(contentHeight: CGFloat, collapsedHeight: CGFloat) {
        self.contentHeight = max(contentHeight, Constants.minimumHeight)
        self.collapsedHeight = collapsedHeight
    }
    
    func body(content: Content) -> some View {
        if #available(iOS 16.4, *) {
            content
                .presentationDetents(detentsForOrientation())
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled(true)
                .presentationBackgroundInteraction(.enabled(upThrough: .height(contentHeight)))
                .presentationCompactAdaptation(.sheet)
                .presentationContentInteraction(.resizes)
        } else {
            content
                .presentationDetents(detentsForOrientation())
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled(true)
        }
    }
    
    private func detentsForOrientation() -> Set<PresentationDetent> {
            if isLandscape {
                return [
                    .height(collapsedHeight),
                    .height(contentHeight)
                ]
            } else {
                return [.height(contentHeight)]
            }
        }
    
    private struct Constants {
        
        static let minimumHeight: CGFloat = 300
    }
}
