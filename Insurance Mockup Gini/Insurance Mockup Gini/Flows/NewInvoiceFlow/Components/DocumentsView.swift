//
//  DocumentsView.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 29.03.2022.
//

import SwiftUI

struct DocumentsView: View {
    var images: [Image]

    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                HStack{
                    Text("Documents")
                    Spacer()
                }.padding()

                ScrollView (.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(0..<images.count) { imageIndex in
                                   images[imageIndex]
                                    .resizable()
                                    .frame(width: 150)
                                    .aspectRatio(contentMode: .fit)
                                    .onTapGesture {
                                        print("\(imageIndex)")
                                    }
                                }
                    }
                }.padding()

                Spacer()
            }
            .background(Style.NewInvoice.grayBackgroundColor)
            .frame(height: 300)

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
