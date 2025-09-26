//
//  GiniView.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import SwiftUI

struct GiniView: UIViewControllerRepresentable {

    private let viewModel: GiniBankSDKModel

    init(viewModel: GiniBankSDKModel) {
        self.viewModel = viewModel
    }

    func makeUIViewController(context: Context) -> UIViewController {
        return context.coordinator.viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No updates needed - the UIViewController maintains its own state
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, viewModel: viewModel)
    }

    // MARK: Internal Coordinator Class

    class Coordinator: NSObject {

        private let parent: GiniView
        private let viewModel: GiniBankSDKModel

        private var giniViewController: UIViewController?

        lazy var viewController: UIViewController = {
            return viewModel.createGiniUIViewController()
        }()

        init(_ view: GiniView, viewModel: GiniBankSDKModel) {
            self.parent = view
            self.viewModel = viewModel
        }
    }
}
