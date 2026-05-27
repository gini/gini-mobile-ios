//
//  PaymentReviewContentView.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI

public struct PaymentReviewContentView: View {
    
    @ObservedObject private var viewModel: PaymentReviewObservableModel
    @State private var hasAppeared = false
    @State private var showBottomSheet = true
    @State private var bottomSheetHeight = Constants.bottomSheetDefaultHeight
    
    @Environment(\.accessibilityVoiceOverEnabled) private var isVoiceOverEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.giniLayout) private var giniLayout
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    /**
     The init method is internal to prevent users from creating instances of this view directly
     outside of GiniInternalPaymentSDK.
     */
    init(viewModel: PaymentReviewObservableModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        GeometryReader { geometry in
            if giniLayout.isLandscape && !viewModel.isBottomSheetMode {
                landscapeLayout(geometry: geometry)
                    .transition(.opacity)
            } else {
                portraitLayout(geometry: geometry)
                    .transition(.opacity)
            }
        }
        .ignoresSafeArea(.keyboard)
        .animation(.easeInOut(duration: Constants.layoutTransitionDuration), value: giniLayout.isLandscape)
        .onChange(of: giniLayout.isLandscape) { landscape in
            // Belt-and-suspenders for iOS 17+: the sheet is already dismissed imperatively
            // from viewWillTransition on iOS 16, but on iOS 17 we keep this path as well.
            if landscape && !viewModel.isBottomSheetMode && showBottomSheet {
                viewModel.isDismissingForRotation = true
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
        // Full-width Done toolbar rendered above the keyboard in landscape (documentCollection)
        // mode. `ToolbarItemGroup(placement: .keyboard)` is the correct way to place content
        // above the keyboard — `safeAreaInset` on the HStack would place it behind the keyboard
        // because the outer container suppresses the keyboard safe area with `ignoresSafeArea`.
        // The inner form view's narrow Done bar is suppressed in landscape so only this
        // full-width version appears.
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                if giniLayout.isLandscape && !viewModel.isBottomSheetMode && viewModel.isAmountFieldFocused {
                    Spacer()
                    Button(viewModel.keyboardDoneButtonTitle) {
                        viewModel.trackKeyboardDismissed()
                        viewModel.validateAmountFieldOnKeyboardDismiss()
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                        to: nil,
                                                        from: nil,
                                                        for: nil)
                    }
                    .padding(.trailing, Constants.doneButtonHorizontalPadding)
                }
            }
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
            // Delay so the layout crossfade finishes before the sheet appears.
            // disablesAnimations suppresses the sheet's default slide-up animation
            // so it appears instantly at its resting position, matching the
            // no-animation dismiss applied when rotating to landscape.
            if !viewModel.isBottomSheetMode && !showBottomSheet {
                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.layoutTransitionDuration) {
                    // Re-check conditions in case the mode changed during the delay.
                    if !viewModel.isBottomSheetMode && !showBottomSheet {
                        var transaction = Transaction()
                        transaction.disablesAnimations = true
                        withTransaction(transaction) {
                            showBottomSheet = true
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showBottomSheet) {
            defer { viewModel.isDismissingForRotation = false }
            if !viewModel.isDismissingForRotation && (viewModel.isBottomSheetMode || isVoiceOverEnabled) {
                viewModel.didTapClose()
            }
        } content: {
            viewModel.paymentReviewPaymentInformationView(
                contentHeight: $bottomSheetHeight
            )
            .padding(.top, verticalSizeClass == .compact && !reduceMotion
                ? Constants.grabberBottomPadding
                : 0)
            .overlay(alignment: .top) {
                if verticalSizeClass == .compact && !reduceMotion {
                    landscapeGrabberCapsule
                }
            }
            .modifier(GiniBottomSheetModifier(contentHeight: bottomSheetHeight,
                                              allowsDismiss: viewModel.isBottomSheetMode,
                                              accessibilityAction: viewModel.didTapClose))
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
    
    // Replacement for the system drag indicator, which is hidden by .fullScreenCover adaptation in landscape.
    // Wrapping in Button ensures VoiceOver announces it as an interactive element and double-tap dismisses.
    private var landscapeGrabberCapsule: some View {
        Button(action: viewModel.didTapClose) {
            Capsule()
                .fill(Color(UIColor.tertiaryLabel))
                .frame(width: Constants.grabberWidth, height: Constants.grabberHeight)
                .frame(width: Constants.grabberHitAreaWidth, height: Constants.grabberHitAreaHeight)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .padding(.top, Constants.grabberTopPadding)
        .accessibilityLabel(viewModel.model.strings.sheetGrabberAccessibilityLabel)
        .accessibilityHint(viewModel.model.strings.sheetGrabberAccessibilityHint)
    }

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
            calculatedHeight = geometry.size.height - effectiveBottomSheetHeight
            + Constants.bottomSheetOverlap - Constants.totalPaddings
            - Constants.pageIndicatorSpace
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
        static let doneButtonHorizontalPadding: CGFloat = 16.0
        static let grabberWidth: CGFloat = 36.0
        static let grabberHeight: CGFloat = 5.0
        static let grabberHitAreaWidth: CGFloat = 60.0
        static let grabberHitAreaHeight: CGFloat = 44.0
        static let grabberTopPadding: CGFloat = 8.0
        static let grabberBottomPadding: CGFloat = 24.0
    }
}
