//
//  Coordinator.swift
//  GiniCapture_Example
//
//  Created by Enrique del Pozo Gómez on 11/10/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit

protocol Coordinator: AnyObject {
    
    var rootViewController: UIViewController { get }
    var childCoordinators: [Coordinator] { get set }
}

extension Coordinator {
    
    func add(childCoordinator: Coordinator) {
        #if DEBUG
        print("🟢 Adding child coordinator: \(type(of: childCoordinator))")
        #endif
        self.childCoordinators.append(childCoordinator)
        #if DEBUG
        print("   Total child coordinators: \(self.childCoordinators.count)")
        #endif
    }
    
    func remove(childCoordinator: Coordinator) {
        #if DEBUG
        print("🔴 Removing child coordinator: \(type(of: childCoordinator))")
        print("   Before removal: \(self.childCoordinators.count) children")
        #endif
        self.childCoordinators = self.childCoordinators.filter { $0 !== childCoordinator }
        #if DEBUG
        print("   After removal: \(self.childCoordinators.count) children")
        #endif
    }
    
}
