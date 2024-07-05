//
//  SkontoViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

class SkontoViewModel {
    private var skontoStateChangeHandlers: [() -> Void] = []

    private (set) var isSkontoApplied: Bool
    private (set) var priceWithoutSkonto: Price
    private (set) var priceWithSkonto: Price

    var totalPrice: Price {
        return isSkontoApplied ? priceWithSkonto : priceWithoutSkonto
    }

    private (set) var date: Date
    private (set) var skontoValue: Double
    private (set) var currencyCode: String

    // TODO: recalculate with backend entity: skontoDuePeriod
    var skontoFormattedDuePeriod: String {
        return "14 days"
    }

    var skontoFormattedPercentageDiscounted: String {
        if skontoValue.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(skontoValue))%"
        } else {
            return String(format: "%.1f%%", skontoValue)
        }
    }

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
        notifyStateChangeHandlers()
    }

    func setSkontoPrice(price: String) {
        guard let price = convertPriceStringToPrice(price: price) else { return }
        priceWithSkonto = price
        recalculatePriceWithoutSkonto()
        notifyStateChangeHandlers()
    }

    func setDefaultPrice(price: String) {
        guard let price = convertPriceStringToPrice(price: price) else { return }
        priceWithoutSkonto = price
        recalculatePriceWithSkonto()
        notifyStateChangeHandlers()
    }

    private func convertPriceStringToPrice(price: String) -> Price? {
        guard let priceValue = Price.convertStringToDecimal(price) else {
            return nil
        }
        return Price(value: priceValue, currencyCode: currencyCode)
    }

    func set(date: Date) {
        self.date = date
        notifyStateChangeHandlers()
    }

    func addStateChangeHandler(_ handler: @escaping () -> Void) {
        skontoStateChangeHandlers.append(handler)
    }

    private func notifyStateChangeHandlers() {
        for stateHandler in skontoStateChangeHandlers {
            stateHandler()
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

    private func recalculatePriceWithSkonto() {
        let calculatedPrice = priceWithoutSkonto.value * (1 - Decimal(skontoValue) / 100)
        priceWithSkonto = Price(value: calculatedPrice, currencyCode: currencyCode)
    }

    private func recalculatePriceWithoutSkonto() {
        let calculatedPrice = priceWithSkonto.value / (1 - Decimal(skontoValue) / 100)
        priceWithoutSkonto = Price(value: calculatedPrice, currencyCode: currencyCode)
    }
}
