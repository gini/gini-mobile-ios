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
    
    /// The init method is internal to prevent users from creating instances of this view directly
    /// outside of GiniInternalPaymentSDK.
    init(viewModel: PaymentReviewObservableModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 16) {
                    if viewModel.isImagesLoading {
                        ProgressView()
                            .frame(height: 400)
                    } else if !viewModel.cellViewModels.isEmpty {
                        let images = viewModel.cellViewModels.compactMap { $0.preview }
                        GiniCarouselView(images: images)
                            .frame(height: 420)
                    }
                }
                .padding()
                .padding(.bottom, 420)
            }
            .onAppear {
                guard !hasAppeared else { return }
                hasAppeared = true
                
                Task {
                    await viewModel.fetchImages()
                }
            }
        }
        .sheet(isPresented: $showBottomSheet) {
            
        } content: {
            PaymentReviewPaymentInformationView(viewModel: viewModel.model.paymentReviewContainerViewModel(),
                                                onBankSelectionTapped: {
                viewModel.model.openBankSelectionBottomSheet()
            },
                                                onPayTapped: { paymentInfo in
                viewModel.didTapPay(paymentInfo)
            })
            .modifier(GiniBottomSheetModifier())
        }
    }
}
