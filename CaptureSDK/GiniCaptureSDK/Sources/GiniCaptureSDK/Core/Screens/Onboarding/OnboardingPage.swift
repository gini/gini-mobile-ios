//
//  OnboardingPage.swift
//  
//
//  Created by Nadya Karaban on 15.09.22.
//

import Foundation

/**
 `OnboardingPage` represents the onboarding page with all it's properties.
 */

public struct OnboardingPage {
    let imageName: String
    let title: String
    let description: String

    /**
     *  Creates an `OnboardingPage` instance.
     *
     * - Parameter imageName:   A name of the image associated with the onboarding page.
     * - Parameter title:       A title of the onboarding page
     * - Parameter description: A short description of the onboarding page
     */

    public init(imageName: String, title: String, description: String) {
        self.imageName = imageName
        self.title = title
        self.description = description
    }
}
