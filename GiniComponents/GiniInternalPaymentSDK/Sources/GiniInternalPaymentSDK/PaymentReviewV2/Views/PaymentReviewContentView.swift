//
//  PaymentReviewContentView.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import SwiftUI

public struct PaymentReviewContentView: View {
    
    @ObservedObject private var viewModel: PaymentReviewObservableModel
    
    init(viewModel: PaymentReviewObservableModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        if #available(iOS 15.0, *) {
            ScrollView {
                VStack(spacing: 16) {
                    if viewModel.isImagesLoading {
                                        ProgressView()
                                            .frame(height: 400)
                                    } else if !viewModel.cellViewModels.isEmpty {
                                        let images = viewModel.cellViewModels.compactMap { $0.preview }
                                        GiniCarouselView(images: images)
                                            .frame(height: 500)
                                    }
                }
                .padding()
            }
            .task {
                await viewModel.fetchImages()
            }
        } else {
            // Fallback on earlier versions
        }
    }
}
