//
//  SkontoViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

public class SkontoViewModel {
    var isSkontoApplied: Bool {
        didSet {
            onSkontoToggle?(isSkontoApplied)
        }
    }

    var onSkontoToggle: ((Bool) -> Void)?

    init(isSkontoApplied: Bool) {
        self.isSkontoApplied = isSkontoApplied
    }

    func toggleDiscount() {
        isSkontoApplied.toggle()
    }
}
