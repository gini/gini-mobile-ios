//
//  Asset.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 3/5/18.
//

import Foundation
import Photos

struct Asset {
    var identifier: String
    var value: PHAsset
    
    init(value: PHAsset) {
        self.value = value
        self.identifier = value.localIdentifier
    }
}

extension Asset: Equatable {
    static func == (lhs: Asset, rhs: Asset) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
