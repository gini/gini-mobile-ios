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
       // animatedOnboardingPage1?.play()
    }
    
    func pageDidDisappear() {
       // animatedOnboardingPage1?.stop()
    }
    
    func injectedView() -> UIView {
        //animatedOnboarding?.stop()
        animatedOnboarding?.contentMode = .scaleAspectFit
        animatedOnboarding?.loopMode = .loop
        animatedOnboarding?.play()
        if let animation = animatedOnboarding {
            return animation
        }
        return UIView()
    }
    
    func onDeinit() {
    }
}
