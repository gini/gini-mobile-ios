//
//  UIViewController+Extensions.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

public extension UIViewController {
    
    func giniTopMostViewController() -> UIViewController {
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.giniTopMostViewController() ?? navigation
        }
        
        if let tabBarController = self as? UITabBarController {
            if let selectedTab = tabBarController.selectedViewController {
                return selectedTab.giniTopMostViewController()
            }
            return tabBarController
        }
        
        if let presentedViewController = self.presentedViewController {
            return presentedViewController.giniTopMostViewController()
        }
        
        if let pageViewController = self as? UIPageViewController,
           let firstViewController = pageViewController.viewControllers?.first {
            return firstViewController.giniTopMostViewController()
        }
        
        return self
    }
}
