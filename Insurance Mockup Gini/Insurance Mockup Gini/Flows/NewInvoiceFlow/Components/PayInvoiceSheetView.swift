//
//  PayInvoiceSheetView.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 24.03.2022.
//

import SwiftUI

struct PayInvoiceSheetView: View {
    @ObservedObject var viewModel: NewInvoiceDetailViewModel

    var body: some View {
        VStack {
            HStack {
                Text("Pay invoice")
                    .font(Style.appFont(style: .medium))
                Spacer()
                Button {
                    viewModel.paySheetPosition = .hidden
                } label: {
                    Image("exit_icon")
                }
            }.padding([.leading, .trailing])

            VStack(alignment: .leading) {
                Text("Recipient")
                    .font(Style.appFont(12))
                    .foregroundColor(Style.PaymentSheet.grayTextColor)
                    .padding([.top,], 12)
                    .padding([.leading,], 8)
                TextField("Recipient", text: $viewModel.companyName)
                    .padding(.top, -4)
                    .padding([.bottom, .leading], 8)
            }
            .frame(height: 58)
            .background(Style.PaymentSheet.textFieldColor)
            .cornerRadius(8)
            .padding([.leading, .trailing])

            VStack(alignment: .leading) {
                Text("IBAN")
                    .font(Style.appFont(12))
                    .foregroundColor(Style.PaymentSheet.grayTextColor)
                    .padding([.top,], 12)
                    .padding([.leading,], 8)
                TextField("IBAN", text: $viewModel.iban)
                    .padding(.top, -4)
                    .padding([.bottom, .leading], 8)
            }
            .frame(height: 58)
            .background(Style.PaymentSheet.textFieldColor)
            .cornerRadius(8)
            .padding([.leading, .trailing, .top])

            HStack {
                Text("Amount")
                    .padding(8)
                Spacer()
                TextField("Amount", text: $viewModel.amount)
                    .multilineTextAlignment(.trailing)
                    .padding(8)
            }
            .frame(height: 58)
            .background(Style.PaymentSheet.textFieldColor)
            .cornerRadius(8)
            .padding([.leading, .trailing, .top])

            VStack(alignment: .leading) {
                Text("Reference")
                    .font(Style.appFont(12))
                    .foregroundColor(Style.PaymentSheet.grayTextColor)
                    .padding([.top,], 12)
                    .padding([.leading,], 8)
                TextField("Reference", text: $viewModel.adress)
                    .padding(.top, -4)
                    .padding([.bottom, .leading], 8)
            }
            .frame(height: 58)
            .background(Style.PaymentSheet.textFieldColor)
            .cornerRadius(8)
            .padding([.leading, .trailing, .top])

            VStack(alignment: .leading) {
                HStack {
                    Image("pay_save_icon")
                        .padding(8)
                    Text("Test Bank")
                    Spacer()
                }
            }
            .frame(height: 58)
            .background(Style.PaymentSheet.textFieldColor)
            .cornerRadius(8)
            .padding([.leading, .trailing, .top])

            HStack {
                Button(action: {
                    print("continue")
                }) {
                    HStack {
                        Spacer()
                        Text("Continue")
                            .foregroundColor(.white)
                            .padding()
                            .font(Style.appFont(style: .semiBold, 16))
                        Spacer()
                    }
                    .background(Style.NewInvoice.accentBlue)
                    .cornerRadius(16)
                    .padding()
                }
            }
        }
    }
}
