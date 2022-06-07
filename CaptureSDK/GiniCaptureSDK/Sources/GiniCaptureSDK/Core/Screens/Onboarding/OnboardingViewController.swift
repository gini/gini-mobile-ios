//
//  OnboardingViewController.swift
//  GiniCapture
//
//  Created by Peter Pult on 24/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

/**
 The `OnboardingViewController` provides a custom onboarding screen which presents some
 introductory screens to the user on how to get the camera in a perfect position etc.
 By default, three screens are pre-configured.
 
 To allow displaying the onboarding as a transparent modal view, set the `modalPresentationStyle`
 of the container class to `.OverCurrentContext`. Add a blank page at the end to make it possible
 to "swipe away" the onboarding. To achieve this, the container class needs to implement `UIScrollViewDelegate`
 and dismiss the view when the last (empty) page is reached. With the `UIScrollViewDelegate` callbacks
 it is also possible to add a custom page control and update the current page accordingly.
 
 Use the `OnboardingPage` class to quickly create custom onboarding pages in a nice consistent design.
 See below how easy it is to present an custom onboarding view controller.
 
     let pages = [
         OnboardingPage(image: myOnboardingImage1, text: "My Onboarding Page 1"),
         OnboardingPage(image: myOnboardingImage2, text: "My Onboarding Page 2"),
         OnboardingPage(image: myOnboardingImage3, text: "My Onboarding Page 3")
         OnboardingPage(image: myOnboardingImage4, text: "My Onboarding Page 4")
     ]
     let onboardingController = OnboardingViewController(pages: pages, scrollViewDelegate: self)
     presentViewController(onboardingController, animated: true, completion: nil)

 - note: Component API only.
 */
@objcMembers public final class OnboardingViewController: UIViewController {
    
    weak var scrollViewDelegate: UIScrollViewDelegate?
    
    /**
     Array of views displayed as pages inside the scroll view.
     */
    public var pages = [UIView]()
    
    /**
     Scroll view used to display different onboarding pages.
     */
    public lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self.scrollViewDelegate
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()

    /**
     Designated intitializer for the `OnboardingViewController` which allows to pass a custom set of
     views which will be displayed in horizontal scroll view.
     
     - parameter pages:              An array of views to be displayed in the scroll view.
     - parameter scrollViewDelegate: The receiver for the scroll view delegate callbacks.
     
     - returns: A view controller instance intended to allow the user to get a brief overview over
     the functionality provided by the Gini Capture SDK.
     */
    public init(pages: [UIView], scrollViewDelegate: UIScrollViewDelegate?) {
        self.scrollViewDelegate = scrollViewDelegate
        self.pages = pages
        super.init(nibName: nil, bundle: nil)
    }
    
    /**
     Convenience initializer for the `OnboardingViewController` which will set a predefined set
     of views as the onboarding pages.
     
     - parameter scrollViewDelegate: The receiver for the scroll view delegate callbacks.
     
     - returns: A view controller instance intended to allow the user to get a brief overview over
     the functionality provided by the Gini Capture SDK.
     */
    public convenience init(scrollViewDelegate: UIScrollViewDelegate?) {
        self.init(pages: GiniConfiguration.shared.onboardingPages, scrollViewDelegate: scrollViewDelegate)
    }
    
    /**
     Returns an object initialized from data in a given unarchiver.
     
     - warning: Not implemented.
     */
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        super.loadView()
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        for page in self.pages {
            contentView.addSubview(page)
        }
        
        addConstraints()
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scrollView.contentInsetAdjustmentBehavior = .never
    }
    
    /**
     Scrolls the scroll view to the next page.
     
     - parameter animated: Defines whether scrolling should be animated.
     */
    public func scrollToNextPage(_ animated: Bool) {
        // Make sure there is no overflow and scrolling only happens from page to page
        if let nextOffset = nextPageOffset(), nextOffset.x < scrollView.contentSize.width {
            scrollView.setContentOffset(nextOffset, animated: animated)
        }
    }
    
    public func nextPageOffset() -> CGPoint? {
        let pageSize = contentView.frame.size.width / CGFloat(pages.count)

        for index in 1..<pages.count {
            let pageOffset = CGFloat(index) * pageSize
            if scrollView.contentOffset.x < pageOffset {
                return CGPoint(x: pageOffset, y: scrollView.contentOffset.y)
            }
        }
        
        return nil
    }
    
    /**
     Center page in case it is not centered (i.e after rotation)
     
     */
    public func centerTo(page: Int) {
        var offset = scrollView.contentOffset
        offset.x = scrollView.frame.width * CGFloat(page)
                
        scrollView.setContentOffset(offset, animated: true)
    }
        
    // MARK: - Constraints
    fileprivate func addConstraints() {
        let pagesCount = CGFloat(pages.count)
        
        // Scroll view
        Constraints.pin(view: scrollView, toSuperView: self.view)
        
        // Content view
        Constraints.pin(view: contentView, toSuperView: scrollView)
        Constraints.active(item: contentView, attr: .width, relatedBy: .equal, to: scrollView, attr: .width,
                          multiplier: pagesCount)
        Constraints.active(item: contentView, attr: .height, relatedBy: .equal, to: scrollView, attr: .height)
        
        for page in pages {
            page.translatesAutoresizingMaskIntoConstraints = false
            Constraints.active(item: page, attr: .top, relatedBy: .equal, to: contentView, attr: .top)
            Constraints.active(item: page, attr: .bottom, relatedBy: .equal, to: contentView, attr: .bottom)
            Constraints.active(item: page, attr: .width, relatedBy: .equal, to: contentView, attr: .width,
                              multiplier: 1/pagesCount)
            if page == pages.first {
                Constraints.active(item: page, attr: .leading, relatedBy: .equal, to: contentView, attr: .leading)
            } else {
                let previousPage = pages[pages.firstIndex(of: page)! - 1]
                Constraints.active(item: page, attr: .leading, relatedBy: .equal, to: previousPage, attr: .trailing)
            }
        }
    }
}
