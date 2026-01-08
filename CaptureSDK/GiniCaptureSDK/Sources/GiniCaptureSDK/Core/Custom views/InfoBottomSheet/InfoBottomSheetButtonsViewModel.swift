//
//  InfoBottomSheetButtonsViewModel.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

// ViewModel for managing primary and secondary buttons in an info bottom sheet
final class InfoBottomSheetButtonsViewModel {
    struct Button {
        let title: String
        let action: () -> Void
    }

    private let primaryButton: Button?
    private let secondaryButton: Button?

    init(_ primary: Button? = nil, _ secondary: Button? = nil) {
        primaryButton = primary
        secondaryButton = secondary
    }

    var primaryTitle: String? {
        primaryButton?.title
    }

    var secondaryTitle: String? {
        secondaryButton?.title
    }

    @objc func didPressPrimary() {
        primaryButton?.action()
    }

    @objc func didPressSecondary() {
        secondaryButton?.action()
    }
}
