//
//  PaymentConfirmationStatusView.swift
//  GinBankSDKExampleBank
//
//  Created by David Vizaknai on 01.04.2022.
//

import SwiftUI
import UIKit

struct PaymentConfirmationStatusView: View {
    var date: Date
    var price: String
    var id: String

    var body: some View {
        VStack {
            HStack {
                Text(NSLocalizedString("ginipaybank.paymentconfirmationscreen.payment.method", comment: "method"))
                    .foregroundColor(.gray)

                Spacer()

                Text(NSLocalizedString("ginipaybank.paymentconfirmationscreen.payment.card", comment: "card"))
            }.padding(.bottom, 4)

            HStack {
                Text(NSLocalizedString("ginipaybank.paymentconfirmationscreen.status", comment: "status"))
                    .foregroundColor(.gray)

                Spacer()

                Text(NSLocalizedString("ginipaybank.paymentconfirmationscreen.status.completed", comment: "completed"))
                    .foregroundColor(Style.confirmationTextColor)
            }
            .padding(.bottom, 4)

            HStack {
                Text(NSLocalizedString("ginipaybank.paymentconfirmationscreen.time", comment: "time"))
                    .foregroundColor(.gray)

                Spacer()

                Text(date.getFormattedDate(format: "h:mm a"))
            }
            .padding(.bottom, 4)

            HStack {
                Text(NSLocalizedString("ginipaybank.paymentconfirmationscreen.date", comment: "date"))
                    .foregroundColor(.gray)

                Spacer()

                Text(date.getFormattedDate(format: "dd MMMM, yyyy"))
            }
            .padding(.bottom, 4)

            HStack {
                Text(NSLocalizedString("ginipaybank.paymentconfirmationscreen.transactionid", comment: "transactionid"))
                    .foregroundColor(.gray)

                Spacer()

                Text(id)
            }
            .padding(.bottom, 4)

            Rectangle()
                .frame(height: 2, alignment: .center)
                .foregroundColor(.gray)
                .padding([.top, .bottom])

            HStack {
                Text(NSLocalizedString("ginipaybank.paymentconfirmationscreen.amount", comment: "amount"))
                    .foregroundColor(.gray)

                Spacer()

                Text("€\(price)")
            }
            .padding(.bottom, 4)
        }
        .padding()
        .background(.white)
        .cornerRadius(8)
    }
}

//struct PaymentConfirmationStatusView_Previews: PreviewProvider {
//    static var previews: some View {
//        VStack {
//            PaymentConfirmationStatusView()
//                .padding()
//        }.background(.gray)
//    }
//}
