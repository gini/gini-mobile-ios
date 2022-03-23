//
//  InvoiceDetailListView.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 23.03.2022.
//

import SwiftUI

struct InvoiceDetailListView: View {
    var body: some View {
        VStack {
            HStack {
                Text("Invoice details")
                    .font(Style.appFont(style: .semiBold, 14))
                Spacer()
                Text("Due in 2 days")
                    .font(Style.appFont(style: .medium, 14))
                    .foregroundColor(.gray)
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.gray, lineWidth: 1)
                            .opacity(0.5)
                            )
            }.padding()

            HStack {
                Text("Date of Document")
                    .font(Style.appFont(14))
                    .foregroundColor(.gray)
                Spacer()
                Text("March 11, 2022")
            }.padding([.top, .leading, .trailing])

            HStack {
                Text("Amount")
                    .font(Style.appFont(14))
                    .foregroundColor(.gray)
                Spacer()
                Text("€334.59")
            }.padding([.top, .leading, .trailing])

            HStack {
                Text("Due date")
                    .font(Style.appFont(14))
                    .foregroundColor(.gray)
                Spacer()
                Text("March 19, 2022")
            }.padding([.top, .leading, .trailing])
        }
    }
}
