//
//  DocumentView.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 29.03.2022.
//

import SwiftUI

struct DocumentView: View {
    var viewModel: DocumentViewModel
    @State private var lastScaleValue: CGFloat = 1.0

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    viewModel.didTapClose()
                } label: {
                    Image("exit_icon")
                }
            }
            .padding(.top, 40)
            .padding(.trailing)

            ScrollView {
                Spacer()
                viewModel.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(lastScaleValue)
                Spacer()
            }
            .gesture(MagnificationGesture().onChanged { value in
                lastScaleValue = value
            }.onEnded { value in
                lastScaleValue = 1.0
            })

        }
        .background(Color.gray)
        .ignoresSafeArea()
    }
}

struct ReimbursmentDocumentView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentView(viewModel: DocumentViewModel())
    }
}
