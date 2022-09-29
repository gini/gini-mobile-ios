//
//  OpaqueViewFactory.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 6/13/18.
//

import UIKit

public enum OpaqueViewStyle {
    case blurred(style: UIBlurEffect.Style)
    case dimmed
}

struct OpaqueViewFactory {

    static func create(with style: OpaqueViewStyle) -> UIView {
        switch style {
        case .blurred(let blurStyle):
            return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
        case .dimmed:
            let view = UIView()
            view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            return view
        }
    }
}
