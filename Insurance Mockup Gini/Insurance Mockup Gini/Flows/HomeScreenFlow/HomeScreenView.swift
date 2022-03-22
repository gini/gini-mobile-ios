//
//  HomeScreenView.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 22.03.2022.
//

import SwiftUI

struct HomeScreenView: View {
    var body: some View {
        ScrollView {
            HStack {
                Text("Overview")
                    .fontWeight(.bold)
                Spacer()
                Image(systemName: "bell")
                Image(systemName: "info.circle")
            }.padding([.leading, .trailing])

            HStack {
                VStack(alignment: .leading) {
                    Text("You are close to the threshold!")
                        .font(.title)
                        .fontWeight(.semibold)
                    Text("€8,970.26 / €11,500.00")
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray, lineWidth: 1)
                    )

            HStack {
                Text("Upcoming appointments")
                Spacer()
                Text("See all")
            }.padding([.top, .bottom])
        }.padding()

    }
}

struct HomeScreenView_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreenView()
    }
}
