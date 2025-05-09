//
//  UIViewController+Extensions.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

public extension UIViewController {
    
    func topMostViewController() -> UIViewController {
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }
        
        if let tabBarController = self as? UITabBarController {
            if let selectedTab = tabBarController.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tabBarController
        }
        
        if let presentedViewController = self.presentedViewController {
            return presentedViewController.topMostViewController()
        }
        
        if let pageViewController = self as? UIPageViewController,
           let firstViewController = pageViewController.viewControllers?.first {
            return firstViewController.topMostViewController()
        }
        
        return self
    }
}
