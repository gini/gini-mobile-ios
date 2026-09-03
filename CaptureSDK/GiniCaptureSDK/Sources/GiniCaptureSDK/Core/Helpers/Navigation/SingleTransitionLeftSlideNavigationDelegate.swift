//
//  SingleTransitionLeftSlideNavigationDelegate.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

/**
 SingleTransitionLeftSlideNavigationDelegate sets LeftSlideTransitionAnimator
 as the animation controller for a single transition and then resets the delegate.
 Can be used for applying a custom transition once without affecting future navigation actions.
 */
final class SingleTransitionLeftSlideNavigationDelegate: NSObject, UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return LeftSlideTransitionAnimator()
    }

    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool) {
        if navigationController.delegate === self {
            navigationController.delegate = nil
        }
    }
}
