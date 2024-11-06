//
//  SkontoViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import GiniBankAPILibrary

protocol SkontoViewModelDelegate: AnyObject {
    func didTapHelp()
    func didTapBack()
    func didTapProceed(on viewModel: SkontoViewModel)
    func didTapDocumentPreview(on viewModel: SkontoViewModel)
}

extension SkontoViewModelDelegate {
    func didTapProceed(on viewModel: SkontoViewModel) {
        // Default implementation
    }
}

class SkontoViewModel {
    private var skontoStateChangeHandlers: [() -> Void] = []
    var endEditingAction: (() -> Void)?
    var proceedAction: (() -> Void)?

    private let skontoDiscounts: SkontoDiscounts
    private (set) var isWithDiscountSwitchAvailable: Bool
    private var skontoPercentage: Double

    private (set) var isSkontoApplied: Bool = true
    private (set) var amountToPay: Price
    private (set) var skontoAmountToPay: Price

    private (set) var dueDate: Date
    private (set) var amountDiscounted: Price
    private (set) var currencyCode: String
    private (set) var remainingDays: Int
    private (set) var paymentMethod: SkontoDiscountDetails.PaymentMethod
    private (set) var edgeCase: SkontoEdgeCase?

    private (set) var documentPagesViewModel: SkontoDocumentPagesViewModel?

    private var maximumAmountToPayValue: Decimal = 99999.99

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

    var remainingDaysString: String {
        let text = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.day",
                                                            comment: "%@ days")
        return String.localizedStringWithFormat(text,
                                                remainingDays)
    }

    var skontoPercentageString: String {
        return String.localizedStringWithFormat(
            NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.total.skontopercentage",
                                                     comment: "%@ Skonto discount"),
            formattedPercentageDiscounted
        )
    }

    var savingsAmountString: String {
        return String.localizedStringWithFormat(
            NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.total.savings",
                                                     comment: "Save %@"),
            savingsPriceString
        )
    }

    var savingsPriceString: String {
        let savingsAmount = calculateSkontoSavingsAmount()
        guard let priceString = savingsAmount.localizedStringWithCurrencyCode else { return "" }
        return priceString
    }

    var localizedBannerInfoMessage: String {
        let text: String
        switch edgeCase {
        case .expired:
            let expiredMessageKey = "ginibank.skonto.infobanner.edgecase.expired.message"
            let localizedText = NSLocalizedStringPreferredGiniBankFormat(expiredMessageKey,
                                                                         comment: "The %@ discount has expired.")
            text = String.localizedStringWithFormat(localizedText,
                                                    formattedPercentageDiscounted)
        case .paymentToday:
            let todayMessageKey = "ginibank.skonto.infobanner.edgecase.today.message"
            let localizedText = NSLocalizedStringPreferredGiniBankFormat(todayMessageKey,
                                                                         comment: "Receive %@ Skonto discount.")
            text = String.localizedStringWithFormat(localizedText,
                                                    formattedPercentageDiscounted)
        case .payByCash:
            if remainingDays == 0 {
                let todayCashMessageKey = "ginibank.skonto.infobanner.edgecase.cash.today.message"
                let localizedText = NSLocalizedStringPreferredGiniBankFormat(todayCashMessageKey,
                                                                             comment: "Receive a %@ Skonto discount")
                text = String.localizedStringWithFormat(localizedText,
                                                        formattedPercentageDiscounted)
            } else {
                let cashMessageKey = "ginibank.skonto.infobanner.edgecase.cash.message"
                let localizedText = NSLocalizedStringPreferredGiniBankFormat(cashMessageKey,
                                                                             comment: "Cash within the next %@ days %@")
                text = String.localizedStringWithFormat(localizedText,
                                                        remainingDaysString,
                                                        formattedPercentageDiscounted)
            }
        default:
            let localizedText = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.infobanner.default.message",
                                                                         comment: "Pay in %@: %@ Skonto discount.")
            text = String.localizedStringWithFormat(localizedText,
                                                    remainingDaysString,
                                                    formattedPercentageDiscounted)
        }
        return text
    }

    private var errorMessage: String?

    weak var delegate: SkontoViewModelDelegate?

    init(skontoDiscounts: SkontoDiscounts,
         isWithDiscountSwitchAvailable: Bool = true) {
        self.skontoDiscounts = skontoDiscounts
        self.isWithDiscountSwitchAvailable = isWithDiscountSwitchAvailable

        // For now multiple Skonto discounts aren't handle
        let skontoDiscountDetails = skontoDiscounts.discounts[0]
        amountToPay = skontoDiscounts.totalAmountToPay
        skontoAmountToPay = skontoDiscountDetails.amountToPay
        dueDate = skontoDiscountDetails.dueDate
        amountDiscounted = skontoDiscountDetails.amountDiscounted
        currencyCode = amountToPay.currencyCode
        skontoPercentage = skontoDiscountDetails.percentageDiscounted
        remainingDays = skontoDiscountDetails.remainingDays
        paymentMethod = skontoDiscountDetails.paymentMethod
        determineSkontoEdgeCase()
        determineSkontoInitialState()
    }

    func toggleDiscount() {
        isSkontoApplied.toggle()
        endEditingAction?()
        notifyStateChangeHandlers()
    }

    func setSkontoAmountToPayPrice(_ price: String) {
        let errorMessage = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.withdiscount.validation",
                                                                    comment: "Discounted value cannot exceed...")
        setPrice(price,
                 maxValue: amountToPay.value,
                 errorMessage: errorMessage
        ) { validatedPrice in
            skontoAmountToPay = validatedPrice
            updateDocumentPagesModelData()
            recalculateSkontoPercentage()
        }
    }

    func setAmountToPayPrice(_ price: String) {
        let errorMessage = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.withoutdiscount.validation",
                                                                    comment: "Your transfer limit has been exceed...")
        setPrice(price,
                 maxValue: maximumAmountToPayValue,
                 errorMessage: errorMessage
        ) { validatedPrice in
            amountToPay = validatedPrice
            recalculateAmountToPayWithSkonto()
            updateDocumentPagesModelData()
        }
    }

    func setMaximumAmountToPayValue(_ value: Decimal?) {
        guard let value else { return }
        maximumAmountToPayValue = value
    }

    private func setPrice(_ price: String,
                          maxValue: Decimal,
                          errorMessage: String,
                          completion: (Price) -> Void) {
        let validationMessage = validatePrice(price, maxValue: maxValue, errorMessage: errorMessage)
        if let validationMessage {
            setErrorMessage(validationMessage)
            notifyStateChangeHandlers()
            return
        }
        guard let validatedPrice = convertPriceStringToPrice(price: price) else { return }
        completion(validatedPrice)
        notifyStateChangeHandlers()
    }

    private func validatePrice(_ price: String, maxValue: Decimal, errorMessage: String) -> String? {
        guard let convertedPrice = convertPriceStringToPrice(price: price), convertedPrice.value <= maxValue else {
            let formatter = NumberFormatter.twoDecimalPriceFormatter
            if let maxPriceString = formatter.string(from: NSDecimalNumber(decimal: maxValue)) {
                return String.localizedStringWithFormat(errorMessage, maxPriceString)
            }
            return errorMessage
        }
        return nil
    }

    func setExpiryDate(_ date: Date) {
        dueDate = date
        recalculateRemainingDays()
        updateDocumentPagesModelData()
        determineSkontoEdgeCase()
        notifyStateChangeHandlers()
    }

    func addStateChangeHandler(_ handler: @escaping () -> Void) {
        skontoStateChangeHandlers.append(handler)
    }

    func setDocumentPagesViewModel(_ viewModel: SkontoDocumentPagesViewModel) {
        documentPagesViewModel = viewModel
    }

    private func updateDocumentPagesModelData() {
        documentPagesViewModel?.updateExpiryDate(date: dueDate)
        documentPagesViewModel?.updateAmountToPay(price: amountToPay)
        documentPagesViewModel?.updateSkontoAmountToPay(price: skontoAmountToPay)
    }

    // MARK: - Actions

    func helpButtonTapped() {
        delegate?.didTapHelp()
    }

    func backButtonTapped() {
        delegate?.didTapBack()
    }

    func proceedButtonTapped() {
        delegate?.didTapProceed(on: self)
    }

    func documentPreviewTapped() {
        delegate?.didTapDocumentPreview(on: self)
    }

    // MARK: - ExtractionResult to send to customers
    /**
     The edited `ExtractionResult` data.
     */
    public var editedExtractionResult: ExtractionResult {
        var modifiedSkontoExtractions: [Extraction]?
        // For now we don't handle multiple Skonto discounts
        if let skontoDiscountExtraction = skontoDiscounts.initialExtractionResult.skontoDiscounts?.first {
            modifiedSkontoExtractions = skontoDiscountExtraction.map { extraction -> Extraction in
                let modifiedExtraction = extraction
                switch modifiedExtraction.name {
                case "skontoAmountToPay", "skontoAmountToPayCalculated":
                        modifiedExtraction.value = skontoAmountToPay.extractionString
                case "skontoDueDate", "skontoDueDateCalculated":
                    modifiedExtraction.value = dueDate.yearMonthDayString
                case "skontoPercentageDiscounted", "skontoPercentageDiscountedCalculated":
                    modifiedExtraction.value = formattedPercentageDiscounted
                case "skontoAmountDiscounted", "skontoAmountDiscountedCalculated":
                    modifiedExtraction.value = amountDiscounted.extractionString
                case "skontoRemainingDays":
                    modifiedExtraction.value = "\(remainingDays)"
                default:
                    break
                }
                return modifiedExtraction
            }
        }

        let modifiedExtractions = skontoDiscounts.initialExtractionResult.extractions
            .map { extraction -> Extraction in
                let modifiedExtraction = extraction
                if modifiedExtraction.name == "amountToPay" {
                    modifiedExtraction.value = finalAmountToPay.extractionString
                }
                return modifiedExtraction
            }

        let modifiedSkontoDiscounts = [modifiedSkontoExtractions].compactMap { $0 }
        return ExtractionResult(extractions: modifiedExtractions,
                                skontoDiscounts: modifiedSkontoDiscounts,
                                candidates: skontoDiscounts.initialExtractionResult.candidates)
    }

    public var extractionBoundingBoxes: [ExtractionBoundingBox] {
        // For now we don't handle multiple Skonto discounts
        guard let skontoDiscountExtraction = skontoDiscounts.discounts.first else {
            return []
        }

        return skontoDiscountExtraction.boundingBoxes
    }

    // MARK: - Private methods

    private func convertPriceStringToPrice(price: String) -> Price? {
        guard let priceValue = Price.convertLocalizedStringToDecimal(price) else {
            return nil
        }
        return Price(value: priceValue, currencyCode: currencyCode)
    }

    private func recalculateRemainingDays() {
        let calendar = Calendar.current
        let currentDate = calendar.startOfDay(for: Date().inBerlinTimeZone)
        let dueDate = calendar.startOfDay(for: self.dueDate)
        let components = calendar.dateComponents([.day], from: currentDate, to: dueDate)
        remainingDays = components.day ?? 0
    }

    private func notifyStateChangeHandlers() {
        for stateHandler in skontoStateChangeHandlers {
            stateHandler()
        }
    }

    private func recalculateAmountToPayWithSkonto() {
        let calculatedPrice = amountToPay.value * (1 - Decimal(skontoPercentage) / 100)
        skontoAmountToPay = Price(value: calculatedPrice, currencyCode: currencyCode)
    }

    private func recalculateSkontoPercentage() {
        guard amountToPay.value > 0 else {
            return
        }

        let skontoPercentageValue = ((amountToPay.value - skontoAmountToPay.value) / amountToPay.value) * 100
        self.skontoPercentage = Double(truncating: skontoPercentageValue as NSNumber)
    }

    private func calculateSkontoSavingsAmount() -> Price {
        let skontoSavingsValue = amountToPay.value - skontoAmountToPay.value
        return Price(value: skontoSavingsValue, currencyCode: currencyCode)
    }

    /**
     Sets `edgeCase` and `isSkontoApplied` based on the following priorities:
     1) expired discount, 2) cash payment, 3) payment due today, 4) no edge case.
     - Note: If both `paymentMethod` and `remainingDays` conditions apply, `paymentMethod` is considered the major case.
    */
    private func determineSkontoEdgeCase() {
        if remainingDays < 0 {
            edgeCase = .expired
        } else if paymentMethod == .cash {
            edgeCase = .payByCash
        } else if remainingDays == 0 {
            edgeCase = .paymentToday
        } else {
            edgeCase = nil
        }
    }

    /**
     This method determines whether the 'Skonto' should be applied based on the current edge case.
     */
    private func determineSkontoInitialState() {
        switch edgeCase {
        case .expired, .payByCash:
            isSkontoApplied = false
        default:
            isSkontoApplied = true
        }
    }

    func setErrorMessage(_ message: String) {
        errorMessage = message
    }

    func getErrorMessageAndClear() -> String? {
        defer { errorMessage = nil }
        return errorMessage
    }
}
