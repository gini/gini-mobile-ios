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

    private (set) var priceWithoutSkonto: Double {
        didSet {
            notifyStateChangeHandlers()
        }
    }

    private (set) var priceWithSkonto: Double {
        didSet {
            notifyStateChangeHandlers()
        }
    }

    var totalPrice: Double {
        return isSkontoApplied ? priceWithSkonto : priceWithoutSkonto
    }

    private (set) var date: Date {
        didSet {
            notifyStateChangeHandlers()
        }
    }

    private (set) var skontoValue: Double
    private (set) var currency: String

    init(isSkontoApplied: Bool,
         skontoValue: Double,
         date: Date,
         priceWithoutSkonto: Double,
         currency: String) {
        self.isSkontoApplied = isSkontoApplied
        self.skontoValue = skontoValue
        self.date = date
        self.priceWithoutSkonto = priceWithoutSkonto
        self.currency = currency
        self.priceWithSkonto = 0
        self.recalculatePriceWithSkonto()
    }

    func toggleDiscount() {
        isSkontoApplied.toggle()
    }

    func set(price: Double) {
        if isSkontoApplied {
            self.priceWithSkonto = price
            recalculatePriceWithoutSkonto()
        } else {
            self.priceWithoutSkonto = price
            recalculatePriceWithSkonto()
        }
    }

    func set(date: Date) {
        self.date = date
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

    private func recalculatePrices() {
        if isSkontoApplied {
            recalculatePriceWithSkonto()
        } else {
            recalculatePriceWithoutSkonto()
        }
    }

    private func recalculatePriceWithSkonto() {
        let calculatedPrice = priceWithoutSkonto * (1 - skontoValue / 100)
        priceWithSkonto = roundToTwoDecimalPlaces(calculatedPrice)
    }

    private func recalculatePriceWithoutSkonto() {
        let calculatedPrice = priceWithSkonto / (1 - skontoValue / 100)
        priceWithoutSkonto = roundToTwoDecimalPlaces(calculatedPrice)
    }

    private func roundToTwoDecimalPlaces(_ value: Double) -> Double {
        return Double(String(format: "%.2f", value)) ?? value
    }
}
