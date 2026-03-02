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
        print("🟢 Adding child coordinator: \(type(of: childCoordinator))")
        self.childCoordinators.append(childCoordinator)
        print("   Total child coordinators: \(self.childCoordinators.count)")
    }
    
    func remove(childCoordinator: Coordinator) {
        print("🔴 Removing child coordinator: \(type(of: childCoordinator))")
        print("   Before removal: \(self.childCoordinators.count) children")
        self.childCoordinators = self.childCoordinators.filter { $0 !== childCoordinator }
        print("   After removal: \(self.childCoordinators.count) children")
    }
    
}
