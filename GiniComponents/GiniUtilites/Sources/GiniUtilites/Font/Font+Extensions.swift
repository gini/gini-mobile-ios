//
//  Font+Extensions.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import SwiftUI

extension Font {

    init(uiFont: UIFont) {
        self = Font(uiFont as CTFont)
    }
}
