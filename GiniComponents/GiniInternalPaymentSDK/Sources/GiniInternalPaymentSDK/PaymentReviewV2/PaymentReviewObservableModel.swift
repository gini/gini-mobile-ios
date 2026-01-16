//
//  PaymentReviewObservableModel.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import Combine
import GiniHealthAPILibrary
import SwiftUI

final class PaymentReviewObservableModel: ObservableObject {
    
    @Published var cellViewModels: [PageCollectionCellViewModel] = []
    @Published var isImagesLoading: Bool = false
    @Published var isLoading: Bool = false
    
    var document: Document? {
        model.document
    }
    
    var selectedPaymentProvider: PaymentProvider? {
        model.selectedPaymentProvider
    }
    
    let model: PaymentReviewModel
    
    init(model: PaymentReviewModel) {
        self.model = model
        setupBindings()
    }
    
    func fetchImages() async {
        await model.fetchImages()
    }
    
    private func setupBindings() {
        // Observe changes from the original model
        model.onPreviewImagesFetched = { [weak self] in
            DispatchQueue.main.async {
                self?.cellViewModels = self?.model.cellViewModels ?? []
            }
        }
        
        model.updateImagesLoadingStatus = { [weak self] in
            DispatchQueue.main.async {
                self?.isImagesLoading = self?.model.isImagesLoading == true
            }
        }
        
        model.updateLoadingStatus = { [weak self] in
            DispatchQueue.main.async {
                self?.isLoading = self?.model.isLoading == true
            }
        }
    }
}
