//
//  InvoiceItemCell.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 25.03.2022.
//

import SwiftUI

struct InvoiceItemCell: View {
    var viewModel: InvoiceItemCellViewModel
    var body: some View {
        HStack {
            Image(viewModel.iconName)

            VStack(alignment: .leading) {
                Text(viewModel.title)
                HStack {
                    PaymentInfoView(paid: viewModel.paid)
                    ReinbursmentInfoView(reimbursmentState: viewModel.reimbursed)
                }
            }

            Spacer()

            Text(viewModel.price)
        }
    }
}

struct PaymentInfoView: View {
    var paid: Bool
    var body: some View {
        if paid {
            HStack {
                Image("check_icon")
                    .resizable()
                    .frame(width: 14, height: 14)
                    .padding(.leading, 4)
                Text("Paid")
                    .font(Style.appFont(style: .medium, 14))
                    .foregroundColor(.green)
                    .padding(.trailing, 4)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.green, lineWidth: 1)
                    )
        } else {
            Text("Due in 2 days")
                .font(Style.appFont(style: .medium, 14))
                .foregroundColor(.gray)
                .padding([.leading, .trailing], 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.gray, lineWidth: 1)
                        .opacity(0.5)
                        )
        }

    }
}

struct ReinbursmentInfoView: View {
    var reimbursmentState: ReimbursmentState
    var body: some View {
        switch reimbursmentState {
        case .notSent:
            Text(reimbursmentState.rawValue)
                .font(Style.appFont(style: .medium, 14))
                .foregroundColor(.gray)
                .padding([.leading, .trailing], 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.gray, lineWidth: 1)
                        .opacity(0.5)
                        )
        case .sent:
            Text(reimbursmentState.rawValue)
                .font(Style.appFont(style: .medium, 14))
                .foregroundColor(.gray)
                .padding([.leading, .trailing], 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.gray, lineWidth: 1)
                        .opacity(0.5)
                        )
        case .reimbursed:
            HStack {
                Image("check_icon")
                    .resizable()
                    .frame(width: 14, height: 14)
                    .padding(.leading, 4)
                Text(reimbursmentState.rawValue)
                    .font(Style.appFont(style: .medium, 14))
                    .foregroundColor(.green)
                    .padding(.trailing, 4)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.green, lineWidth: 1)
                    )
        }
    }
}


struct InvoiceItemCell_Previews: PreviewProvider {
    static var previews: some View {
        let invoice = Invoice(extractions: [], document: nil)
        InvoiceItemCell(viewModel: InvoiceItemCellViewModel(invoice: invoice))
    }
}
