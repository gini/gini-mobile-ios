//
//  InvoiceDetailListView.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 23.03.2022.
//

import SwiftUI

struct InvoiceDetailListView: View {

    var viewModel: NewInvoiceDetailViewModel

    var body: some View {
        VStack {
            HStack {
                Text("Invoice details")
                    .font(Style.appFont(style: .semiBold, 14))
                Spacer()
                Text("Due in \(viewModel.numberOfDaysUntilDue) days")
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
                Text(viewModel.creationDate)
            }.padding([.top, .leading, .trailing])

            HStack {
                Text("Amount")
                    .font(Style.appFont(14))
                    .foregroundColor(.gray)
                Spacer()
                Text(viewModel.amount)
            }.padding([.top, .leading, .trailing])

            HStack {
                Text("Due date")
                    .font(Style.appFont(14))
                    .foregroundColor(.gray)
                Spacer()
                Text(viewModel.dueDate)
            }.padding([.top, .leading, .trailing])
        }
    }
}
