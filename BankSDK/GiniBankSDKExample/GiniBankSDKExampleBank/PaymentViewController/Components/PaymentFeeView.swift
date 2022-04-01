//
//  PaymentFeeView.swift
//  GinBankSDKExampleBank
//
//  Created by David Vizaknai on 01.04.2022.
//

import SwiftUI
import UIKit

struct PaymentFeeView: View {
    @Binding var invoicePrice: Double
    var tax: Double = 0

    var body: some View {
        HStack {
            VStack {
                HStack {
                    Text(NSLocalizedString("ginipaybank.paymentscreen.payment.recipient.title", comment: "recipient gets"))
                        .foregroundColor(.gray)

                    Spacer()

                    TextField(NSLocalizedString("ginipaybank.paymentscreen.payment.recipient.price", comment: "price"), text: .constant("€ \(String(format: "%.2f", invoicePrice))"))
                        .multilineTextAlignment(.trailing)
                }.padding(.top, 6)

                HStack {
                    Text(NSLocalizedString("ginipaybank.paymentscreen.payment.recipient.transfer.fee", comment: "transferfee"))
                        .foregroundColor(.gray)

                    Spacer()

                    Text("€ \(String(format: "%.2f", tax))")
                        .multilineTextAlignment(.trailing)
                }.padding([.top, .bottom], 4)

                HStack {
                    Text(NSLocalizedString("ginipaybank.paymentscreen.payment.recipient.transfer.total", comment: "total"))
                        .foregroundColor(.gray)

                    Spacer()

                    Text("€ \(String(format: "%.2f", invoicePrice + tax))")
                        .multilineTextAlignment(.trailing)
                }


            }.padding()
        }
        .background(.white)
        .cornerRadius(8)
    }
}

struct PaymentFeeView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentFeeView(invoicePrice: .constant(4))
    }
}
