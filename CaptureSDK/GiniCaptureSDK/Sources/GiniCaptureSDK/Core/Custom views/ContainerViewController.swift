//
//  GINIContainer.swift
//  GiniCapture
//
//  Created by Peter Pult on 16/06/16.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit

protocol ContainerViewController: AnyObject {
    
    var containerView: UIView { get }
    var contentController: UIViewController { get }
    
    func displayContent(_ controller: UIViewController)
    
}

extension ContainerViewController where Self: UIViewController {
    
    func displayContent(_ controller: UIViewController) {
        self.addChild(controller)
        controller.view.frame = self.containerView.bounds
        self.containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
    
}
