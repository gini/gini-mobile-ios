//
//  DocumentView.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 29.03.2022.
//

import SwiftUI

struct DocumentView: View {
    var viewModel: DocuementViewModel

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
            .padding(.top)
            .padding(.trailing)

            Spacer()
            viewModel.image
                .resizable()
                .aspectRatio(contentMode: .fit)
            Spacer()
        }
        .background(Color.gray)
        .ignoresSafeArea()
    }
}

struct ReimbursmentDocumentView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentView(viewModel: DocuementViewModel())
    }
}
