//
//  GiniCarouselView.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//


import SwiftUI

struct GiniCarouselView: View {
    
    private let images: [UIImage]
    
    @State private var currentIndex: Int = 0
    
    init(images: [UIImage]) {
        self.images = images
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 12) {
                TabView(selection: $currentIndex) {
                    ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                        GiniZoomableImageView(image: image, size: geometry.size)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            }
        }
    }
}
