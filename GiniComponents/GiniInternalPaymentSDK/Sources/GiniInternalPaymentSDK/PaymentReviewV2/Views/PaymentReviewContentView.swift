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
    @State private var collapsedHeight = Constants.collapsedDefaultHeight
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    /// The init method is internal to prevent users from creating instances of this view directly
    /// outside of GiniInternalPaymentSDK.
    init(viewModel: PaymentReviewObservableModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        GeometryReader { geometry in
            if isLandscape {
                landscapeLayout(geometry: geometry)
            } else {
                portraitLayout(geometry: geometry)
            }
        }
        .onAppear {
            fetchImagesIfNeeded()
            viewModel.dismissBannerAfterDelay()
        }
    }
    
    // MARK: - Portrait Layout
    
    @ViewBuilder
    private func portraitLayout(geometry: GeometryProxy) -> some View {
        let carouselHeight = computedCarouselHeight(for: geometry, isLandscape: false)
        
        ZStack {
            ScrollView {
                documentPreviewContent(carouselHeight: carouselHeight)
                    .padding()
                    .padding(.bottom, max(bottomSheetHeight - Constants.bottomSheetOverlap, 0))
                    .frame(width: geometry.size.width)
            }
        }
        .sheet(isPresented: $showBottomSheet) {
            
        } content: {
            viewModel.paymentReviewPaymentInformationView(
                contentHeight: $bottomSheetHeight,
                collapsedHeight: $collapsedHeight
            )
            .modifier(GiniBottomSheetModifier(
                contentHeight: bottomSheetHeight,
                collapsedHeight: collapsedHeight
            ))
        }
    }
    
    // MARK: - Landscape Layout
    
    @ViewBuilder
    private func landscapeLayout(geometry: GeometryProxy) -> some View {
        let carouselHeight = computedCarouselHeight(for: geometry, isLandscape: true)
        let sheetWidth = geometry.size.width * 0.55
        
        HStack(spacing: 0) {
            ScrollView {
                viewModel.paymentReviewPaymentInformationView(
                    contentHeight: $bottomSheetHeight,
                    collapsedHeight: $collapsedHeight
                )
                .padding(.vertical, 16)
            }
            .frame(width: sheetWidth)
            
            ScrollView {
                documentPreviewContent(carouselHeight: carouselHeight)
                    .padding()
            }
            .frame(width: geometry.size.width - sheetWidth)
        }
    }
    
    // MARK: - Private Views
    
    @ViewBuilder
    private func documentPreviewContent(carouselHeight: CGFloat) -> some View {
        VStack(spacing: 16) {
            if viewModel.isImagesLoading {
                showLoader(carouselHeight: carouselHeight)
            } else if !viewModel.cellViewModels.isEmpty {
                showPreviewImageCarousel(carouselHeight: carouselHeight)
            }
        }
    }
    
    @ViewBuilder
    private func showLoader(carouselHeight: CGFloat) -> some View {
        ProgressView()
            .frame(height: carouselHeight)
    }
    
    @ViewBuilder
    private func showPreviewImageCarousel(carouselHeight: CGFloat) -> some View {
        let images = viewModel.cellViewModels.compactMap { $0.preview }
        
        GiniCarouselView(images: images)
            .frame(height: carouselHeight)
    }
    
    // MARK: - Private Methods
    
    private func fetchImagesIfNeeded() {
        guard !hasAppeared else { return }
        hasAppeared = true
        
        Task {
            await viewModel.fetchImages()
        }
    }
    
    private func computedCarouselHeight(for geometry: GeometryProxy, isLandscape: Bool) -> CGFloat {
        let totalPaddings = 32.0
        let pageIndicatorSpace = 30.0
        let effectiveBottomSheetHeight = bottomSheetHeight > 0 ? bottomSheetHeight : Constants.bottomSheetDefaultHeight
        
        let calculatedHeight: CGFloat
        if isLandscape {
            calculatedHeight = geometry.size.height - totalPaddings - pageIndicatorSpace
        } else {
            calculatedHeight = geometry.size.height - effectiveBottomSheetHeight + Constants.bottomSheetOverlap - totalPaddings - pageIndicatorSpace
        }
        
        return max(calculatedHeight, Constants.carouselDefaultHeight)
    }
    
    private struct Constants {
        static let bottomSheetDefaultHeight: CGFloat = 300
        static let collapsedDefaultHeight: CGFloat = 90
        static let bottomSheetOverlap: CGFloat = 20
        static let carouselDefaultHeight = 300.0
    }
}
