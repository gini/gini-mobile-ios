//
//  InfoBottomSheetButtonsViewModel.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

final class InfoBottomSheetButtonsViewModel {
    struct Button {
        let title: String
        let action: () -> Void
    }

    private let primaryButton: Button?
    private let secondaryButton: Button?

    init(_ primary: Button? = nil, _ secondary: Button? = nil) {
        self.primaryButton = primary
        self.secondaryButton = secondary
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
