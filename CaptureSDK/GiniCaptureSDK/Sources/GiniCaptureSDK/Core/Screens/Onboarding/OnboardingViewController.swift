//
//  OnboardingViewController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {
    @IBOutlet weak var pagesCollection: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: MultilineTitleButton!
    private(set) var dataSource: OnboardingDataSource
    private let configuration = GiniConfiguration.shared
    private var navigationBarBottomAdapter: OnboardingNavigationBarBottomAdapter?
    private var bottomNavigationBar: UIView?
    private lazy var skipButton = GiniBarButton(ofType: .skip)

    init() {
        dataSource = OnboardingDataSource(configuration: configuration)
        super.init(nibName: "OnboardingViewController", bundle: giniCaptureBundle())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureCollectionView() {
        pagesCollection.register(
            UINib(nibName: "OnboardingPageCell", bundle: giniCaptureBundle()),
            forCellWithReuseIdentifier: OnboardingPageCell.reuseIdentifier)
        pagesCollection.isPagingEnabled = true
        pagesCollection.showsHorizontalScrollIndicator = false
        pagesCollection.dataSource = dataSource
        pagesCollection.delegate = dataSource
        dataSource.delegate = self
    }

    private func configurePageControl() {
        pageControl.pageIndicatorTintColor = GiniColor(light: UIColor.GiniCapture.dark1,
                                                       dark: UIColor.GiniCapture.light1
                                                      ).uiColor().withAlphaComponent(0.3)
        pageControl.currentPageIndicatorTintColor = GiniColor(light: UIColor.GiniCapture.dark1,
                                                              dark: UIColor.GiniCapture.light1
                                                             ).uiColor()
        pageControl.addTarget(self, action: #selector(self.pageControlSelectionAction(_:)), for: .valueChanged)
        pageControl.numberOfPages = dataSource.pageModels.count
        pageControl.isAccessibilityElement = true
        configureNavigationButtons(for: 0)
        pageControl.currentPage = 0
    }

    private func setupView() {
        view.backgroundColor = GiniColor(light: UIColor.GiniCapture.light2, dark: UIColor.GiniCapture.dark2).uiColor()
        configureCollectionView()
        if configuration.bottomNavigationBarEnabled {
            configureBottomNavigation()
        } else {
            configureBasicNavigation()
        }
        configurePageControl()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func layoutBottomNavigationBar(_ navigationBar: UIView) {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 46),
            navigationBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func configureBasicNavigation() {
        nextButton.titleLabel?.font = configuration.textStyleFonts[.bodyBold]
        nextButton.configure(with: GiniConfiguration.shared.primaryButtonConfiguration)
        nextButton.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        configureNextButton()

        configureSkipButton()
    }

    private func hideTopNavigation() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func configureBottomNavigation() {
        hideTopNavigation()
        removeButtons()
        if let customBottomNavigationBar = configuration.onboardingNavigationBarBottomAdapter {
            navigationBarBottomAdapter = customBottomNavigationBar
        } else {
            navigationBarBottomAdapter = DefaultOnboardingNavigationBarBottomAdapter()
        }
        navigationBarBottomAdapter?.setNextButtonClickedActionCallback { [weak self] in
            self?.nextPage()
        }
        navigationBarBottomAdapter?.setSkipButtonClickedActionCallback { [weak self] in
            self?.skipTapped()
        }
        navigationBarBottomAdapter?.setGetStartedButtonClickedActionCallback { [weak self] in
            self?.getStartedButtonAction()
        }
        if let navigationBar = navigationBarBottomAdapter?.injectedView() {
            bottomNavigationBar = navigationBar
            view.addSubview(navigationBar)
            layoutBottomNavigationBar(navigationBar)
            navigationBarBottomAdapter?.showButtons(navigationButtons: [.skip, .next], navigationBar: navigationBar)

            configureNextButton()
            nextButton.addTarget(self, action: #selector(nextPage), for: .touchUpInside)

            configureSkipButton()
        }
    }

    private func removeButtons() {
        nextButton.removeFromSuperview()
    }

    private func configureSkipButton() {
        skipButton.addAction(self, #selector(skipTapped))
        navigationItem.rightBarButtonItem = skipButton.barButton
    }

    private func configureGetStartedButton() {
        let getStartedTitle = NSLocalizedStringPreferredFormat("ginicapture.onboarding.getstarted",
                                                               comment: "Get Started button")
        nextButton.setTitle(getStartedTitle, for: .normal)
        nextButton.accessibilityValue = getStartedTitle
    }

    private func configureNextButton() {
        let nextButtonTitle = NSLocalizedStringPreferredFormat("ginicapture.onboarding.next",
                                                               comment: "Next button")
        nextButton.accessibilityValue = nextButtonTitle
        nextButton.setTitle(nextButtonTitle, for: .normal)
    }

    @objc private func skipTapped() {
        // Handle the skip button tap if there are more onboarding pages.
        // The skip button is not present on the last onboarding page.
        let currentPageIndex = dataSource.currentPageIndex
        guard currentPageIndex < dataSource.pageModels.count - 1 else { return }
        track(event: .skipTapped, for: currentPageIndex)
        close()
    }

    private func close() {
        dismiss(animated: true)
    }

    @objc private func pageControlSelectionAction(_ sender: UIPageControl) {
        let index = IndexPath(item: sender.currentPage, section: 0)
        pagesCollection.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
    }

    @objc private func nextPage() {
        let currentPageIndex = dataSource.currentPageIndex
        if currentPageIndex < dataSource.pageModels.count - 1 {
            // Next button tapped
            track(event: .nextStepTapped, for: currentPageIndex)
            let index = IndexPath(item: currentPageIndex + 1, section: 0)
            pagesCollection.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
            dataSource.isProgrammaticScroll = true
        } else {
            getStartedButtonAction()
        }
    }

    private func getStartedButtonAction() {
        track(event: .getStartedTapped, for: dataSource.currentPageIndex)
        close()
    }

    private func track(event: GiniAnalyticsEvent, for pageIndex: Int) {
        let pageModel = dataSource.pageModels[pageIndex]
        let currentPageScreenName = pageModel.analyticsScreen
        var eventProperties = [GiniAnalyticsProperty]()
        if pageModel.isCustom {
            eventProperties.append(.init(key: .customOnboardingTitle, value: pageModel.page.title))
        }
        GiniAnalyticsManager.track(event: event,
                                   screenNameString: currentPageScreenName,
                                   properties: eventProperties)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        // Calculate the current visible page index
        let visiblePageIndex = Int(round(pagesCollection.contentOffset.x / pagesCollection.bounds.width))

        dataSource.isProgrammaticScroll = true
        // Invalidate layout before the rotation begins
        pagesCollection.collectionViewLayout.invalidateLayout()

        // Use the coordinator to synchronize your changes with the system's rotation animation
        coordinator.animate(alongsideTransition: { _ in
            // Perform adjustments within the animation block to avoid jumps or flickers
            UIView.performWithoutAnimation {
                // Update the collection view's offset for the new orientation
                let newOffset = CGPoint(x: CGFloat(visiblePageIndex) * size.width, y: 0)
                self.pagesCollection.setContentOffset(newOffset, animated: false)
            }
        }) { _ in
            // Reset the flag after the transition completes
            self.dataSource.isProgrammaticScroll = false
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        pagesCollection.collectionViewLayout.invalidateLayout()
    }

    deinit {
        navigationBarBottomAdapter?.onDeinit()
    }
}

extension OnboardingViewController: OnboardingScreen {
    func didScroll(pageIndex: Int) {
        guard pageControl.currentPage != pageIndex else { return }

        sendGiniAnalyticsEventPageSwiped()
        configureNavigationButtons(for: pageIndex)
        pageControl.currentPage = pageIndex
    }

    private func sendGiniAnalyticsEventPageSwiped() {
        // Ignore events triggered by programmatic scrolling.
        guard !dataSource.isProgrammaticScroll else { return }

        // Registers the `pageSwiped` event for the page swiped action, tracking based on the page from which the swipe was triggered.
        // `pageControl.currentPage` should be updated after this method is called as it is done in `didScroll(pageIndex: Int)` method
        track(event: .pageSwiped, for: pageControl.currentPage)
    }

    private func configureNavigationButtons(for pageIndex: Int) {
        switch pageIndex {
        case dataSource.pageModels.count - 1:
            if configuration.bottomNavigationBarEnabled,
                let bottomNavigationBar = bottomNavigationBar {
                navigationBarBottomAdapter?.showButtons(navigationButtons: [.getStarted],
                                                        navigationBar: bottomNavigationBar)
            } else {
                navigationItem.rightBarButtonItem = nil
                if nextButton != nil {
                    configureGetStartedButton()
                }
            }
        default:
            if configuration.bottomNavigationBarEnabled,
                let bottomNavigationBar = bottomNavigationBar {
                navigationBarBottomAdapter?.showButtons(navigationButtons: [.skip, .next],
                                                        navigationBar: bottomNavigationBar)
            } else {
                configureSkipButton()

                if nextButton != nil {
                    configureNextButton()
                }
            }
        }
    }
}

class CollectionFlowLayout: UICollectionViewFlowLayout {
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
