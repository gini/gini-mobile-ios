//
//  CustomOnboardingIllustrationAdapter.swift
//  GiniBankSDKExample
//
//  Created by Nadya Karaban on 16.09.22.
//

import Foundation
import GiniCaptureSDK
import Lottie
import UIKit

class CustomOnboardingIllustrationAdapter: OnboardingIllustrationAdapter {
    private var animatedOnboarding: AnimationView?
    
    init(animationName: String? = nil, backgroundColor: UIColor) {
        self.animatedOnboarding = AnimationView(name: animationName ?? "")
        self.animatedOnboarding?.backgroundColor = backgroundColor
    }
    
    func pageDidAppear() {
        animatedOnboarding?.play()
    }
    
    func pageDidDisappear() {
        animatedOnboarding?.stop()
    }
    
    func injectedView() -> UIView {
        animatedOnboarding?.contentMode = .scaleAspectFit
        animatedOnboarding?.loopMode = .loop
        
        if let animation = animatedOnboarding {
            return animation
        }
        return UIView()
    }
    
    func onDeinit() {
    }
}
