//
//  InvoiceDetailView.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 24.03.2022.
//

import SwiftUI

struct InvoiceDetailView: View {
    @StateObject var viewModel: InvoiceDetailViewModel

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
                        InvoiceDetailHeaderView(viewModel: viewModel.invoiceHeaderViewModel)

                        InvoiceDetailListView(viewModel: viewModel.invoiceDetailListViewModel)

                        if !viewModel.paid {
                            HStack {
                                Button(action: {
                                    viewModel.didSelectPay()
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
                        }

                        Rectangle().fill(Color.gray).frame(height: 1, alignment: .center).padding([.top, .bottom], 26)

                        ReinbursmentStatusView(reimbursmentStatus: viewModel.reimbursmentStatus, price: viewModel.price)

                        if viewModel.reimbursmentStatus != .sent {
                            HStack {
                                Button(action: {
                                    if viewModel.reimbursmentStatus == .reimbursed {
                                        viewModel.didSelectShowReimbursmentDoc()
                                    } else if viewModel.reimbursmentStatus == .notSent {
                                        viewModel.didSelectSubmitForClaim()
                                    }
                                }) {
                                    if viewModel.reimbursmentStatus == .notSent {
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
                                    } else if viewModel.reimbursmentStatus == .reimbursed {
                                        HStack {
                                            Spacer()
                                            Text("Show reimbursement document")
                                                .foregroundColor(Color.gray)
                                                .padding()
                                                .font(Style.appFont(style: .semiBold, 16))
                                            Spacer()
                                        }
                                        .background(Color.clear)
                                        .cornerRadius(16)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                    .stroke(Color.gray, lineWidth: 1)
                                                )
                                        .padding()
                                    }
                                }
                            }
                        }

                        DocumentsView(images: viewModel.images, selectedImage: viewModel.selectedImage)
                    }
                    .background(Color.white)
                    .cornerRadius(20)

                    InvoiceIconView(paid: viewModel.paid, iconName: viewModel.iconTitle)
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

//struct InvoiceDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        let invoice = Invoice(extractions: [], document: nil)
//        let vm = InvoiceDetailViewModel(invoiceDetail: NewInvoiceDetailViewModel(invoice: invoice))
//        InvoiceDetailView(viewModel: vm)
//    }
//}
