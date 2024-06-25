//
//  SkontoViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

public class SkontoViewModel {
    private var observers: [(Bool) -> Void] = []

    private (set) var isSkontoApplied: Bool {
        didSet {
            notifyObservers()
        }
    }

    init(isSkontoApplied: Bool) {
        self.isSkontoApplied = isSkontoApplied
    }

    func toggleDiscount() {
        isSkontoApplied.toggle()
    }

    func addObserver(_ observer: @escaping (Bool) -> Void) {
        observers.append(observer)
    }

    private func notifyObservers() {
        for observer in observers {
            observer(isSkontoApplied)
        }
    }
}
