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
                        InvoiceDetailHeaderView(viewModel: viewModel.invoiceHeaderViewModel)

                        InvoiceDetailListView(viewModel: viewModel.invoiceDetailListViewModel)

                        // Separator
                        Rectangle().fill(Color.gray).frame(height: 1, alignment: .center).padding([.top, .bottom], 26)

                        ReinbursmentStatusView(reimbursmentStatus: viewModel.reimbursmentStatus, price: viewModel.price)

                        DocumentsView(images: viewModel.images)
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
                }
            .zIndex(PaymentOptionSheetPosition.middle == viewModel.paymentOptionSheetPosition ? 2 : 0)

        }
        .background(Style.NewInvoice.backgroundColor)
        .ignoresSafeArea()
    }
}
