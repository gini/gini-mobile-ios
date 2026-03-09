//
//  GiniCarouselView.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//


import SwiftUI

struct GiniCarouselView: View {
    
    private let images: [UIImage]
    private let imageAccessibilityLabel: String?
    
    @State private var currentIndex: Int = 0
    
    init(images: [UIImage], imageAccessibilityLabel: String? = nil) {
        self.images = images
        self.imageAccessibilityLabel = imageAccessibilityLabel
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: Constants.spacing) {
                TabView(selection: $currentIndex) {
                    ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                        GiniZoomableImageView(image: image,
                                              size: geometry.size,
                                              accessibilityLabel: imageAccessibilityLabel)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            }
        }
    }
    
    private struct Constants {
        
        static let spacing: CGFloat = 12
    }
}
