//
//  NewInvoiceDetailView.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 23.03.2022.
//

import Combine
import SwiftUI
import BottomSheet

struct NewInvoiceDetailView: View {

    @State private var isPresented: Bool = false
    @ObservedObject var viewModel: NewInvoiceDetailViewModel

    @ObservedObject private var keyboard = KeyboardResponder()
    @State private var textFieldInput: String = ""

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
                        InvoiceDetailHeaderView(viewModel: viewModel)

                        InvoiceDetailListView(viewModel: viewModel)

                        // Separator
                        Rectangle().fill(Color.gray).frame(height: 1, alignment: .center).padding([.top, .bottom], 26)

                        ReinbursmentStatusView(viewModel: viewModel)

                        DocumentsView()
                    }
                    .background(Color.white)
                    .cornerRadius(20)

                    Image(viewModel.iconTitle)
                        .frame(width: 58, height: 58)
                        .offset(x: 0, y: -29)
                }.padding(.top, 40)
            }
            .zIndex(PaymentOptionSheetPosition.middle == viewModel.paymentOptionSheetPosition ? 0 : 1)
            .padding(.top, 40)

            HStack {
                Button(action: {
                    viewModel.paymentOptionSheetPosition = .middle
                }) {
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
                }
            }
            .padding(.bottom, 40)
            .zIndex(PaymentOptionSheetPosition.middle == viewModel.paymentOptionSheetPosition ? 1 : 2)

            ZStack {
                Spacer()
                    .bottomSheet(bottomSheetPosition: $viewModel.paymentOptionSheetPosition, options: [
                        .swipeToDismiss,
                        .absolutePositionValue,
                        .background({AnyView(Color.white)}),
                        .dragIndicatorColor(Color.gray),
                        .shadow(color: Color.gray, radius: CGFloat(10), x: CGFloat(0), y:  CGFloat(0)),
                        .backgroundBlur(effect: .systemMaterialDark)
                    ]) {
                        ButtonsSheetView(viewModel: viewModel.sheetViewModel)
                    }.zIndex(PaymentOptionSheetPosition.middle == viewModel.paymentOptionSheetPosition ? 1 : 0)

                Spacer()
                    .bottomSheet(bottomSheetPosition: $viewModel.paySheetPosition, options: [
                        .swipeToDismiss,
                        .absolutePositionValue,
                        .background({AnyView(Color.white)}),
                        .dragIndicatorColor(Color.gray),
                        .shadow(color: Color.gray, radius: CGFloat(10), x: CGFloat(0), y:  CGFloat(0)),
                        .backgroundBlur(effect: .systemMaterialDark)
                    ]) {
                        PayInvoiceSheetView()
                    }
                    .padding(.bottom, keyboard.currentHeight)
                    .edgesIgnoringSafeArea(.bottom)
                    .animation(.easeOut(duration: 0.16))
                    .zIndex(PaySheetPosition.extended == viewModel.paySheetPosition ? 1 : 0)
            }
            .zIndex(PaymentOptionSheetPosition.middle == viewModel.paymentOptionSheetPosition || PaySheetPosition.extended == viewModel.paySheetPosition ? 2 : 0)

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

struct InvoiceDetailHeaderView: View {
    var viewModel: NewInvoiceDetailViewModel
    var body: some View {
        VStack {
            Text(viewModel.companyName)
                .font(Style.appFont(style: .semiBold, 16))
                .padding(.top, 60)

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
        }
    }
}

struct ReinbursmentStatusView: View {
    var viewModel: NewInvoiceDetailViewModel
    var body: some View {
        VStack {
            HStack {
                Text("Reimbursement")
                    .font(Style.appFont(style: .semiBold, 14))
                Spacer()
                if viewModel.reimbursmentStatus {
                    Text("Reimbursed")
                        .foregroundColor(Color.green)
                        .padding(2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.green, lineWidth: 1)
                                .opacity(0.5)
                        )

                } else {
                    Text("Not sent")
                        .padding(2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.gray, lineWidth: 1)
                                .opacity(0.5)
                        )

                }
            }.padding([.top, .leading, .trailing])

            HStack {
                Text("Date of reimbursement")
                    .font(Style.appFont(14))
                    .foregroundColor(.gray)
                Spacer()
                Text("-")
                    .foregroundColor(.gray)
            }.padding([.top, .leading, .trailing])
        }
    }
}

struct DocumentsView: View {
    var body: some View {
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
}
