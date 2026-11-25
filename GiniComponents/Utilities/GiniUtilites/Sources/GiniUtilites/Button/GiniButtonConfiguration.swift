//
//  GiniButtonConfiguration.swift
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
public struct GiniButtonConfiguration {
    public let backgroundColor: UIColor
    public let borderColor: UIColor
    public let titleColor: UIColor
    public let shadowColor: UIColor
    public let cornerRadius: CGFloat
    public let borderWidth: CGFloat
    public let shadowRadius: CGFloat

    public let withBlurEffect: Bool

    /**
     Optional title font. UIKit buttons apply it via `titleLabel.font`,
     SwiftUI buttons via `GiniButtonStyle`. `nil` means the caller supplies
     the font separately; use `defaultTitleFont` when a concrete `UIFont`
     is required.
     */
    public let titleFont: UIFont?

    /**
     Fallback `UIFont` for call sites that need a non-nil font when
     `titleFont` is `nil`. Resolves to `.body` so the label scales with
     Dynamic Type.
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

/**
 Back-compat alias. Downstream SDKs re-export the shared button config
 under the historical `ButtonConfiguration` name, so the GiniUtilites
 symbol has to keep resolving under that name too — new call sites
 should prefer `GiniButtonConfiguration`.
 */
public typealias ButtonConfiguration = GiniButtonConfiguration

/**
 SwiftUI `ButtonStyle` that paints a Button using a `GiniButtonConfiguration`
 — the SwiftUI counterpart to GiniCaptureSDK's UIKit `configure(with:)`
 helpers. Scoped to Button (via `.buttonStyle(...)`) so it does not add a
 universal modifier to every SwiftUI `View`, mirroring the UIKit side
 which extends only the specific `GiniCaptureButton` / `BottomLabelButton`
 classes instead of `UIView`.

 Applies, in order: the configured `titleFont` (when non-`nil`) via
 `font`; `titleColor` via `foregroundStyle`; a background
 `RoundedRectangle` of `configuration.cornerRadius` that is either filled
 with `configuration.backgroundColor` or rendered transparent when
 `configuration.withBlurEffect` is `true` — mirroring UIKit's
 `addBlurEffect(cornerRadius:)` which also discards `backgroundColor` and
 lets the enclosing Liquid Glass surface show through; a border drawn
 with `strokeBorder` so the line sits inside the shape instead of
 straddling the edge; a shadow using `configuration.shadowColor` /
 `shadowRadius`; and finally an `opacity` dip while the button is
 pressed, matching the native button feedback UIKit provides via
 `UIControl.State.highlighted`.
 */
public struct GiniButtonStyle: ButtonStyle {
    public let configuration: GiniButtonConfiguration

    public init(_ configuration: GiniButtonConfiguration) {
        self.configuration = configuration
    }

    public func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: self.configuration.cornerRadius)
        return configuration.label
            .font(self.configuration.titleFont.map { Font(giniFont: $0) })
            .foregroundStyle(Color(uiColor: self.configuration.titleColor))
            .background {
                if self.configuration.withBlurEffect {
                    BlurAwareBackground(shape: shape)
                } else {
                    shape.fill(Color(uiColor: self.configuration.backgroundColor))
                }
            }
            .overlay(shape.strokeBorder(Color(uiColor: self.configuration.borderColor),
                                        lineWidth: self.configuration.borderWidth))
            .shadow(color: Color(uiColor: self.configuration.shadowColor),
                    radius: self.configuration.shadowRadius)
            .opacity(configuration.isPressed ? Self.pressedOpacity : 1)
    }

    private static let pressedOpacity: Double = 0.75
}

/**
 Blur-path background: fully clear in light mode so the Liquid Glass
 flat look matches Figma, `.ultraThinMaterial` in dark mode so the
 button stays visible against the dark sheet (mirrors UIKit's blur
 fallback).
 */
private struct BlurAwareBackground<Shape: SwiftUI.Shape>: View {
    @Environment(\.colorScheme) private var colorScheme
    let shape: Shape

    var body: some View {
        if colorScheme == .dark {
            shape.fill(.ultraThinMaterial)
        } else {
            shape.fill(.clear)
        }
    }
}
