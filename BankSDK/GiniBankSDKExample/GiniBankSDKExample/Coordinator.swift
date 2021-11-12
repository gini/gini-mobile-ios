//
//  Coordinator.swift
//  Example Swift
//
//  Created by Nadya Karaban on 18.02.21.
//

import Foundation
import UIKit

protocol Coordinator: AnyObject {
    
    var rootViewController: UIViewController { get }
    var childCoordinators: [Coordinator] { get set }
}

extension Coordinator {
    
    func add(childCoordinator: Coordinator) {
        childCoordinators.append(childCoordinator)
    }
    
    func remove(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== childCoordinator }
    }
    
}
