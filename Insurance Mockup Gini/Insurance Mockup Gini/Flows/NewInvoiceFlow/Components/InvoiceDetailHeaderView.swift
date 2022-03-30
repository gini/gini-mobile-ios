//
//  InvoiceDetailHeaderView.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 29.03.2022.
//

import SwiftUI

class InvoiceDetailHeaderViewModel: ObservableObject {
    var companyTitle: String
    var description: String
    var ammount: String
    var adress: String
    var paid: Bool

    init(invoice: Invoice) {
        companyTitle = invoice.invoiceTitle
        description = invoice.description
        ammount = "\(invoice.price) \(invoice.currency)"
        adress = invoice.adress
        paid = invoice.paid
    }
}

struct InvoiceDetailHeaderView: View {
    @ObservedObject var viewModel: InvoiceDetailHeaderViewModel
    var body: some View {
        VStack {
            Text(viewModel.companyTitle)
                .font(Style.appFont(style: .semiBold, 16))
                .padding(.top, 60)

            Text(viewModel.description)
                .font(Style.appFont(14))
                .foregroundColor(.gray)
                .padding(4)

            Text(viewModel.ammount)
                .font(Style.appFont(style: .semiBold, 32))
                .foregroundColor(viewModel.paid ? Color.green : Style.NewInvoice.accentBlue)
                .padding(.top)

            Text(viewModel.adress)
                .font(Style.appFont(14))
                .foregroundColor(.gray)
                .padding(.top, 2)
        }
    }
}
