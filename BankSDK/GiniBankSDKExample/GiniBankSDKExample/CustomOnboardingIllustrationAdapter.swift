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
    private var animatedOnboardingPage1: AnimationView?
    func pageDidAppear() {
       // animatedOnboardingPage1?.play()
    }
    
    func pageDidDisappear() {
       // animatedOnboardingPage1?.stop()
    }
    
    func injectedView() -> UIView {
        let animatedOnboardingPage1 = AnimationView(name: "page1Animation")
        animatedOnboardingPage1.backgroundColor = .blue
        animatedOnboardingPage1.contentMode = .scaleAspectFit
        animatedOnboardingPage1.loopMode = .loop
        animatedOnboardingPage1.play()
        return animatedOnboardingPage1
    }
    
    func onDeinit() {
    }
}
