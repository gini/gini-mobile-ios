//
//  Bundle.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 10/30/17.
//

import Foundation

public extension Bundle {
    var appName: String {
        return self.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? ""
    }
}
