//
//  TransactionSummaryViewModel.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import GiniBankAPILibrary

protocol TransactionSummaryViewModel {
    var items: [ExtractionViewData] { get }
    var isCrossBorderPayment: Bool { get }
    func updateValue(at index: Int, value: String)
}

final class DefaultTransactionSummaryViewModel: TransactionSummaryViewModel {

    private(set) var items: [ExtractionViewData] = []
    let isCrossBorderPayment: Bool

    /**
     Sorted references to the underlying `Extraction` objects.
     Mutating `.value` here propagates back to the coordinator's array via class reference.
     */
    private let sortedExtractions: [Extraction]

    init(extractions: [Extraction],
         editableFields: [String: String],
         isCrossBorderPayment: Bool) {
        self.isCrossBorderPayment = isCrossBorderPayment
        self.sortedExtractions = extractions.sorted { ($0.name ?? "") < ($1.name ?? "") }
        self.items = sortedExtractions.map { extraction in
            let name = extraction.name ?? ""
            let title = name
            let isEditable = isCrossBorderPayment || editableFields[name] != nil
            return ExtractionViewData(title: title,
                                      value: extraction.value,
                                      isEditable: isEditable,
                                      name: extraction.name)
        }
    }

    func updateValue(at index: Int, value: String) {
        guard items.indices.contains(index) else { return }
        items[index].value = value
        /// Mutate the underlying `Extraction` class so the coordinator's extractedResults
        /// array reflects the user's edit without requiring any additional callback.
        sortedExtractions[index].value = value
    }
}
