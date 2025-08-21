//
//  GiniPreviewContainer.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

#if DEBUG
import SwiftUI

struct GiniViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
    let viewControllerBuilder: () -> ViewController

    init(_ builder: @escaping () -> ViewController) {
        self.viewControllerBuilder = builder
    }

    func makeUIViewController(context: Context) -> ViewController {
        return viewControllerBuilder()
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        // Intentionally left empty – no dynamic updates needed for static preview
    }
}
#endif
