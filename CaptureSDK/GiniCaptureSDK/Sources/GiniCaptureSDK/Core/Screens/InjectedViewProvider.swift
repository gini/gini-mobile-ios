//
//  InjectedViewProvider.swift
//  
//
//  Created by Nadya Karaban on 20.05.22.
//

import Foundation
import UIKit

public protocol InjectedViewProvider {
    func injectedView() -> UIView
}

public protocol NavigationBarBottomProvider: InjectedViewProvider {
    func didClickBackButton()
    func backButtonIcon() -> UIImage
}

public protocol NavigationBarTopProvider: InjectedViewProvider {
    func didClickCloseButton()
    func closeButtonIcon() -> UIImage
    func title() -> String
}

public protocol OnboardingIconProview {
    func pageDidAppear()
    func pageDidDisappear()
}

class InjectedContainerView: UIView {
   //func injectedViewProvider() -> InjectedViewProvider
}
