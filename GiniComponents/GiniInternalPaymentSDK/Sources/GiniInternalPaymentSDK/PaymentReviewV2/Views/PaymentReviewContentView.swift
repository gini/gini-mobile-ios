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
        let sheetWidth = geometry.size.width * Constants.screenPercentage
        
        HStack(spacing: Constants.zero) {
            ScrollView {
                viewModel.paymentReviewPaymentInformationView(
                    contentHeight: $bottomSheetHeight,
                    collapsedHeight: $collapsedHeight
                )
            }
            .frame(width: sheetWidth)
            
            ScrollView {
                documentPreviewContent(carouselHeight: carouselHeight)
            }
            .frame(width: geometry.size.width - sheetWidth)
        }
        .padding(.bottom, Constants.paymentInformationViewHorizontalPadding)
    }
    
    // MARK: - Private Views
    
    @ViewBuilder
    private func documentPreviewContent(carouselHeight: CGFloat) -> some View {
        VStack(spacing: Constants.documentPreviewStackSpacing) {
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
        let effectiveBottomSheetHeight = bottomSheetHeight > 0 ? bottomSheetHeight : Constants.bottomSheetDefaultHeight
        
        let calculatedHeight: CGFloat
        if isLandscape {
            calculatedHeight = geometry.size.height - Constants.totalPaddings - Constants.pageIndicatorSpace
        } else {
            calculatedHeight = geometry.size.height - effectiveBottomSheetHeight + Constants.bottomSheetOverlap - Constants.totalPaddings - Constants.pageIndicatorSpace
        }
        
        return max(calculatedHeight, Constants.carouselDefaultHeight)
    }
    
    private struct Constants {
        static let zero: CGFloat = 0.0
        static let bottomSheetDefaultHeight: CGFloat = 300
        static let collapsedDefaultHeight: CGFloat = 90
        static let bottomSheetOverlap: CGFloat = 20.0
        static let carouselDefaultHeight: CGFloat = 300.0
        static let screenPercentage: CGFloat = 0.55
        static let paymentInformationViewHorizontalPadding: CGFloat = 16.0
        static let documentPreviewStackSpacing: CGFloat = 16.0
        static let totalPaddings: CGFloat = 32.0
        static let pageIndicatorSpace: CGFloat = 30.0
    }
}
