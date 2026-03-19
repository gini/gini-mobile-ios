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
            if isLandscape && !viewModel.isBottomSheetMode {
                landscapeLayout(geometry: geometry)
                    .transition(.opacity)
            } else {
                portraitLayout(geometry: geometry)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: Constants.layoutTransitionDuration), value: isLandscape)
        .onChange(of: isLandscape) { landscape in
            // When rotating to landscape in documentCollection mode, dismiss the
            // sheet immediately (without animation) so the crossfade transition
            // isn't disrupted by the sheet's own dismissal animation.
            if landscape && !viewModel.isBottomSheetMode && showBottomSheet {
                showBottomSheet = false
            }
        }
        .overlay {
            loadingOverlay
        }
        .task {
            guard !hasAppeared else { return }
            hasAppeared = true
            await viewModel.fetchImages()
        }
        .onAppear {
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
        .onAppear {
            // On iOS 16/17, rotating to landscape destroys portraitLayout which
            // dismisses the sheet and sets showBottomSheet to false. Restore it
            // when portraitLayout reappears in documentCollection mode.
            // Delay so the layout crossfade finishes before the sheet slides in.
            if !viewModel.isBottomSheetMode && !showBottomSheet {
                showBottomSheet = true
            }
        }
        .sheet(isPresented: $showBottomSheet) {
            if viewModel.isBottomSheetMode {
                viewModel.didTapClose()
            }
        } content: {
            viewModel.paymentReviewPaymentInformationView(
                contentHeight: $bottomSheetHeight
            )
            .modifier(GiniBottomSheetModifier(
                contentHeight: bottomSheetHeight,
                allowsDismiss: viewModel.isBottomSheetMode,
                accessibilityAction: viewModel.didTapClose
            ))
        }
    }
    
    // MARK: - Landscape Layout
    
    @ViewBuilder
    private func landscapeLayout(geometry: GeometryProxy) -> some View {
        let carouselHeight = computedCarouselHeight(for: geometry, isLandscape: true)
        let sheetWidth = geometry.size.width * Constants.screenPercentage
        
        HStack(alignment: .center, spacing: Constants.landscapeContainerSpacing) {
            viewModel.paymentReviewPaymentInformationView(
                contentHeight: $bottomSheetHeight
            )
            .clipShape(
                .rect(
                    topLeadingRadius: Constants.paymentInformationContainerTopCornerRadius,
                    bottomLeadingRadius: Constants.paymentInformationContainerBottomCornerRadius,
                    bottomTrailingRadius: Constants.paymentInformationContainerBottomCornerRadius,
                    topTrailingRadius: Constants.paymentInformationContainerTopCornerRadius
                )
            )
            .frame(width: sheetWidth)
            .padding(.top, Constants.paymentInformationViewHorizontalPadding)
            
            documentPreviewContent(carouselHeight: carouselHeight)
                .frame(width: geometry.size.width - sheetWidth)
                .padding(.top, Constants.paymentInformationViewHorizontalPadding)
        }
    }
    
    // MARK: - Private Views
    
    @ViewBuilder
    private var loadingOverlay: some View {
        if viewModel.isLoading {
            Color.black.opacity(Constants.loadingOverlayOpacity)
                .ignoresSafeArea()
            ProgressView()
                .scaleEffect(Constants.loadingIndicatorScale)
                .tint(.white)
        }
    }
    
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
        
        GiniCarouselView(images: images,
                         imageAccessibilityLabel: viewModel.invoiceImageAccessibilityLabel)
            .frame(height: carouselHeight)
    }
    
    // MARK: - Private Methods
    
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
        static let bottomSheetOverlap: CGFloat = 20.0
        static let carouselDefaultHeight: CGFloat = 300.0
        static let screenPercentage: CGFloat = 0.55
        static let paymentInformationViewHorizontalPadding: CGFloat = 16.0
        static let documentPreviewStackSpacing: CGFloat = 16.0
        static let totalPaddings: CGFloat = 32.0
        static let pageIndicatorSpace: CGFloat = 30.0
        static let loadingOverlayOpacity: CGFloat = 0.4
        static let loadingIndicatorScale: CGFloat = 1.5
        static let layoutTransitionDuration: CGFloat = 0.35
        static let landscapeContainerSpacing: CGFloat = 8.0
        static let paymentInformationContainerTopCornerRadius: CGFloat = 12.0
        static let paymentInformationContainerBottomCornerRadius: CGFloat = 6.0
    }
}
