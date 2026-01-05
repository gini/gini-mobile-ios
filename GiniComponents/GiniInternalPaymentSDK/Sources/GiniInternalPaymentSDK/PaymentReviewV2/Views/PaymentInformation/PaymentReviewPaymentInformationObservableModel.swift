//
//  PaymentReviewPaymentInformationObservableModel.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Combine
import GiniHealthAPILibrary
import SwiftUI

final class PaymentReviewPaymentInformationObservableModel: ObservableObject {
    
    @Published var extractions: [Extraction]
    
    let model: PaymentReviewContainerViewModel
    
    init(model: PaymentReviewContainerViewModel) {
        self.model = model
        self.extractions = model.extractions ?? []
        
        setupBindings()
    }
    
    private func setupBindings() {
        model.onExtractionFetched = { [weak self] () in
            DispatchQueue.main.async {
                self?.extractions = self?.model.extractions ?? []
            }
        }
    }
}
