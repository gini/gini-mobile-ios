//
//  ErrorLog+GiniPayApiLib.swift
//  GiniCapture
//
//  Created by Nadya Karaban on 24.08.21.
//

import Foundation
import GiniBankAPILibrary

extension ErrorLog {
    
    var apiLibVersion: String {
        Bundle(for: GiniBankAPI.self).infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
}

