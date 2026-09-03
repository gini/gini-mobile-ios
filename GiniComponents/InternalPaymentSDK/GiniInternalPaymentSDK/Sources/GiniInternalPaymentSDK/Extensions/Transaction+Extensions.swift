//
//  Transaction+Extensions.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI

extension Transaction {
    /**
     Disables ambient UIKit animation inheritance (e.g. keyboard CATransaction).
     */
    static var withoutAnimation: Transaction {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        return transaction
    }
}
