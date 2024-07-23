//
//  SkontoViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import GiniBankAPILibrary

protocol SkontoViewModelDelegate: AnyObject {
    // MARK: Temporary remove help action
//    func didTapHelp()
    func didTapBack()
    func didTapProceed(on viewModel: SkontoViewModel)
}

class SkontoViewModel {
    private var skontoStateChangeHandlers: [() -> Void] = []
    var endEditingAction: (() -> Void)?
    var proceedAction: (() -> Void)?

    private let skontoDiscounts: SkontoDiscounts
    private var skontoPercentage: Double

    private (set) var isSkontoApplied: Bool
    private (set) var amountToPay: Price
    private (set) var skontoAmountToPay: Price

    private (set) var dueDate: Date
    private (set) var amountToPayDiscounted: Price
    private (set) var currencyCode: String
    private (set) var remainingDays: Int

    var finalAmountToPay: Price {
        return isSkontoApplied ? skontoAmountToPay : amountToPay
    }

    var formattedPercentageDiscounted: String {
        let formatter = NumberFormatter.floorRoundingFormatter
        if let formattedValue = formatter.string(from: NSNumber(value: skontoPercentage)) {
            return "\(formattedValue)%"
        } else {
            return "\(skontoPercentage)%"
        }
    }

    var localizedDiscountString: String {
        return String.localizedStringWithFormat(
            NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.total.amount.skonto",
                                                     comment: "%@ Skonto discount"),
            formattedPercentageDiscounted
        )
    }

    weak var delegate: SkontoViewModelDelegate?

    init(skontoDiscounts: SkontoDiscounts,
         amountToPay: Price) {
        self.skontoDiscounts = skontoDiscounts

        // For now we don't handle multiple Skonto discounts
        let skontoDiscountDetails = skontoDiscounts.discounts[0]

        // TODO: set `isSkontoApplied` based on each Skonto edgecases
        isSkontoApplied = true

        self.amountToPay = amountToPay
        skontoAmountToPay = skontoDiscountDetails.amountToPay
        dueDate = skontoDiscountDetails.dueDate
        amountToPayDiscounted = skontoDiscountDetails.amountDiscounted
        currencyCode = amountToPay.currencyCode
        skontoPercentage = skontoDiscountDetails.percentageDiscounted
        remainingDays = skontoDiscountDetails.remainingDays

        recalculateAmountToPayWithSkonto()
    }

    func toggleDiscount() {
        isSkontoApplied.toggle()
        endEditingAction?()
        notifyStateChangeHandlers()
    }

    func setSkontoPrice(price: String) {
        guard let price = convertPriceStringToPrice(price: price), price.value <= amountToPay.value else {
            notifyStateChangeHandlers()
            return
        }
        skontoAmountToPay = price
        recalculateSkontoPercentage()
        notifyStateChangeHandlers()
    }

    func setDefaultPrice(price: String) {
        guard let price = convertPriceStringToPrice(price: price) else { return }
        amountToPay = price
        recalculateAmountToPayWithSkonto()
        notifyStateChangeHandlers()
    }

    private func convertPriceStringToPrice(price: String) -> Price? {
        guard let priceValue = Price.convertLocalizedStringToDecimal(price) else {
            return nil
        }
        return Price(value: priceValue, currencyCode: currencyCode)
    }

    func set(date: Date) {
        self.dueDate = date
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

    // MARK: Temporary remove help action
//    func helpButtonTapped() {
//        delegate?.didTapHelp()
//    }

    func backButtonTapped() {
        delegate?.didTapBack()
    }

    func proceedButtonTapped() {
        delegate?.didTapProceed(on: self)
    }

    private func recalculateAmountToPayWithSkonto() {
        let calculatedPrice = amountToPay.value * (1 - Decimal(skontoPercentage) / 100)
        skontoAmountToPay = Price(value: calculatedPrice, currencyCode: currencyCode)
    }

    private func recalculateSkontoPercentage() {
        guard amountToPay.value > 0 else {
            return
        }

        let skontoPercentage = ((amountToPay.value - skontoAmountToPay.value) / amountToPay.value) * 100
        self.skontoPercentage = Double(truncating: skontoPercentage as NSNumber)
    }

    /**
     The edited `ExtractionResult` data.
     */

        let modifiedSkontoExtractions = skontoDiscounts.initialExtractionResult.skontoDiscounts?[0]
            .map { extraction -> Extraction in

            if extraction.name == "skontoAmountToPay" {
                extraction.value = "\(skontoAmountToPay.value)"
            } else if extraction.name == "skontoDueDate" {
                // TODO: send the modified due date
                extraction.value = "22-07-2024"
    public var editedExtractionResult: ExtractionResult {
            }
            return extraction
        }

        let modifiedExtractions = skontoDiscounts.initialExtractionResult.extractions
            .map { extraction -> Extraction in

                if extraction.name == "amountToPay" {
                    extraction.value = "\(finalAmountToPay.value)"
                }

                return extraction
            }

        // TODO: skontoDiscounts should be [[Extraction]]?
        return ExtractionResult(extractions: modifiedExtractions,
                                skontoDiscounts: nil,
                                candidates: skontoDiscounts.initialExtractionResult.candidates)
    }
}
