//
//  OneTimeSlideFromLeftNavigationDelegate.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

class SingleTransitionLeftSlideNavigationDelegate: NSObject, UINavigationControllerDelegate {
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
