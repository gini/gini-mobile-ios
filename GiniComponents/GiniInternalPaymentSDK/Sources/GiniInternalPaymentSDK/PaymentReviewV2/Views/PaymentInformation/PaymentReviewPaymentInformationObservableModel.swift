//
//  PaymentReviewPaymentInformationObservableModel.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Combine
import GiniHealthAPILibrary
import SwiftUI

final class PaymentReviewPaymentInformationObservableModel: ObservableObject {
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var extractions: [Extraction]
    @Published var selectedPaymentProvider: PaymentProvider
    
    let model: PaymentReviewContainerViewModel
    
    init(model: PaymentReviewContainerViewModel) {
        self.model = model
        self.extractions = model.extractions ?? []
        self.selectedPaymentProvider = model.selectedPaymentProvider
        
        setupBindings()
    }
    
    private func setupBindings() {
        model.onExtractionFetched = { [weak self] () in
            DispatchQueue.main.async {
                self?.extractions = self?.model.extractions ?? []
            }
        }
        
        /// Subscribe to payment provider changes
        model.$selectedPaymentProvider
            .sink { [weak self] newProvider in
                self?.selectedPaymentProvider = newProvider
            }
            .store(in: &cancellables)
    }
}
