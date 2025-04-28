//
//  LeftSlideTransitionAnimator.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

class LeftSlideTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toView = transitionContext.view(forKey: .to),
            let fromView = transitionContext.view(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to)
        else {
            transitionContext.completeTransition(false)
            return
        }

        let container = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toVC)

        toView.frame = finalFrame.offsetBy(dx: -container.frame.width, dy: 0)
        container.addSubview(toView)

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromView.frame = fromView.frame.offsetBy(dx: container.frame.width, dy: 0)
            toView.frame = finalFrame
        }) { finished in
            transitionContext.completeTransition(finished)
        }
    }
}
