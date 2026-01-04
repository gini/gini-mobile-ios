//
//  PaymentReviewPaymentInformationView.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI

struct PaymentReviewPaymentInformationView: View {
    
    @State private var recipient: String = ""
    @State private var iban: String = ""
    @State private var amount: String = ""
    @State private var referenceNumber: String = ""
    
    @State private var showBanner: Bool = true
    
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
                
                TextField("", text: $referenceNumber)
                    .textFieldStyle(GiniTextFieldStyle(title: "Reference number"))
                
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
        }
    }
}

#Preview {
    PaymentReviewPaymentInformationView()
}
