//
//  GiniCarouselView.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//


import SwiftUI

struct GiniCarouselView: View {
    
    let images: [UIImage]
    @State private var currentIndex: Int = 0
    
    var body: some View {
        VStack(spacing: 12) {
            TabView(selection: $currentIndex) {
                ForEach(images.indices, id: \.self) { index in
                    GiniZoomableImageView(image: images[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        }
    }
}
