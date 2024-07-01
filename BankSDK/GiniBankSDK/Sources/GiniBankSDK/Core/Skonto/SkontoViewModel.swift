//
//  SkontoViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

class SkontoViewModel {
    private var skontoStateChangeHandlers: [() -> Void] = []

    private (set) var isSkontoApplied: Bool {
        didSet {
            notifyStateChangeHandlers()
        }
    }

    private (set) var priceWithoutSkonto: Price {
        didSet {
            notifyStateChangeHandlers()
        }
    }

    private (set) var priceWithSkonto: Price {
        didSet {
            notifyStateChangeHandlers()
        }
    }

    var totalPrice: Price {
        return isSkontoApplied ? priceWithSkonto : priceWithoutSkonto
    }

    private (set) var date: Date {
        didSet {
            notifyStateChangeHandlers()
        }
    }

    private (set) var skontoValue: Double
    private (set) var currencyCode: String

    init(isSkontoApplied: Bool,
         skontoValue: Double,
         date: Date,
         priceWithoutSkonto: Price) {
        self.isSkontoApplied = isSkontoApplied
        self.skontoValue = skontoValue
        self.date = date
        self.priceWithoutSkonto = priceWithoutSkonto
        self.currencyCode = priceWithoutSkonto.currencyCode
        self.priceWithSkonto = priceWithoutSkonto // Placeholder, will be recalculated
        self.recalculatePriceWithSkonto()
    }

    func toggleDiscount() {
        isSkontoApplied.toggle()
    }

    func set(price: String) {
        guard let priceValue = Price.convertStringToDecimal(price) else {
            return
        }
        let price = Price(value: priceValue, currencyCode: currencyCode)
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
        let calculatedPrice = priceWithoutSkonto.value * (1 - Decimal(skontoValue) / 100)
        priceWithSkonto = Price(value: calculatedPrice, currencyCode: currencyCode)
    }

    private func recalculatePriceWithoutSkonto() {
        let calculatedPrice = priceWithSkonto.value / (1 - Decimal(skontoValue) / 100)
        priceWithoutSkonto = Price(value: calculatedPrice, currencyCode: currencyCode)
    }
}
