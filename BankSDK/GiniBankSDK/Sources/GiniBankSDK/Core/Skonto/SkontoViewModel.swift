//
//  SkontoViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

public class SkontoViewModel {
    private var skontoStateChangeHandlers: [() -> Void] = []

    private (set) var isSkontoApplied: Bool {
        didSet {
            notifyStateChangeHandlers()
        }
    }

    private (set) var skontoValue: Double
    private (set) var date: Date
    private (set) var priceWithoutSkonto: Double
    private (set) var currency: String

    init(isSkontoApplied: Bool, skontoValue: Double, date: Date, priceWithoutSkonto: Double, currency: String) {
        self.isSkontoApplied = isSkontoApplied
        self.skontoValue = skontoValue
        self.date = date
        self.priceWithoutSkonto = priceWithoutSkonto
        self.currency = currency
    }

    func toggleDiscount() {
        isSkontoApplied.toggle()
    }

    func addStateChangeHandler(_ handler: @escaping () -> Void) {
        skontoStateChangeHandlers.append(handler)
    }

    private func notifyStateChangeHandlers() {
        for handler in skontoStateChangeHandlers {
            handler()
        }
    }

    func proceedButtonTapped() {
        // TODO: Handle proceed button tap
    }

    func helpButtonTapped() {
        // TODO: Handle help button tap
    }

    func backButtonTapped() {
        // TODO: Handle back button tap
    }
}
