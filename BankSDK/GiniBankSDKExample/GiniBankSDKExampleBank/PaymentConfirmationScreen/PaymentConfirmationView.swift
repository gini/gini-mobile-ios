//
//  PaymentConfirmationView.swift
//  GinBankSDKExampleBank
//
//  Created by David Vizaknai on 01.04.2022.
//

import UIKit
import SwiftUI

struct PaymentConfirmationView: View {
    @ObservedObject var viewModel: PaymentConfirmationViewModel
    var body: some View {
        VStack {
            HStack {
                Text(NSLocalizedString("ginipaybank.paymentscreen.title", comment: "transfer"))
                    .font(.system(size: 24))
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.top, 40)
            .padding()

            ConfirmationHeaderView(invoiceTitle: viewModel.invoiceTitle)
                .padding()

            PaymentConfirmationStatusView(date: viewModel.date, price: viewModel.price, id: viewModel.id)
                .padding()

            Button(action: {
                viewModel.openPaymentRequesterApp()
            }) {
                HStack {
                    Spacer()
                    Text(NSLocalizedString("ginipaybank.paymentconfirmationscreen.button.title", comment: "back to app"))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .font(.system(size: 16))
                    Spacer()
                }
                .background(.black)
                .cornerRadius(16)
                .padding()
            }

            Spacer()
        }
        .ignoresSafeArea()
        .background(Style.backgroundColor)
        .onAppear {
            viewModel.fetchPayment()
        }
    }
}
