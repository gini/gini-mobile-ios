//
//  ButtonConfiguration.swift
//
//
//  Created by David Vizaknai on 30.11.2022.
//

import UIKit
import GiniUtilites

/**
 Backward-compatible re-export. `ButtonConfiguration` moved to GiniUtilites
 so SwiftUI consumers across every SDK can use it without importing
 GiniCaptureSDK. Integrators that already `import GiniCaptureSDK` keep
 seeing the type under its original name via this typealias.
 */
public typealias ButtonConfiguration = GiniUtilites.ButtonConfiguration

extension BottomLabelButton {
    func configure(with configuration: ButtonConfiguration) {
        self.backgroundColor = configuration.backgroundColor
        self.layer.borderColor = configuration.borderColor.cgColor
        self.layer.shadowColor = configuration.shadowColor.cgColor

        self.actionLabel.textColor = configuration.titleColor

        self.layer.cornerRadius = configuration.cornerRadius
        self.layer.borderWidth = configuration.borderWidth
        self.layer.shadowRadius = configuration.shadowRadius
    }
}

public class GiniCaptureButton: UIButton {
    var traitCollectionUpdated: () -> Void = {
        // This closure will remain empty; no implementation is needed.
    }
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        traitCollectionUpdated()
    }
}

public extension GiniCaptureButton {
    func configure(with configuration: ButtonConfiguration) {
        self.backgroundColor = configuration.backgroundColor
        self.layer.borderColor = configuration.borderColor.cgColor
        self.layer.shadowColor = configuration.shadowColor.cgColor
        traitCollectionUpdated = { [weak self] in
            self?.layer.borderColor = configuration.borderColor.cgColor
            self?.layer.shadowColor = configuration.shadowColor.cgColor
        }
        self.setTitleColor(configuration.titleColor, for: .normal)
        self.setTitleColor(configuration.titleColor, for: .highlighted)
        self.setTitleColor(configuration.titleColor, for: .selected)

        self.layer.cornerRadius = configuration.cornerRadius
        self.layer.borderWidth = configuration.borderWidth
        self.layer.shadowRadius = configuration.shadowRadius

        // When switching from one ButtonConfiguration with a blur effect to another ButtonConfiguration with a blur effect,
        // the previous blur effect should be removed.
        self.removeBlurEffect()
        if configuration.withBlurEffect {
            self.addBlurEffect(cornerRadius: configuration.cornerRadius)
        }
    }
}
