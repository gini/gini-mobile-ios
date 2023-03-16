//
// GiniNavigationBarButtons.swift
//  
//
//  Created by David Vizaknai on 15.03.2023.
//

import UIKit

public protocol GiniNavigationBarButton: AnyObject {
    func addAction(_ target: Any?, _ action: Selector)
    var barButton: UIBarButtonItem { get }
}

public final class GiniCancelBarButton: GiniNavigationBarButton {
    private lazy var configuration = GiniConfiguration.shared
    private let button = UIButton(type: UIButton.ButtonType.custom)

    public func addAction(_ target: Any?, _ action: Selector) {
        button.addTarget(target, action: action, for: .touchUpInside)
    }

    public var barButton: UIBarButtonItem {
        return UIBarButtonItem(customView: button)
    }

    public init() {
        button.titleLabel?.font = configuration.textStyleFonts[.bodyBold]
        let cancelString = NSLocalizedStringPreferredFormat("ginicapture.camera.popupCancel",
                                                                    comment: "Cancel")
        button.setTitleColor(.red, for: .normal)
//        button.setTitleColor(.GiniCapture.accent1, for: .normal)
        button.setTitle(cancelString, for: .normal)
    }
}
