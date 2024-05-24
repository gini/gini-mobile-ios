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
}
