//
//  InvoiceListView.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 25.03.2022.
//

import SwiftUI

enum FilterOptions: String {
    case all = "All"
    case open = "Open"
    case unpaid = "Unpaid"
    case reimbursed = "Reimbursed"
}
struct InvoiceListView: View {

    @ObservedObject var viewModel: InvoiceListViewModel
    var filterItems: [FilterOptions] = [.all, .open, .unpaid, .reimbursed]

    var body: some View {
        ScrollView {
            HStack(spacing: 16) {
                Text("Invoices")
                    .font(Style.appFont(style: .bold, 20))
                Spacer()
                Image("search_icon")
                Image("help_icon")
            }.padding([.top, .bottom])

            HStack {
                Spacer()
                HStack {
                    Image("check_icon")
                    Text("Your dental bill has been reimbursed")
                        .font(Style.appFont(style: .medium, 14))
                }.offset(x: -12, y: 0)
                Spacer()
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                    .opacity(0.5)
                    )

            ScrollView (.horizontal, showsIndicators: false) {
                ZStack(alignment: .bottom) {
                    Rectangle().fill(Color.gray).frame(height: 1, alignment: .center).padding([.leading, .trailing], -26)
                        .offset(x: 0, y: -1)

                    HStack(spacing: 16) {
                        ForEach(filterItems, id: \.self) { item in
                            InvoiceFilterItemView(text: item.rawValue, isSelected: item == viewModel.activeFilter)
                                .frame(width: 90, height: 30)
                                .onTapGesture {
                                    withAnimation {
                                        viewModel.updateFilter(item)
                                    }
                                }
                                .onAppear(perform: {
                                    viewModel.updateFilter(viewModel.activeFilter)
                                })
                        }
                    }
                }
            }
            .frame(height: 35)

            Section {
                ForEach(viewModel.thisMonthList, id: \.id) { item in
                        InvoiceItemCell(viewModel: item)
                        .onTapGesture {
                            viewModel.didSelectInvoice(with: item.id)
                        }
                }
            } header: {
                HStack {
                    Text("This month")
                        .font(Style.appFont(14))

                    Spacer()
                }.padding(.top)
            }

            Section {
                ForEach(viewModel.lastMonthList, id: \.id) { item in
                        InvoiceItemCell(viewModel: item)
                        .onTapGesture {
                            viewModel.didSelectInvoice(with: item.id)
                        }
                }
            } header: {
                HStack {
                    Text("January")
                        .font(Style.appFont(14))

                    Spacer()
                }.padding(.top)
            }
        }.padding()
    }
}

struct InvoiceListView_Previews: PreviewProvider {
    static var previews: some View {
        InvoiceListView(viewModel: InvoiceListViewModel(dataModel: InvoiceListDataModel()))
    }
}
