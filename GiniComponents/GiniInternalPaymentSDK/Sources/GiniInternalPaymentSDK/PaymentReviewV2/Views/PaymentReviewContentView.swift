//
//  PaymentReviewContentView.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import SwiftUI

public struct PaymentReviewContentView: View {
    
    @ObservedObject private var viewModel: PaymentReviewObservableModel
    @State private var hasAppeared = false
    @State private var showBottomSheet = true
    @State private var bottomSheetHeight = Constants.bottomSheetDefaultHeight
    @State private var carouselHeight = Constants.carouselDefaultHeight
    
    /// The init method is internal to prevent users from creating instances of this view directly
    /// outside of GiniInternalPaymentSDK.
    init(viewModel: PaymentReviewObservableModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                ScrollView {
                    documentPreviewContent()
                        .padding()
                        .padding(.bottom, max(bottomSheetHeight - Constants.bottomSheetOverlap, 0))
                }
                .onAppear {
                    guard !hasAppeared else { return }
                    hasAppeared = true
                    
                    Task {
                        await viewModel.fetchImages()
                    }
                }
                .onChange(of: bottomSheetHeight) { _ in
                    updateCarouselHeight(screenHeight: geometry.size.height)
                }
                .onChange(of: geometry.size.height) { newHeight in
                    updateCarouselHeight(screenHeight: newHeight)
                }
            }
            .sheet(isPresented: $showBottomSheet) {
                
            } content: {
                viewModel.paymentReviewPaymentInformationView(contentHeight: $bottomSheetHeight)
                    .modifier(GiniBottomSheetModifier(contentHeight: bottomSheetHeight))
            }
        }
    }
    
    // MARK: - Private Views
    
    @ViewBuilder
    private func documentPreviewContent() -> some View {
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
            .frame(height: carouselHeight)
    }
    
    @ViewBuilder
    private func showPreviewImageCarousel() -> some View {
        let images = viewModel.cellViewModels.compactMap { $0.preview }
        
        GiniCarouselView(images: images)
            .frame(height: carouselHeight)
    }
    
    private func updateCarouselHeight(screenHeight: CGFloat) {
        let totalPaddings = 32.0
        let effectiveBottomSheetHeight = bottomSheetHeight > 0 ? bottomSheetHeight : Constants.bottomSheetDefaultHeight
        let calculatedHeight = screenHeight - effectiveBottomSheetHeight + Constants.bottomSheetOverlap - totalPaddings
        
        carouselHeight = max(calculatedHeight, Constants.carouselDefaultHeight)
    }
    
    private struct Constants {
        
        static let bottomSheetDefaultHeight: CGFloat = 300
        static let bottomSheetOverlap: CGFloat = 20
        static let carouselDefaultHeight = 300.0
    }
}
