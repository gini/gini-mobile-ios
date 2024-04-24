//
//  CustomResourceProvider.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

public protocol CustomResourceProvider {
    func customPrefferedColor(name: String) -> UIColor
}
