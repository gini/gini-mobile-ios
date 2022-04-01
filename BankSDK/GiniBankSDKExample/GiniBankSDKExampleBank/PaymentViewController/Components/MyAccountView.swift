//
//  MyAccountView.swift
//  GinBankSDKExampleBank
//
//  Created by David Vizaknai on 01.04.2022.
//

import SwiftUI

struct MyAccountView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("DE23 3701 0044 1344 8291 01")
                    .foregroundColor(.gray)

                Text("€6.231,40")
                    .fontWeight(.bold)
            }.padding()

            Spacer()

            Image(systemName: "chevron.down")
                .padding()
        }
        .background(.white)
        .cornerRadius(8)
    }
}

struct MyAccountView_Previews: PreviewProvider {
    static var previews: some View {
        MyAccountView()
    }
}
