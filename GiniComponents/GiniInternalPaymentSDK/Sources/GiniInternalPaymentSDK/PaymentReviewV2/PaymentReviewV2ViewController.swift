//
//  PaymentReviewV2ViewController.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//


import GiniHealthAPILibrary
import UIKit
import SwiftUI

public class PaymentReviewV2ViewController: UIHostingController<PaymentReviewContentView> {
    
    private let selectedPaymentProvider: PaymentProvider
    private var isInfoBarHidden = true
    
    public init(viewModel: PaymentReviewModel, selectedPaymentProvider: PaymentProvider) {
        let observableModel = PaymentReviewObservableModel(model: viewModel)
        
        self.selectedPaymentProvider = selectedPaymentProvider
        self.isInfoBarHidden = viewModel.configuration.isInfoBarHidden
        
        super.init(rootView: PaymentReviewContentView(viewModel: observableModel))
    }
    
    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
