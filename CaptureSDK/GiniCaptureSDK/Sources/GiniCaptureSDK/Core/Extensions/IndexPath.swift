//
//  IndexPath.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 2/2/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import Foundation

extension IndexPath {
    static func indexesBetween(_ first: IndexPath, and second: IndexPath, inSection section: Int = 0) -> [IndexPath] {
        var indexes: [IndexPath] = []
        let maxInt: Int = Swift.max(first.row, second.row)
        let minInt: Int = Swift.min(first.row, second.row)
        
        if maxInt > minInt {
            for index in (minInt + 1) ..< maxInt {
                indexes.append(IndexPath(row: index, section: section))
            }
        }
        
        return indexes
    }
}
