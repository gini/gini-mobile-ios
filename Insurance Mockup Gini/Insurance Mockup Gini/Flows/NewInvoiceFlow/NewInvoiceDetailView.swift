//
//  NewInvoiceDetailView.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 23.03.2022.
//

import Combine
import SwiftUI

struct NewInvoiceDetailView: View {

    @State private var isPresented: Bool = false
    var viewModel: NewInvoiceDetailViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                HStack {
                    Text("New invoice")
                        .font(Style.appFont(style: .bold, 20))
                    Spacer()
                    Button {
                        viewModel.didTapCancel()
                    } label: {
                        Image("exit_icon")
                    }
                }.padding()

                ZStack(alignment: .top) {
                    VStack {
                        Text(viewModel.companyName)
                            .font(Style.appFont(style: .semiBold, 16))
                            .padding(.top, 30)

                        Text("Prophylaxe")
                            .font(Style.appFont(14))
                            .foregroundColor(.gray)
                            .padding(4)

                        Text(viewModel.amount)
                            .font(Style.appFont(style: .semiBold, 32))
                            .foregroundColor(Style.NewInvoice.accentBlue)
                            .padding(.top)

                        Text("Musterstrasse 11, 1234 Musterstadt")
                            .font(Style.appFont(14))
                            .foregroundColor(.gray)
                            .padding(.top, 2)

                        InvoiceDetailListView(viewModel: viewModel)

                        Rectangle().fill(Color.gray).frame(height: 1, alignment: .center).padding([.top, .bottom], 26)

                        HStack {
                            Text("Reimbursement")
                                .font(Style.appFont(style: .semiBold, 14))
                            Spacer()
                            Text("Not sent")
                                .padding(2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.gray, lineWidth: 1)
                                        .opacity(0.5)
                                        )

                        }.padding([.top, .leading, .trailing])

                        HStack {
                            Text("Date of reimbursement")
                                .font(Style.appFont(14))
                                .foregroundColor(.gray)
                            Spacer()
                            Text("-")
                                .foregroundColor(.gray)
                        }.padding([.top, .leading, .trailing])

                        ZStack(alignment: .top) {
                            VStack {
                                HStack{
                                    Text("Documents")
                                    Spacer()
                                }.padding()
                                Spacer()
                            }
                            .background(Style.NewInvoice.grayBackgroundColor)
                            .frame(height: 200)

                            HStack {
                                let max = UIScreen.main.bounds.width/18
                                ForEach(1..<Int(max+2)) { i in
                                    Triangle()
                                        .fill(.white)
                                        .frame(width: 18, height: 18)
                                        .padding([.leading, .trailing], -4)
                                }
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(20)

                    Image("icon_dentist")
                        .frame(width: 58, height: 58)
                        .offset(x: 0, y: -29)
                }.padding(.top, 40)
            }
            .padding(.top, 40)

            Button(action: { self.isPresented.toggle() }) {
                HStack {
                    Spacer()
                    Text("Continue")
                        .foregroundColor(.white)
                        .padding()
                        .font(Style.appFont(style: .semiBold, 16))
                    Spacer()
                }
                .background(Style.NewInvoice.accentBlue)
                .cornerRadius(16)
                .padding()
            }.sheet(isPresented: $isPresented, content: {
                ButtonsSheetView()
            })
            .padding(.bottom, 40)

        }
        .background(Style.NewInvoice.backgroundColor)
        .ignoresSafeArea()
    }
}

struct NewInvoiceDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NewInvoiceDetailView(viewModel: NewInvoiceDetailViewModel(results: [], document: nil))
    }
}
