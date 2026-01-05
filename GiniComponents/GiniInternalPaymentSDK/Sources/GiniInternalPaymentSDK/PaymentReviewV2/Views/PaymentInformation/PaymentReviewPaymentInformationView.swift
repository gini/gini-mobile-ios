//
//  PaymentReviewPaymentInformationView.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI
import GiniHealthAPILibrary
import GiniUtilites

struct PaymentReviewPaymentInformationView: View {
    
    @ObservedObject private var viewModel: PaymentReviewPaymentInformationObservableModel
    
    @State private var recipient: String = ""
    @State private var iban: String = ""
    @State private var amount: String = ""
    @State private var paymentPurpose: String = ""
    
    @State private var showBanner: Bool = true
    
    init(viewModel: PaymentReviewContainerViewModel) {
        let observableModel = PaymentReviewPaymentInformationObservableModel(model: viewModel)
        self.viewModel = observableModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if showBanner {
                HStack {
                    Text("Please check the pre-filled data.")
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(red: 0.71, green: 0.77, blue: 0.29))
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            VStack(spacing: 8.0) {
                TextField("", text: $recipient)
                    .textFieldStyle(GiniTextFieldStyle(title: "Recipient"))
                
                HStack(spacing: 8.0) {
                    TextField("", text: $iban)
                        .textFieldStyle(GiniTextFieldStyle(title: "IBAN"))
                    
                    TextField("", text: $amount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(GiniTextFieldStyle(title: "Amount"))
                }
                
                TextField("", text: $paymentPurpose)
                    .textFieldStyle(GiniTextFieldStyle(title: "Payment purpose"))
                
                if #available(iOS 15.0, *) {
                    Button(action: {}) {
                        Text("To the banking app")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .foregroundColor(.white)
                    .background(.red)
                    .cornerRadius(12.0)
                    .frame(height: 56.0)
                } else {
                    // Fallback on earlier versions
                }
            }
            .padding(.horizontal, 16.0)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showBanner = false
                }
            }
            
            populateFields()
        }
    }
    
    // MARK: Private methods
    
    private func populateFields() {
        if !viewModel.extractions.isEmpty {
            populateFieldsWithExtractions(viewModel.extractions)
        } else if let paymentInfo = viewModel.model.paymentInfo {
            populateFieldsWithPaymentInfo(paymentInfo)
        }
    }
    
    private func populateFieldsWithExtractions(_ extractions: [Extraction]) {
        recipient = extractions.first(where: {$0.name == "payment_recipient"})?.value ?? ""
        iban = extractions.first(where: {$0.name == "iban"})?.value.uppercased() ?? ""
        paymentPurpose = extractions.first(where: {$0.name == "payment_purpose"})?.value ?? ""
        
        if let amountString = viewModel.extractions.first(where: {$0.name == "amount_to_pay"})?.value,
            let amountToPay = Price(extractionString: amountString) {
            let amountToPayText = amountToPay.string
            amount = amountToPayText ?? ""
        }
    }
    
    private func populateFieldsWithPaymentInfo(_ paymentInfo: PaymentInfo) {
        recipient = paymentInfo.recipient
        iban = paymentInfo.iban
        paymentPurpose = paymentInfo.purpose
        
        if let amountToPay = Price(extractionString: paymentInfo.amount) {
            let amountToPayText = amountToPay.string
            amount = amountToPayText ?? ""
        }
    }
}
