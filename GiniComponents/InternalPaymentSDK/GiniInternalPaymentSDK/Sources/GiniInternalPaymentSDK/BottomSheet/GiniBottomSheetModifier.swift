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
            // close and back buttons. Mirror the iOS 16.4+ logic: enable background
            // interaction unless VoiceOver is active and the sheet is non-dismissible.
            base
                .background(SheetBackgroundInteractionHelper(isEnabled: allowsDismiss || !isVoiceOverEnabled))
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

/**
 Enables background interaction on iOS 16.0–16.3 by configuring the underlying
 `UISheetPresentationController` to leave the background undimmed and interactive.
 On iOS 16.4+, `presentationBackgroundInteraction` is used instead.

 Set `isEnabled` to `false` to suppress background interaction (e.g. when VoiceOver
 is active and the sheet is non-dismissible), mirroring the `.disabled` value used
 on iOS 16.4+.
 */
struct SheetBackgroundInteractionHelper: UIViewRepresentable {
    let isEnabled: Bool

    func makeUIView(context _: Context) -> SheetBackgroundInteractionView {
        SheetBackgroundInteractionView(isEnabled: isEnabled)
    }

    func updateUIView(_: SheetBackgroundInteractionView,
                      context _: Context) {
        // No updates needed — configuration is applied once in didMoveToWindow.
    }
}

/**
 A zero-size, invisible UIView that walks the responder chain on `didMoveToWindow`
 to find the enclosing `UISheetPresentationController` and set
 `largestUndimmedDetentIdentifier = .large`, keeping the background fully
 interactive behind the sheet on iOS 16.0–16.3.

 Using `UIViewRepresentable` (rather than `UIViewControllerRepresentable`) is
 intentional: SwiftUI adds the UIView directly into the view hierarchy via
 `addSubview`, so the responder chain is always populated when `didMoveToWindow`
 fires. A `UIViewControllerRepresentable`'s managed VC does not go through the
 standard `addChild` path, leaving `parent` nil at the point where configuration
 would need to happen.
 */
final class SheetBackgroundInteractionView: UIView {
    private let isEnabled: Bool

    init(isEnabled: Bool) {
        self.isEnabled = isEnabled
        super.init(frame: .zero)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard isEnabled, window != nil else { return }
        var responder: UIResponder? = self
        while let current = responder {
            if let vc = current as? UIViewController,
               let sheet = vc.sheetPresentationController {
                sheet.largestUndimmedDetentIdentifier = .large
                return
            }
            responder = current.next
        }
    }
}
