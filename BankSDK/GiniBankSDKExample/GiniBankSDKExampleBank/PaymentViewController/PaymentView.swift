//
//  PaymentView.swift
//  GinBankSDKExampleBank
//
//  Created by David Vizaknai on 01.04.2022.
//

import SwiftUI
import UIKit

struct PaymentView: View {
    @ObservedObject var viewModel: PaymentViewModel
    @ObservedObject private var kGuardian = KeyboardGuardian(textFieldCount: 1)

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text(NSLocalizedString("ginipaybank.paymentscreen.title", comment: "Transfer"))
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.top, 40)
                .padding()

                HStack {
                    Text(NSLocalizedString("ginipaybank.paymentscreen.myaccount.header", comment: "myaccount"))
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                    Spacer()
                }
                .padding([.leading, .trailing])
                .padding(.top, 20)

                MyAccountView()
                    .frame(height: 78)
                    .padding([.leading, .trailing])

                HStack {
                    Text(NSLocalizedString("ginipaybank.paymentscreen.beneficiary.header", comment: "beneficiary"))
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                    Spacer()
                }
                .padding([.leading, .trailing])
                .padding(.top, 20)

                BeneficiaryBankDetailView(paymentTitle: $viewModel.invoiceTitle, iban: $viewModel.iban)
                    .padding([.leading, .trailing])

                ReferenceView(referenceString: $viewModel.invoiceReference)
                    .padding([.leading, .trailing])

                PaymentFeeView(invoicePrice: $viewModel.invoicePrice)
                    .padding([.leading, .trailing])

                EstimatedView()
                    .padding([.leading, .trailing])

                Button(action: {
                    viewModel.resolvePaymentRequest()
                }) {
                    HStack {
                        Spacer()
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text(NSLocalizedString("ginipaybank.paymentscreen.pay.button.title", comment: "payment button"))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .font(.system(size: 16))
                        }
                        Spacer()
                    }
                    .background(.black)
                    .cornerRadius(16)
                    .padding()
                }

                Spacer()
            }
            .background(Style.backgroundColor)
            .onAppear {
                viewModel.fetchPaymentRequest()
            }
            .offset(y: -kGuardian.slide/4).animation(.easeInOut, value: 0.9)
            .onAppear { self.kGuardian.addObserver() }
            .onDisappear { self.kGuardian.removeObserver() }
        }.ignoresSafeArea()
    }
}

struct Style {
    static let backgroundColor = Color(red: 0.898, green: 0.898, blue: 0.898)
    static let confirmationTextColor = Color(red: 0.507, green: 0.683, blue: 0)
}
