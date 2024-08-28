//
//  DigitalInvoiceViewModel.swift
//  GiniBank
//
//  Created by Krzysztof Kryniecki on 18/07/2022.
//

import Foundation

protocol DigitalInvoiceViewModelDelagate: AnyObject {
    func didTapHelp(on viewModel: DigitalInvoiceViewModel)
    func didTapCancel(on viewModel: DigitalInvoiceViewModel)
    func didTapPay(on viewModel: DigitalInvoiceViewModel)
    func didTapEdit(on viewModel: DigitalInvoiceViewModel, lineItemViewModel: DigitalLineItemTableViewCellViewModel)
    func shouldShowDigitalInvoiceOnboarding(on viewModel: DigitalInvoiceViewModel)
}

final class DigitalInvoiceViewModel {
    weak var delegate: DigitalInvoiceViewModelDelagate?
    var invoice: DigitalInvoice? {
        didSet {
            skontoViewModel?.setAmountToPayPrice(invoice?.total?.stringWithoutSymbol ?? "")
        }
    }
    var skontoViewModel: SkontoViewModel?

    var totalPrice: Price? {
        skontoViewModel?.isSkontoApplied == true ? skontoViewModel?.skontoAmountToPay : invoice?.total
    }

    var hasSkonto: Bool {
        return skontoViewModel != nil
    }

    init(invoice: DigitalInvoice?) {
        self.invoice = invoice
    }

    func isPayButtonEnabled() -> Bool {
        if let total = totalPrice?.value {
            return total > 0
        }

        return false
    }

    func didTapHelp() {
        delegate?.didTapHelp(on: self)
    }

    func didTapCancel() {
        delegate?.didTapCancel(on: self)
    }

    func didTapPay() {
        if hasSkonto {
            let totalPriceForExtractions = totalPrice
            self.invoice?.totalPriceForExtractions = totalPriceForExtractions
            self.invoice?.skontoExtractions = skontoViewModel?.editedExtractionResult.skontoDiscounts
        }
        delegate?.didTapPay(on: self)
    }

    func didTapEdit(on lineItemViewModel: DigitalLineItemTableViewCellViewModel) {
        delegate?.didTapEdit(on: self, lineItemViewModel: lineItemViewModel)
    }

    func shouldShowOnboarding() {
        delegate?.shouldShowDigitalInvoiceOnboarding(on: self)
    }
}
