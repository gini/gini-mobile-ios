//
//  GiniBottomSheetModifier.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI
import UIKit

struct GiniBottomSheetModifier: ViewModifier {
    
    private let contentHeight: CGFloat
    private let allowsDismiss: Bool
    private let accessibilityAction: (() -> Void)?
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityVoiceOverEnabled) private var isVoiceOverEnabled
    @Environment(\.giniLayout) private var giniLayout
    
    init(contentHeight: CGFloat,
         allowsDismiss: Bool = false,
         accessibilityAction: (() -> Void)?) {
        self.contentHeight = max(contentHeight, Constants.minimumHeight)
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
                .presentationCompactAdaptation(horizontal: .sheet, vertical: .fullScreenCover)
                .presentationContentInteraction(.scrolls)
        } else {
            // On iOS 16.0–16.3 `presentationBackgroundInteraction` is unavailable.
            // Without it the sheet dims the presenting view and blocks the navigation-bar
            // close and back buttons. The helper sets `largestUndimmedDetentIdentifier`
            // via UIKit to restore background interactivity.
            base
                .background(SheetBackgroundInteractionHelper())
        }
    }
    
    private func detentsForOrientation() -> Set<PresentationDetent> {
        if giniLayout.isLandscape {
            return [.large]
        } else {
            // Only one detent in portrait: the sheet stays at its content height and the
            // inner ScrollView scrolls to show the focused field. A .large detent causes
            // iOS to auto-snap to full screen when the keyboard appears.
            return [.height(contentHeight)]
        }
    }
    
    private struct Constants {

        static let minimumHeight: CGFloat = 300
    }
}

/// Enables background interaction on iOS 16.0–16.3 by configuring the underlying
/// `UISheetPresentationController` to leave the background undimmed and interactive.
/// On iOS 16.4+, `presentationBackgroundInteraction` is used instead.
struct SheetBackgroundInteractionHelper: UIViewControllerRepresentable {
    func makeUIViewController(context _: Context) -> SheetBackgroundInteractionHelperController {
        SheetBackgroundInteractionHelperController()
    }

    func updateUIViewController(_ controller: SheetBackgroundInteractionHelperController,
                                context _: Context) {
        // No updates needed — configuration is applied once in viewWillAppear.
    }
}

final class SheetBackgroundInteractionHelperController: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        parent?.sheetPresentationController?.largestUndimmedDetentIdentifier = .large
    }
}
