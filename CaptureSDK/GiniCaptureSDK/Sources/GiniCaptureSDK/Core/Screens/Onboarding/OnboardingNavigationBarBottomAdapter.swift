//
//  File.swift
//  
//
//  Created by Nadya Karaban on 08.08.22.
//

import Foundation
import UIKit
// Option 3 to limit UI Control variety and limit it to UIControl and connect control and action on Gini side
public protocol GiniNavigationButtonView: UIControl {
    func handlePressAction()
}

class CustomNavigationButtonView: UIControl, GiniNavigationButtonView {
    func handlePressAction() {
    }
}

//Option 1 Use blocks
public protocol OnboardingNavigationBarBottomAdapter: InjectedViewAdapter {
    // Problem 1 - needs to be called in didClickNextButton()
    var nextButtonCompletionHandler: () -> Void { get set }
    // Problem 2  - Action needs to be connected to the control
    func didClickNextButton()
    
    func showButtons(navigationButtons: [OnboardingNavigationBarBottomButton])
}

// Option 2 Use Subclass of  Base class
// Problem - Action needs to be connected to the control

class BaseNavigationBarBottomAdapter: OnboardingNavigationBarBottomAdapter {
    var nextButton = CustomNavigationButtonView()
    
    func didClickNextButton() {
        nextButton.handlePressAction()
    }
    
    var nextButtonCompletionHandler: (() -> Void) = {}
    
    func showButtons(navigationButtons: [OnboardingNavigationBarBottomButton]) {
    }
    
    func injectedView() -> UIView {
        if let navigationBarView =
            OnboardingBottomNavigationBar().loadNib() as?
                OnboardingBottomNavigationBar {

            return navigationBarView
        } else {
            return UIView()
        }
    }
    
    
}

class CustomNavigationBarBottomAdapter: BaseNavigationBarBottomAdapter {
    
    override func injectedView() -> UIView {
        return UIView()
    }
    
    
//    override func didClickNextButton() {
//        super.didClickNextButton()
//        //custom
//    }
}

public enum OnboardingNavigationBarBottomButton: Int {
    case SKIP
    case NEXT
    case GET_STARTED
}

//public protocol OnboardingNextButton {
//    func nextButton() -> UIView
//    func nextButtonAction()
//}

class DefaultOnboardingNavigationBarBottomAdapter: OnboardingNavigationBarBottomAdapter {
    var nextButtonCompletionHandler: (() -> Void) = {}
    private func addAnimation(){}
    private func bindAction(){}
    func didClickSkipButton(completion: () -> Void) {
    }
    
    func didClickSkipButton() {
    }
    //return UIView
//    func nextButton() -> UIView {
//        let btn = UIButton()
//        //btn.addTarget(<#T##target: Any?##Any?#>, action: (), for: UIControl.Event)
//        return UIView()
//    }
//
//    func nextButtonAction() {
//       print("nextButtonAction")
//    }
    
    private var bottomBarView : OnboardingBottomNavigationBar?
    func injectedView() -> UIView {
        if let navigationBarView =
            OnboardingBottomNavigationBar().loadNib() as?
                OnboardingBottomNavigationBar {
           // navigationBarView.nextButton.addTarget(self, action: #selector(didClickNextButton), for: .touchUpInside)

            return navigationBarView
        } else {
            return UIView()
        }
    }
        
    @objc func didClickNextButton() {
        self.nextButtonCompletionHandler()
    }
    
    func didClickGetStartedButton() {
    }
    
    func showButtons(navigationButtons: [OnboardingNavigationBarBottomButton]) {
        
    }
    
    
}
