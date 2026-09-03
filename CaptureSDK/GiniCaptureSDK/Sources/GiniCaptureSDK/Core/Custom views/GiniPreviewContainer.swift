//
//  GiniPreviewContainer.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

/// SwiftUI wrapper for previewing UIViewController instances in Xcode Canvas

#if DEBUG
import SwiftUI

struct GiniViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
    /// Closure that builds the view controller instance
    let viewControllerBuilder: () -> ViewController

    /// Initialize with a view controller builder closure
    init(_ builder: @escaping () -> ViewController) {
        self.viewControllerBuilder = builder
    }

    /// Creates the UIViewController instance for SwiftUI preview
    func makeUIViewController(context: Context) -> ViewController {
        return viewControllerBuilder()
    }

    /// Updates the view controller - intentionally empty for static previews
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        // Intentionally left empty – no dynamic updates needed for static preview
    }
}
#endif
