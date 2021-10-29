//
//  URL.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 12/5/17.
//

import Foundation

extension URL {
    var queryParameters: [String: Any]? {
        return URLComponents(string: self.absoluteString)?
            .queryItems?
            .reduce(into: [String: Any]()) { (dict, queryItem) in
                dict[queryItem.name] = queryItem.value
        }
    }
}
