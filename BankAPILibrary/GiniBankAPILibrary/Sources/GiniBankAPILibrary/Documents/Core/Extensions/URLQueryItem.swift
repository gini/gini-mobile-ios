//
//  URLQueryItem.swift
//  GiniBankAPI
//
//  Created by Enrique del Pozo Gómez on 1/20/18.
//

import Foundation

extension URLQueryItem {
    init?(name: String, itemValue: Any?) {
        guard let value = itemValue else { return nil }
        self.init(name: name, value: String(describing: value))
    }
}
