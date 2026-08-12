//
//  GiniCarouselView.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//


import SwiftUI

struct GiniCarouselViewModel {
    let images: [UIImage]
    let imageAccessibilityLabel: String?
    let pageIndicatorTintColor: UIColor
    let currentPageIndicatorTintColor: UIColor
}

struct GiniCarouselView: View {
    
    private let images: [UIImage]
    private let imageAccessibilityLabel: String?
    
    @State private var currentIndex: Int = 0
    
    init(viewModel: GiniCarouselViewModel) {
        self.images = viewModel.images
        self.imageAccessibilityLabel = viewModel.imageAccessibilityLabel
        let pageControlAppearance = UIPageControl.appearance(whenContainedInInstancesOf: [PaymentReviewViewController.self])
        pageControlAppearance.currentPageIndicatorTintColor = viewModel.currentPageIndicatorTintColor
        pageControlAppearance.pageIndicatorTintColor = viewModel.pageIndicatorTintColor
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
