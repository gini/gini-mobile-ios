//
//  InvoiceDetailListView.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 23.03.2022.
//

import SwiftUI

class InvoiceDetailListViewModel {
    var creationDate: Date
    var dueDate: Date
    var amountWithCurrency: String
    var paid: Bool
    var numberOfDaysUntilDue: Int

    init(invoice: Invoice) {
        self.creationDate = invoice.creationDate
        self.dueDate = invoice.dueDate
        self.amountWithCurrency = "\(invoice.price) \(invoice.currency)"
        self.paid = invoice.paid
        self.numberOfDaysUntilDue = Int((invoice.dueDate - Date()) / (24*60*60))
    }
}

struct InvoiceDetailListView: View {
    var viewModel: InvoiceDetailListViewModel

    var body: some View {
        VStack {
            HStack {
                Text("Invoice details")
                    .font(Style.appFont(style: .semiBold, 14))
                Spacer()
                PaymentInfoView(paid: viewModel.paid, dueDaysCont: viewModel.numberOfDaysUntilDue)
            }.padding()

            HStack {
                Text("Date of Document")
                    .font(Style.appFont(14))
                    .foregroundColor(.gray)
                Spacer()
                Text(viewModel.creationDate.getFormattedDate(format: "dd MMMM, yyyy"))
            }.padding([.top, .leading, .trailing])

            HStack {
                Text("Amount")
                    .font(Style.appFont(14))
                    .foregroundColor(.gray)
                Spacer()
                Text(viewModel.amountWithCurrency)
            }.padding([.top, .leading, .trailing])

            HStack {
                Text("Due date")
                    .font(Style.appFont(14))
                    .foregroundColor(.gray)
                Spacer()
                Text(viewModel.dueDate.getFormattedDate(format: "dd MMMM, yyyy"))
            }.padding([.top, .leading, .trailing])
        }
    }
}
