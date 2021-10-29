//
//  Album.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 2/27/18.
//

import Foundation
import Photos

struct Album {
    var assets: [Asset]
    var title: String
    var identifier: String
    var count: Int {
        return assets.count
    }
}

extension Album: Equatable {
    static func == (lhs: Album, rhs: Album) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
