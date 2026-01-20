//
//  PaymentReviewContentView.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import SwiftUI

public struct PaymentReviewContentView: View {
    
    @ObservedObject private var viewModel: PaymentReviewObservableModel
    @State private var hasAppeared = false
    
    /// The init method is internal to prevent users from creating instances of this view directly
    /// outside of GiniInternalPaymentSDK.
    init(viewModel: PaymentReviewObservableModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                documentPreviewContent
            }
            .padding()
        }
        .onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            
            Task {
                await viewModel.fetchImages()
            }
        }
    }
    
    // MARK: - Private Views
    
    @ViewBuilder
    private var documentPreviewContent: some View {
        VStack(spacing: 16) {
            if viewModel.isImagesLoading {
                showLoader()
            } else if !viewModel.cellViewModels.isEmpty {
                showPreviewImageCarousel()
            }
        }
    }
    
    @ViewBuilder
    private func showLoader() -> some View {
        ProgressView()
            .frame(height: 400)
    }
    
    @ViewBuilder
    private func showPreviewImageCarousel() -> some View {
        let images = viewModel.cellViewModels.compactMap { $0.preview }
        GiniCarouselView(images: images)
            .frame(height: 500)
    }
}
