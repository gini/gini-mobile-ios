//
//  ButtonConfiguration.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import UIKit
import SwiftUI

/**
 A value-type configuration for styling a button — background, border,
 title, shadow, corner radius, and an optional blur effect. Lives in
 GiniUtilites so both UIKit button helpers (defined in GiniCaptureSDK)
 and SwiftUI views (via `View.configure(with:)` below) can read it
 without one SDK needing to import the other.
 */
public struct ButtonConfiguration {
    public let backgroundColor: UIColor
    public let borderColor: UIColor
    public let titleColor: UIColor
    public let shadowColor: UIColor
    public let cornerRadius: CGFloat
    public let borderWidth: CGFloat
    public let shadowRadius: CGFloat

    public let withBlurEffect: Bool

    /**
     Optional title font. When non-`nil`, callers (UIKit via
     `titleLabel.font`, SwiftUI via `View.configure(with:)`) apply it as the
     button's label font. When `nil`, the caller supplies the font itself —
     the CaptureSDK / BankSDK side historically does this via
     `textStyleFonts[.bodyBold]` outside the config.

     Use `ButtonConfiguration.defaultTitleFont` as the fallback when
     unwrapping from a call site that always expects a non-nil font.
     */
    public let titleFont: UIFont?

    /**
     Dynamic-Type-aware fallback font for call sites that need a concrete
     `UIFont` when `titleFont` is `nil`. Resolves to `.body` so the button
     label scales with Dynamic Type when no explicit font is configured.
     */
    public static var defaultTitleFont: UIFont {
        UIFont.preferredFont(forTextStyle: .body)
    }

    /// Button configuration initalizer
    /// - Parameters:
    ///   - backgroundColor: the button's background color
    ///   - borderColor: the button's border color
    ///   - titleColor: the button's title color
    ///   - shadowColor: the button's color of the shadow
    ///   - cornerRadius: the button's corner radius
    ///   - borderWidth: the button's border width
    ///   - shadowRadius: the button's shadow radius
    ///   - withBlurEffect: adds a blur effect on the button ignoring the background color and making it translucent
    ///   - titleFont: optional title font; see property doc
    public init(backgroundColor: UIColor,
                borderColor: UIColor,
                titleColor: UIColor,
                shadowColor: UIColor,
                cornerRadius: CGFloat,
                borderWidth: CGFloat,
                shadowRadius: CGFloat,
                withBlurEffect: Bool,
                titleFont: UIFont? = nil) {
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.titleColor = titleColor
        self.shadowColor = shadowColor
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.shadowRadius = shadowRadius
        self.withBlurEffect = withBlurEffect
        self.titleFont = titleFont
    }
}

public extension View {
    /**
     Applies the given `ButtonConfiguration` to a SwiftUI view — the SwiftUI
     mirror of the UIKit `configure(with:)` helpers in GiniCaptureSDK.

     Applies, in order: title color via `foregroundStyle`; a background
     `RoundedRectangle` of `configuration.cornerRadius` filled with
     `configuration.backgroundColor`, with `.ultraThinMaterial` layered on
     top when `configuration.withBlurEffect` is `true` (mirrors UIKit's
     `addBlurEffect(cornerRadius:)`); a border stroke of the same shape;
     and a shadow using `configuration.shadowColor` / `shadowRadius`.
     */
    func configure(with configuration: ButtonConfiguration) -> some View {
        let shape = RoundedRectangle(cornerRadius: configuration.cornerRadius)
        return self
            .font(configuration.titleFont.map { Font(giniFont: $0) })
            .foregroundStyle(Color(uiColor: configuration.titleColor))
            .background {
                if configuration.withBlurEffect {
                    // Mirror UIKit's `addBlurEffect(cornerRadius:)` which
                    // discards `backgroundColor` before inserting the blur.
                    // SwiftUI renders the button clean/transparent so the
                    // enclosing surface shows through, matching the Liquid
                    // Glass design direction for outlined buttons.
                    shape.fill(.clear)
                } else {
                    shape.fill(Color(uiColor: configuration.backgroundColor))
                }
            }
            .overlay(shape.stroke(Color(uiColor: configuration.borderColor),
                                  lineWidth: configuration.borderWidth))
            .shadow(color: Color(uiColor: configuration.shadowColor),
                    radius: configuration.shadowRadius)
    }
}
