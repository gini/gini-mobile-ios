//
//  OnboardingPage.swift
//  
//
//  Created by Nadya Karaban on 15.09.22.
//

import Foundation

public struct OnboardingPageNew {
    let imageName: String
    let title: String
    let description: String
    public init(imageName: String, title: String, description: String) {
        self.imageName = imageName
        self.title = title
        self.description = description
    }
}
