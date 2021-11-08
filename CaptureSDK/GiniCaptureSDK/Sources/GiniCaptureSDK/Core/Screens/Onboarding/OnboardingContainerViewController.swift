//
//  OnboardingContainerViewController.swift
//  GiniCapture
//
//  Created by Peter Pult on 24/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

/**
 Block that will be executed when the onboarding was dismissed.
 */
typealias OnboardingContainerCompletionBlock = () -> Void

/**
 Container class for `OnboardingViewController`.
 
 - note: Should be embedded in a navigation controller.
 */
final class OnboardingContainerViewController: UIViewController, ContainerViewController {
    
    let giniConfiguration: GiniConfiguration
    public weak var trackingDelegate: OnboardingScreenTrackingDelegate?
    fileprivate let backgroundAlpha: CGFloat = 0.25
    fileprivate var completionBlock: OnboardingContainerCompletionBlock?

    lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var contentController: UIViewController = {
        var pages = self.giniConfiguration.onboardingPages
        pages.append(UIView()) // Add an empty last page to transition nicely back to camera
        return OnboardingViewController(pages: pages,
                                        scrollViewDelegate: self)
    }()
    
    fileprivate lazy var pageControlContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate lazy var pageControl: UIPageControl = {
       let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPage = 0
        pageControl.numberOfPages = self.giniConfiguration.onboardingPages.count + 1 // Empty page at the end
        pageControl.currentPageIndicatorTintColor = UIColor.from(giniColor: giniConfiguration.onboardingCurrentPageIndicatorColor).withAlphaComponent(giniConfiguration.onboardingCurrentPageIndicatorAlpha)
        pageControl.pageIndicatorTintColor = UIColor.from(giniColor: giniConfiguration.onboardingPageIndicatorColor)
        pageControl.isUserInteractionEnabled = false
        pageControl.isAccessibilityElement = false
        return pageControl
    }()
    
    fileprivate lazy var continueButton: UIBarButtonItem = {
        let continueButtonResources =
            GiniPreferredButtonResource(image: "navigationOnboardingContinue",
                                        title: "ginicapture.navigationbar.onboarding.continue",
                                        comment: "Button title in the navigation bar for the " +
                "continue button on the onboarding screen",
                                        configEntry: self.giniConfiguration.navigationBarOnboardingTitleContinueButton)
        return GiniBarButtonItem(
            image: continueButtonResources.preferredImage,
            title: continueButtonResources.preferredText,
            style: .plain,
            target: self,
            action: #selector(self.nextPage)
        )
    }()
    
    init(giniConfiguration: GiniConfiguration = GiniConfiguration.shared,
         trackingDelegate: OnboardingScreenTrackingDelegate? = nil,
         withCompletion completion: @escaping OnboardingContainerCompletionBlock) {
        self.giniConfiguration = giniConfiguration
        self.trackingDelegate = trackingDelegate
        self.completionBlock = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(containerView)
        view.addSubview(pageControlContainerView)
        pageControlContainerView.addSubview(pageControl)
        navigationItem.setRightBarButton(continueButton, animated: false)
        
        addConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = .localized(resource: NavigationBarStrings.onboardingTitle)
        view.backgroundColor = UIColor.from(giniColor: giniConfiguration.onboardingScreenBackgroundColor)
        
        trackingDelegate?.onOnboardingScreenEvent(event: Event(type: .start))
        
        // Add content to container view
        displayContent(contentController)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        trackingDelegate?.onOnboardingScreenEvent(event: Event(type: .finish))
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // Current onboarding page needs to be centered during transition (after ScrollView changes its frame)
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let self = self else {
                return
            }
            (self.contentController as? OnboardingViewController)?.centerTo(page: self.pageControl.currentPage)
        })
    }
    
    // MARK: Actions
    
    @IBAction func close() {
        dismiss(animated: false, completion: completionBlock)
    }
    
    @IBAction func nextPage() {
        (contentController as? OnboardingViewController)?.scrollToNextPage(true)
    }
    
    // MARK: Constraints
    
    fileprivate func addConstraints() {
        let superview = self.view
        
        // Container view
        Constraints.active(item: containerView, attr: .top, relatedBy: .equal, to: superview, attr: .top)
        Constraints.active(item: containerView, attr: .bottom, relatedBy: .greaterThanOrEqual, to: superview,
                          attr: .bottom, priority: 750)
        Constraints.active(item: containerView, attr: .width, relatedBy: .equal, to: superview, attr: .width,
                          priority: 750)
        Constraints.active(item: containerView, attr: .width, relatedBy: .lessThanOrEqual, to: superview,
                          attr: .width, priority: 999)
        Constraints.active(item: containerView, attr: .centerX, relatedBy: .equal, to: superview, attr: .centerX)
        
        // Page control container view
        Constraints.active(item: pageControlContainerView, attr: .top, relatedBy: .equal, to: containerView,
                          attr: .bottom, priority: 750)
        Constraints.active(item: pageControlContainerView, attr: .trailing, relatedBy: .equal, to: superview,
                          attr: .trailing)
        Constraints.active(item: pageControlContainerView, attr: .bottom, relatedBy: .equal, to: view.safeAreaLayoutGuide,
                          attr: .bottom)
        Constraints.active(item: pageControlContainerView, attr: .leading, relatedBy: .equal, to: superview,
                          attr: .leading)
        Constraints.active(item: pageControlContainerView, attr: .height, relatedBy: .greaterThanOrEqual,
                          to: pageControl, attr: .height, multiplier: 1.1)
        
        // Page control
        Constraints.active(item: pageControl, attr: .height, relatedBy: .equal, to: nil, attr: .height, constant: 55)
        Constraints.active(item: pageControl, attr: .centerX, relatedBy: .equal, to: pageControlContainerView,
                          attr: .centerX)
        Constraints.active(item: pageControl, attr: .centerY, relatedBy: .equal, to: pageControlContainerView,
                          attr: .centerY)
        
    }
}

// MARK: UIScrollViewDelegate

extension OnboardingContainerViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setPageControl(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        setPageControl(scrollView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Update fixed elements position
        let pageWidth = scrollView.frame.size.width
        let contentOffsetX = scrollView.contentOffset.x
        var frameOffsetX = contentOffsetX - pageWidth * CGFloat(pageControl.numberOfPages - 2)
        let fixedFrame = view.frame
        frameOffsetX = max(-frameOffsetX, -fixedFrame.width)
        frameOffsetX = min(frameOffsetX, 0)
        navigationController?.navigationBar.frame.origin.x = frameOffsetX
        pageControlContainerView.frame.origin.x = frameOffsetX
    }
    
    fileprivate func setPageControl(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let contentOffsetX = scrollView.contentOffset.x
        let currentPage = contentOffsetX / pageWidth
        pageControl.currentPage = Int(currentPage)
        
        // Dismiss onboarding on reach of end
        if contentOffsetX + pageWidth >= scrollView.contentSize.width {
            close()
        }
    }
    
}

// MARK: User defaults flags

extension OnboardingContainerViewController {
    static var willBeShown: Bool {
        return (GiniConfiguration.shared.onboardingShowAtFirstLaunch &&
            !UserDefaults.standard.bool(forKey: "ginicapture.defaults.onboardingShowed")) ||
            GiniConfiguration.shared.onboardingShowAtLaunch
    }
}
