//
//  OnboardingIllustrationAdapter.swift
//  
//
//  Created by Nadya Karaban on 08.08.22.
//

import Foundation
/**
*   Adapter for injecting a custom onboarding illustration with a custom animation for the onboarding page.
*/
public protocol OnboardingIllustrationAdapter: InjectedViewAdapter {
/**
 *  Called when the page appears on screen. If you use animations, then you can start the animation here.
 */
    func pageDidAppear()
/**
 *  Called when the page disappears. If you use animations, then you can stop the animation here.
 */
    func pageDidDisappear()
}
