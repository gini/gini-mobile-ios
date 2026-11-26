//
//  View+GiniBottomSheet.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI

public extension View {

    /**
     Presents `content` as a bottom sheet with a visible drag indicator. The
     detent adapts to the user's current `dynamicTypeSize` — `.medium` on
     non-accessibility sizes, `.large` on accessibility sizes.

     The caller owns `isPresented`. Programmatic dismissal is a plain
     `isPresented.wrappedValue = false`; user drag-down flips the binding
     through SwiftUI's sheet bridge.

     - Parameters:
       - isPresented: Two-way binding owned by the caller.
       - onDismiss: Called when the sheet is dismissed for any reason;
         matches SwiftUI's `.sheet(isPresented:onDismiss:content:)`
         semantics.
       - content: The sheet body.
     */
    func giniBottomSheet<Content: View>(isPresented: Binding<Bool>,
                                        onDismiss: (() -> Void)? = nil,
                                        @ViewBuilder content: @escaping () -> Content) -> some View {
        modifier(GiniBottomSheetModifier(isPresented: isPresented,
                                         onDismiss: onDismiss,
                                         sheetContent: content))
    }
}

private struct GiniBottomSheetModifier<SheetContent: View>: ViewModifier {

    @Binding var isPresented: Bool
    let onDismiss: (() -> Void)?
    let sheetContent: () -> SheetContent

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    func body(content: Content) -> some View {
        content.sheet(isPresented: $isPresented, onDismiss: onDismiss) {
            sheetContent()
                .presentationDetents([detent])
                .presentationDragIndicator(.visible)
        }
    }

    private var detent: PresentationDetent {
        dynamicTypeSize.isAccessibilitySize ? .large : .medium
    }
}
