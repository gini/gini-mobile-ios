//
//  PaymentReviewPaymentInformationView.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI
import GiniHealthAPILibrary
import GiniUtilites

struct PaymentReviewPaymentInformationView: View {
    
    let onBankSelectionTapped: () -> Void
    
    @ObservedObject private var viewModel: PaymentReviewPaymentInformationObservableModel
    
    @State private var recipient: String = ""
    @State private var iban: String = ""
    @State private var amount: String = ""
    @State private var paymentPurpose: String = ""
    
    @State private var showBanner: Bool = true
    
    init(viewModel: PaymentReviewContainerViewModel,
         onBankSelectionTapped: @escaping () -> Void) {
        let observableModel = PaymentReviewPaymentInformationObservableModel(model: viewModel)
        self.viewModel = observableModel
        self.onBankSelectionTapped = onBankSelectionTapped
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
                let textFieldConfiguration = viewModel.model.defaultStyleInputFieldConfiguration
                
                TextField("", text: $recipient)
                    .textFieldStyle(GiniTextFieldStyle(title: "Recipient",
                                                       configuration: textFieldConfiguration))
                
                HStack(spacing: 8.0) {
                    TextField("", text: $iban)
                        .textFieldStyle(GiniTextFieldStyle(title: "IBAN",
                                                           configuration: textFieldConfiguration))
                    
                    TextField("", text: $amount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(GiniTextFieldStyle(title: "Amount",
                                                           configuration: textFieldConfiguration))
                }
                
                TextField("", text: $paymentPurpose)
                    .textFieldStyle(GiniTextFieldStyle(title: "Payment purpose",
                                                       configuration: textFieldConfiguration))
                
                if #available(iOS 15.0, *) {
                    HStack(spacing: 8.0) {
                        Button(action: {
                            onBankSelectionTapped()
                        }) {
                            HStack(spacing: 12.0) {
                                if let uiImage = UIImage(data: viewModel.selectedPaymentProvider.iconData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 36, height: 36)
                                        .cornerRadius(6.0)
                                }
                                
                                if let chevronImage = viewModel.model.configuration.chevronDownIcon {
                                    Image(uiImage: chevronImage)
                                        .resizable()
                                        .renderingMode(.template)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 24, height: 24)
                                        .tint(Color(viewModel.model.configuration.chevronDownIconColor!))
                                }
                            }
                            .frame(width: 96.0, height: 36.0)
                            .padding(.vertical, 10.0)
                        }
                        .background(Color(viewModel.model.secondaryButtonConfiguration.backgroundColor))
                        .cornerRadius(viewModel.model.secondaryButtonConfiguration.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: viewModel.model.secondaryButtonConfiguration.cornerRadius)
                                .stroke(Color(viewModel.model.secondaryButtonConfiguration.borderColor),
                                        lineWidth: viewModel.model.secondaryButtonConfiguration.borderWidth)
                        )
                        
                        Button(action: {}) {
                            Text(viewModel.model.strings.payInvoiceLabelText)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .foregroundColor(Color(viewModel.model.selectedPaymentProvider.colors.text.toColor()!))
                        .background(Color(viewModel.selectedPaymentProvider.colors.background.toColor()!))
                        .cornerRadius(viewModel.model.primaryButtonConfiguration.cornerRadius)
                        .font(Font(viewModel.model.primaryButtonConfiguration.titleFont))
                        .frame(height: 56.0)
                    }
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
