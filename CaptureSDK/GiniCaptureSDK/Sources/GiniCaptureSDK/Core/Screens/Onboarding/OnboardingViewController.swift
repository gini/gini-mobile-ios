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
    @IBOutlet weak var buttonCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewToPageControlConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewToViewBottomConstraint: NSLayoutConstraint!
    private var bottomPaddingPageIndicatorConstraint: NSLayoutConstraint!
    private var navigationBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var skipBottomBarButton: MultilineTitleButton!
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
        pagesCollection.register(
            UINib(nibName: "OnboardingPageCellLandscapeIphone", bundle: giniCaptureBundle()),
            forCellWithReuseIdentifier: OnboardingPageCell.reuseIdentifier + "iphoneland")
        pagesCollection.register(
            UINib(nibName: "OnboardingPageCellLandscapeIphoneSmall", bundle: giniCaptureBundle()),
            forCellWithReuseIdentifier: OnboardingPageCell.reuseIdentifier + "iphoneland-small")
        pagesCollection.isPagingEnabled = true
        pagesCollection.showsHorizontalScrollIndicator = false
        pagesCollection.contentInsetAdjustmentBehavior = .never
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
        updatePageControlAndNavigationButtons(at: 0)
    }

    private func setupView() {
        view.backgroundColor = GiniColor(light: UIColor.GiniCapture.light2, dark: UIColor.GiniCapture.dark2).uiColor()
        configureCollectionView()
        configureBasicNavigation()
        if configuration.bottomNavigationBarEnabled {
            configureBottomNavigation()
        }
        configurePageControl()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if UIDevice.current.isIphone {
            if view.currentInterfaceOrientation.isLandscape {

                if configuration.onboardingNavigationBarBottomAdapter != nil {
                    bottomNavigationBar?.isHidden = false
                    nextButton?.isHidden = true
                    skipBottomBarButton?.isHidden = true
                } else {
                    bottomNavigationBar?.isHidden = true
                    nextButton?.isHidden = false
                    skipBottomBarButton?.isHidden = !configuration.bottomNavigationBarEnabled
                        || pageControl.currentPage == dataSource.pageModels.count - 1
                }

                let safeareaLeftPadding = view.safeAreaInsets.left
                let safeareaRightPadding = view.safeAreaInsets.right

                // icon leading constraint size from safearea
                let iconPadding: CGFloat = 56
                let iconWidth: CGFloat = 220
                let viewWidth = view.bounds.width

                // it'll be easier to start with the zero point of the view
                let startOffset = -viewWidth/2

                // distance from X=0 to icon view right edge x
                let toIconOffset = safeareaLeftPadding + iconPadding + iconWidth

                // width of stackview with texts, including padding. safe area isn't counted, as constraints are bound to safe area
                let textStackWidthWithPadding = viewWidth - toIconOffset - safeareaRightPadding

                // X of the right edge of the icon view + half of text stack width
                let xOffset = startOffset + toIconOffset + (textStackWidthWithPadding / 2)
                let isIphoneSmall = UIDevice.current.isSmallIphone

                buttonCenterXConstraint.constant = isIphoneSmall ? 0 : xOffset
                collectionViewToPageControlConstraint.isActive = false
                collectionViewToViewBottomConstraint.isActive = true
            } else {
                buttonCenterXConstraint.constant = 0
                collectionViewToViewBottomConstraint.isActive = false
                collectionViewToPageControlConstraint.isActive = true
                bottomNavigationBar?.isHidden = !configuration.bottomNavigationBarEnabled
                nextButton?.isHidden = configuration.bottomNavigationBarEnabled
                skipBottomBarButton?.isHidden = true
            }
            pagesCollection.reloadData()
        }
    }

    func postNotificationToCurrentCell() {
        let currentPage = pageControl.currentPage
        let indexPath = IndexPath(item: currentPage, section: 0)

        guard let currentCell = pagesCollection.cellForItem(at: indexPath) as? OnboardingPageCell else {
            // If the cell is not visible yet, accessibility focus cannot be set.
            return
        }

        // Post accessibility notification to focus on the current cell
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            UIAccessibility.post(notification: .layoutChanged, argument: currentCell)
        }
    }

    private func layoutBottomNavigationBar(_ navigationBar: UIView) {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false

        bottomPaddingPageIndicatorConstraint = navigationBar.topAnchor.constraint(
            equalTo: pageControl.bottomAnchor,
            constant: getBottomPaddingForPageController()
        )
        navigationBarHeightConstraint = navigationBar.heightAnchor.constraint(equalToConstant: getBottomBarHeight())
        NSLayoutConstraint.activate([
            bottomPaddingPageIndicatorConstraint,
            navigationBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBarHeightConstraint
        ])
    }

    private func configureBasicNavigation() {
        nextButton.titleLabel?.font = configuration.textStyleFonts[.bodyBold]
        nextButton.configure(with: GiniConfiguration.shared.primaryButtonConfiguration)
        nextButton.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        nextButton.titleLabel?.numberOfLines = 1

        skipBottomBarButton.titleLabel?.font = configuration.textStyleFonts[.bodyBold]
        skipBottomBarButton.configure(with: GiniConfiguration.shared.transparentButtonConfiguration)
        skipBottomBarButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)

        configureNextButton()
        configureSkipBottomButton()

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
        nextButton.isHidden = true
    }

    private func configureSkipButton() {
        skipButton.addAction(self, #selector(skipTapped))
        navigationItem.rightBarButtonItem = skipButton.barButton
    }

    private func configureGetStartedButton() {
        let getStartedTitle = NSLocalizedStringPreferredFormat("ginicapture.onboarding.getstarted",
                                                               comment: "Get Started button")

        nextButton.setTitle(getStartedTitle, for: .normal)
    }

    private func configureSkipBottomButton() {
        let title = NSLocalizedStringPreferredFormat("ginicapture.onboarding.skip",
                                                     comment: "Skip button")

        skipBottomBarButton.setTitle(title, for: .normal)
    }

    private func configureNextButton() {
        let nextButtonTitle = NSLocalizedStringPreferredFormat("ginicapture.onboarding.next",
                                                               comment: "Next button")

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
        let pageIndex = sender.currentPage
        let index = IndexPath(item: pageIndex, section: 0)
        pagesCollection.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
        updatePageControlAndNavigationButtons(at: pageIndex)
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

        if configuration.bottomNavigationBarEnabled {
            bottomPaddingPageIndicatorConstraint.constant = getBottomPaddingForPageController()
            navigationBarHeightConstraint.constant = getBottomBarHeight()
        }

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
        }) { [weak self] _ in
            // Reset the flag after the transition completes
            self?.dataSource.isProgrammaticScroll = false
            self?.notifyLayoutChangedAfterRotation()
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        pagesCollection.collectionViewLayout.invalidateLayout()
    }

    /// This is to notify VoiceOver that the layout changed with the presentation of the Onboarding screen. The delay is needed to ensure that
    /// VoiceOver has already finished processing the UI changes.
    private func notifyLayoutChangedAfterRotation() {
        // --- VoiceOver focus handling ---
        // Without this small delay, VoiceOver often fails to move focus to the current cell
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.postNotificationToCurrentCell()
        }
    }

    deinit {
        navigationBarBottomAdapter?.onDeinit()
    }

    private func updatePageControlAndNavigationButtons(at pageIndex: Int) {
        configureNavigationButtons(for: pageIndex)
        pageControl.currentPage = pageIndex
    }
}

extension OnboardingViewController: OnboardingScreen {
    func didScroll(pageIndex: Int) {
        guard pageControl.currentPage != pageIndex else { return }

        sendGiniAnalyticsEventPageSwiped()
        updatePageControlAndNavigationButtons(at: pageIndex)
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
                skipBottomBarButton.isHidden = true
                if nextButton != nil {
                    configureGetStartedButton()
                }
            } else {
                navigationItem.rightBarButtonItem = nil
                if nextButton != nil {
                    configureGetStartedButton()
                }
            }
        default:
            if configuration.bottomNavigationBarEnabled,
                let bottomNavigationBar = bottomNavigationBar,
               configuration.onboardingNavigationBarBottomAdapter == nil {
                navigationBarBottomAdapter?.showButtons(navigationButtons: [.skip, .next],
                                                        navigationBar: bottomNavigationBar)
                skipBottomBarButton.isHidden = !(UIDevice.current.isIphone &&
                                                 view.currentInterfaceOrientation.isLandscape)
                if nextButton != nil {
                    configureNextButton()
                }
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

private extension OnboardingViewController {
    enum Constants {
        static let pageControlBottomBarPadding: CGFloat = 46
        static let pageControlBottomBarPaddingLandscape: CGFloat = 0
        static let bottomBarHeightPortrait: CGFloat = 110
        static let bottomBarHeightLandscape: CGFloat = 64
    }

    func getBottomPaddingForPageController() -> CGFloat {
        if isiPhoneAndLandscape() {
            return Constants.pageControlBottomBarPaddingLandscape
        }
        return Constants.pageControlBottomBarPadding
    }

    func getBottomBarHeight() -> CGFloat {
        if isiPhoneAndLandscape() {
            return Constants.bottomBarHeightLandscape
        }
        return Constants.bottomBarHeightPortrait
    }

    func isiPhoneAndLandscape() -> Bool {
        return UIDevice.current.isIphone && view.currentInterfaceOrientation.isLandscape
    }
}
