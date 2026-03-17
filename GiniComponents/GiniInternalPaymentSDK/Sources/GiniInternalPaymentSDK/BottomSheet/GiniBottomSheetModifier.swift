//
//  GiniBottomSheetModifier.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI

struct GiniBottomSheetModifier: ViewModifier {
    
    private let contentHeight: CGFloat
    private let collapsedHeight: CGFloat
    private let allowsDismiss: Bool
    private let accessibilityAction: (() -> Void)?
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityVoiceOverEnabled) private var isVoiceOverEnabled
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    init(contentHeight: CGFloat,
         collapsedHeight: CGFloat,
         allowsDismiss: Bool = false,
         accessibilityAction: (() -> Void)?) {
        self.contentHeight = max(contentHeight, Constants.minimumHeight)
        self.collapsedHeight = collapsedHeight
        self.allowsDismiss = allowsDismiss
        self.accessibilityAction = accessibilityAction
    }
    
    func body(content: Content) -> some View {
        let base = content
            .presentationDetents(detentsForOrientation())
            .presentationDragIndicator(reduceMotion ? .hidden : .visible)
            .interactiveDismissDisabled(!allowsDismiss && !isVoiceOverEnabled)
            .accessibilityAction(.escape) {
                accessibilityAction?()
            }
        
        if #available(iOS 16.4, *) {
            let presentationBackgroundInteractionForVoiceOver = isVoiceOverEnabled ? .disabled : PresentationBackgroundInteraction.enabled(upThrough: .height(contentHeight))
            
            base
                .presentationBackgroundInteraction(allowsDismiss ? .automatic : presentationBackgroundInteractionForVoiceOver)
                .presentationCompactAdaptation(.sheet)
                .presentationContentInteraction(.resizes)
        } else {
            base
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
