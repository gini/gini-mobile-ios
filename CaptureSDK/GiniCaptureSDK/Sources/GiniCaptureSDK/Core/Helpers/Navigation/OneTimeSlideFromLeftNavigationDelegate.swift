//
//  OneTimeSlideFromLeftNavigationDelegate.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

class OneTimeSlideFromLeftNavigationDelegate: NSObject, UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideFromLeftAnimator()
    }

    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool) {
        if navigationController.delegate === self {
            navigationController.delegate = nil
        }
    }
}
