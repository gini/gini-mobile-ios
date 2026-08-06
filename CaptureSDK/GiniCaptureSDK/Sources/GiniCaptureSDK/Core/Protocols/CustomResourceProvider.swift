//
//  CustomResourceProvider.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

/**
 *  Custom resource provider protocol which allows clients to override the default Gini resources.
 *  The change will affect all screens.
 */
public protocol CustomResourceProvider {
    /**
     *  Returns a custom preferred color for a given resource name.
     *
     *  - Parameter name: The name of the resource.
     *  - Returns: The custom preferred UIColor.
     */
    func customPrefferedColor(name: String) -> UIColor

    /**
     *  Returns a custom color for a single UI element identified by its key,
     *  allowing per-screen, per-element customization independent of the color palette.
     *
     *  The list of supported element keys is part of the SDK's customization documentation.
     *  Returning `nil` keeps the SDK's default color for that element, so implementing
     *  this method for a subset of keys never affects any other element or screen.
     *
     *  - Parameter key: The element key, e.g. `skonto.amountToPay.title`.
     *  - Returns: A `GiniColor` (light and dark mode pair) to override the element's
     *             color, or `nil` to use the SDK default.
     */
    func customElementColor(for key: String) -> GiniColor?
}

public extension CustomResourceProvider {
    /// Default implementation so existing conformances keep compiling and behaving unchanged.
    func customElementColor(for key: String) -> GiniColor? {
        return nil
    }
}
