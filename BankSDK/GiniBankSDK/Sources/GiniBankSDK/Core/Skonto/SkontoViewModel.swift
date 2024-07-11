//
//  SkontoViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

protocol SkontoViewModelDelegate: AnyObject {
    func didTapHelp()
    func didTapBack()
    func didTapProceed(on viewModel: SkontoViewModel)
}

class SkontoViewModel {
    private var skontoStateChangeHandlers: [() -> Void] = []
    var endEditingAction: (() -> Void)?
    var proceedAction: (() -> Void)?

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
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .decimal
        formatter.roundingMode = .floor
        if let formattedValue = formatter.string(from: NSNumber(value: skontoValue)) {
            return "\(formattedValue)%"
        } else {
            return "\(skontoValue)%"
        }
    }

    weak var delegate: SkontoViewModelDelegate?

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
        endEditingAction?()
        notifyStateChangeHandlers()
    }

    func setSkontoPrice(price: String) {
        guard let price = convertPriceStringToPrice(price: price), price.value <= priceWithoutSkonto.value else {
            notifyStateChangeHandlers()
            return
        }
        priceWithSkonto = price
        recalculateSkontoValue()
        notifyStateChangeHandlers()
    }

    func setDefaultPrice(price: String) {
        guard let price = convertPriceStringToPrice(price: price) else { return }
        priceWithoutSkonto = price
        recalculatePriceWithSkonto()
        notifyStateChangeHandlers()
    }

    private func convertPriceStringToPrice(price: String) -> Price? {
        guard let priceValue = Price.convertLocalizedStringToDecimal(price) else {
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

    func helpButtonTapped() {
        delegate?.didTapHelp()
    }

    func backButtonTapped() {
        delegate?.didTapBack()
    }

    func proceedButtonTapped() {
        delegate?.didTapProceed(on: self)
    }

    private func recalculatePriceWithSkonto() {
        let calculatedPrice = priceWithoutSkonto.value * (1 - Decimal(skontoValue) / 100)
        priceWithSkonto = Price(value: calculatedPrice, currencyCode: currencyCode)
    }

    private func recalculatePriceWithoutSkonto() {
        let calculatedPrice = priceWithSkonto.value / (1 - Decimal(skontoValue) / 100)
        priceWithoutSkonto = Price(value: calculatedPrice, currencyCode: currencyCode)
    }

    private func recalculateSkontoValue() {
        let skontoPercentage = ((priceWithoutSkonto.value - priceWithSkonto.value) / priceWithoutSkonto.value) * 100
        skontoValue = Double(truncating: skontoPercentage as NSNumber)
    }
}