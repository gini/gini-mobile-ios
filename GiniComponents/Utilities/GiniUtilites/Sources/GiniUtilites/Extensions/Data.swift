//
//  Data.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

extension Data {
    public var toImage: UIImage {
        return UIImage(data: self) ?? UIImage()
    }
}
