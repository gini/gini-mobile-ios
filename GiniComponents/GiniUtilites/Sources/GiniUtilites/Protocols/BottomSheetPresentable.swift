//
//  BottomSheetPresentable.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

public typealias GiniBottomSheetViewController = UIViewController & BottomSheetPresentable

public protocol BottomSheetPresentable {
    
    var shouldShowDragIndicator: Bool { get }
    
    func configureBottomSheet(shouldIncludeLargeDetent: Bool)
    func updateBottomSheetHeight(_ height: CGFloat)
}

public extension BottomSheetPresentable where Self: UIViewController {
    
    func configureBottomSheet(shouldIncludeLargeDetent: Bool = false) {
        if #available(iOS 15, *),
           let presentationController = sheetPresentationController {
            presentationController.detents = [shouldIncludeLargeDetent ? .large() : .medium()]
            presentationController.prefersGrabberVisible = true
            presentationController.prefersScrollingExpandsWhenScrolledToEdge = false
            presentationController.prefersEdgeAttachedInCompactHeight = false
        }
    }
    
    func updateBottomSheetHeight(_ height: CGFloat) {
        if #available(iOS 16, *),
            let presentationController = sheetPresentationController {
            let identifier = UISheetPresentationController.Detent.Identifier("customHeight")
            
            let customDetent = UISheetPresentationController.Detent.custom(identifier: identifier) { context in
                return height
            }
            
            presentationController.detents = [customDetent]
            presentationController.selectedDetentIdentifier = identifier
        }
    }
}
