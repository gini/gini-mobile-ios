//
//  InvoiceDetailView.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 24.03.2022.
//

import SwiftUI

struct InvoiceDetailView: View {
    var viewModel: InvoiceDetailViewModel

    var body: some View {
        VStack {
            ScrollView {
                HStack {
                    Button {
                        viewModel.didTapBack()
                    } label: {
                        Image("back_icon")
                    }
                    Spacer()
                }.padding()

                ZStack(alignment: .top) {
                    VStack {
                        InvoiceDetailHeaderView(viewModel: viewModel.invoiceDetailViewModel)

                        InvoiceDetailListView(viewModel: viewModel.invoiceDetailViewModel)

                        HStack {
                            Button(action: {
                                print("Pay")
                            }) {
                                HStack {
                                    Spacer()
                                    Text("Pay invoice")
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

                        Rectangle().fill(Color.gray).frame(height: 1, alignment: .center).padding([.top, .bottom], 26)

                        ReinbursmentStatusView(viewModel: viewModel.invoiceDetailViewModel)

                        HStack {
                            Button(action: {
                                print("Pay")
                            }) {
                                HStack {
                                    Spacer()
                                    Text("Submit for claim")
                                        .foregroundColor(Style.NewInvoice.accentBlue)
                                        .padding()
                                        .font(Style.appFont(style: .semiBold, 16))
                                    Spacer()
                                }
                                .background(Style.NewInvoice.secondaryBlue)
                                .cornerRadius(16)
                                .padding()
                            }
                        }

                        DocumentsView()
                    }
                    .background(Color.white)
                    .cornerRadius(20)

                    Image(viewModel.invoiceDetailViewModel.iconTitle)
                        .frame(width: 58, height: 58)
                        .offset(x: 0, y: -29)
                }.padding(.top, 40)
            }
            .padding(.top, 40)
        }
        .background(Style.NewInvoice.backgroundColor)
        .ignoresSafeArea()
    }
}

struct InvoiceDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let invoice = Invoice(extractions: [], document: nil)
        let vm = InvoiceDetailViewModel(invoiceDetail: NewInvoiceDetailViewModel(invoice: invoice))
        InvoiceDetailView(viewModel: vm)
    }
}
