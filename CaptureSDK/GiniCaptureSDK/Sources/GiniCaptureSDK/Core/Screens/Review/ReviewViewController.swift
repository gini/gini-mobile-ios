//
//  ReviewViewController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import Photos
// swiftlint:disable file_length
/**
 The ReviewViewControllerDelegate protocol defines methods that allow you to handle user actions in the
 ReviewViewControllerDelegate
 (tap add, delete...
 */
public protocol ReviewViewControllerDelegate: AnyObject {
    /**
     Called when a user deletes one of the pages.
     
     - parameter viewController: `ReviewViewController` where the pages are reviewed.
     - parameter page: Page deleted.
     */
    func review(_ viewController: ReviewViewController, didDelete page: GiniCapturePage)

    /**
     Called when a user taps on the error action when the errored page
     
     - parameter viewController: `ReviewViewController` where the pages are reviewed.
     - parameter errorAction: `NoticeActionType` selected.
     - parameter page: Page where the error action has been triggered
     */
    func review(_ viewController: ReviewViewController, didTapRetryUploadFor page: GiniCapturePage)

    /**
     Called when a user taps on the add page button
     
     - parameter viewController: `ReviewViewController` where the pages are reviewed.
     */
    func reviewDidTapAddImage(_ viewController: ReviewViewController)
    /**
     Called when a user taps on the process documents button

     - parameter viewController: `ReviewViewController` where the pages are reviewed.
     */
    func reviewDidTapProcess(_ viewController: ReviewViewController, shouldSaveToGallery: Bool)

    /**
     Called when a user taps on a page

     - parameter viewController: `ReviewViewController` where the pages are reviewed.
     - parameter page: Page that the user selected
     */
    func review(_ viewController: ReviewViewController, didSelectPage page: GiniCapturePage)
}

/**
  The `ReviewViewController` provides a custom review screen. The user has the option to check
  for blurriness and document orientation. If the result is not satisfying, the user can return to the camera screen.
  The photo should be uploaded to Gini’s backend immediately after having been taken as it is safe to assume that
  in most cases the photo is good enough to be processed further.
  */
public final class ReviewViewController: UIViewController {

    /**
     The object that acts as the delegate of the review view controller.
     */
    public weak var delegate: ReviewViewControllerDelegate?

    var pages: [GiniCapturePage]
    var resetToEnd = false
    fileprivate let giniConfiguration: GiniConfiguration
    fileprivate lazy var presenter: ReviewCollectionCellPresenter = {
        let presenter = ReviewCollectionCellPresenter()
        presenter.delegate = self
        return presenter
    }()

    private var navigationBarBottomAdapter: ReviewScreenBottomNavigationBarAdapter?

    // MARK: - UI initialization

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8

        var collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = GiniColor(light: .GiniCapture.light2,
                                               dark: .GiniCapture.dark2).uiColor()
        collection.dataSource = self
        collection.delegate = self
        collection.showsHorizontalScrollIndicator = false
        collection.register(ReviewCollectionCell.self,
                            forCellWithReuseIdentifier: ReviewCollectionCell.reuseIdentifier)

        collection.isScrollEnabled = false
        collection.contentInsetAdjustmentBehavior = .never

        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self,
                                                           action: #selector(swipeHandler(sender:)))
        swipeLeftRecognizer.direction = .left
        collection.addGestureRecognizer(swipeLeftRecognizer)

        let swipeRightRecognizer = UISwipeGestureRecognizer(target: self,
                                                            action: #selector(swipeHandler(sender:)))
        swipeRightRecognizer.direction = .right
        collection.addGestureRecognizer(swipeRightRecognizer)
        return collection
    }()

    private lazy var tipLabel: UILabel = {
        var tipLabel = UILabel()
        tipLabel.font = giniConfiguration.textStyleFonts[.caption2]
        tipLabel.textAlignment = .center
        tipLabel.adjustsFontForContentSizeCategory = true
        tipLabel.translatesAutoresizingMaskIntoConstraints = false
        tipLabel.textColor = GiniColor(light: .GiniCapture.dark1,
                                       dark: .GiniCapture.light1).uiColor()
        tipLabel.isAccessibilityElement = true
        tipLabel.numberOfLines = 0
        tipLabel.text = NSLocalizedStringPreferredFormat("ginicapture.multipagereview.description",
                                                         comment: "Tip on review screen")

        return tipLabel
    }()

    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = GiniColor(light: .GiniCapture.dark1,
                                                       dark: .GiniCapture.light1)
                                                       .uiColor().withAlphaComponent(0.3)
        pageControl.currentPageIndicatorTintColor = GiniColor(light: .GiniCapture.dark1,
                                                              dark: .GiniCapture.light1).uiColor()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.isAccessibilityElement = true
        pageControl.addTarget(self,
                              action: #selector(pageControlSelectionAction(_:)),
                              for: .valueChanged)

        return pageControl
    }()

    private lazy var saveToGalleryView: SaveToGalleryView = {
        let view = SaveToGalleryView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var processButton: MultilineTitleButton = {
        let button = MultilineTitleButton()
        button.configure(with: giniConfiguration.primaryButtonConfiguration)
        button.titleLabel?.font = giniConfiguration.textStyleFonts[.bodyBold]
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedStringPreferredFormat("ginicapture.multipagereview.mainButtonTitle",
                                                        comment: "Process button title"), for: .normal)
        button.addTarget(self, action: #selector(didTapProcessDocument), for: .touchUpInside)
        button.isAccessibilityElement = true
        return button
    }()

    private lazy var addPagesButton: BottomLabelButton = {
        let addPagesButton = BottomLabelButton()
        addPagesButton.translatesAutoresizingMaskIntoConstraints = false
        addPagesButton.setupButton(with: UIImageNamedPreferred(named: "plus_icon") ?? UIImage(),
                                   name: NSLocalizedStringPreferredFormat(
                                    "ginicapture.multipagereview.secondaryButtonTitle",
                                        comment: "Add pages button title"))
        addPagesButton.accessibilityValue = NSLocalizedStringPreferredFormat(
                                                "ginicapture.multipagereview.secondaryButton.accessibility",
                                                comment: "Add pages")
        addPagesButton.isHidden = !giniConfiguration.multipageEnabled
        addPagesButton.actionLabel.font = giniConfiguration.textStyleFonts[.bodyBold]
        addPagesButton.configure(with: giniConfiguration.addPageButtonConfiguration)
        addPagesButton.didTapButton = { [weak self] in
            guard let self = self else { return }
            self.didTapAddPages()
        }
        addPagesButton.isAccessibilityElement = true
        addPagesButton.accessibilityTraits = .button
        return addPagesButton
    }()

    private lazy var buttonsStackViewContainer: UIStackView = {
        let view = UIStackView(arrangedSubviews: [processButton])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = Constants.padding
        return view
    }()

    private lazy var buttonsContainerWrapper: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private lazy var optionsStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [saveToGalleryView])

        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical

        return view
    }()

    private var bottomNavigationBar: UIView?

    private var loadingIndicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        indicatorView.hidesWhenStopped = true
        indicatorView.style = .large
        indicatorView.color = GiniColor(light: .GiniCapture.dark3,
                                        dark: .GiniCapture.light3).uiColor()
        return indicatorView
    }()

    private var loadingIndicator: UIView?

    private lazy var collectionViewHeightConstraint = collectionView.heightAnchor.constraint(
                                                      equalToConstant: view.frame.height * 0.5)

    private var currentPage: Int = 0 {
        didSet {
            setCellStatus(for: currentPage, isActive: true)
        }
    }

    // This is needed in order to "catch" the screen rotation on the modally presented viewcontroller
    private var previousScreenHeight: CGFloat = UIScreen.main.bounds.height

    // MARK: - Constraints

    private lazy var scrollViewConstraints: [NSLayoutConstraint] = [
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    ]

    private lazy var contentViewConstraints: [NSLayoutConstraint] = {
        let heightConstraint = contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        heightConstraint.priority = .defaultLow

        return [
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            heightConstraint,
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor)
        ]
    }()

    private lazy var tipLabelConstraints: [NSLayoutConstraint] = {
        return [
            tipLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.padding),
            tipLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                              constant: Constants.tipLabelPadding),
            tipLabel.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor)
        ]
    }()

    private lazy var collectionViewConstraints: [NSLayoutConstraint] = {
        let trailingConstraint = collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        trailingConstraint.priority = .defaultLow

        return [
            collectionView.topAnchor.constraint(equalTo: tipLabel.bottomAnchor,
                                                constant: Constants.padding),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trailingConstraint,
            collectionViewHeightConstraint
        ]
    }()

    private lazy var collectionViewHorizontalConstraints: [NSLayoutConstraint] = {
        return [
            collectionView.topAnchor.constraint(equalTo: tipLabel.bottomAnchor,
                                                constant: Constants.padding),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: optionsStackView.leadingAnchor,
                                                     constant: -Constants.collectionViewHorizontalSpaceLandscape),
            collectionViewHeightConstraint
        ]
    }()

    private lazy var pageControlConstraints: [NSLayoutConstraint] = [
        pageControl.topAnchor.constraint(equalTo: collectionView.bottomAnchor,
                                         constant: Constants.pageControlTopConstant),
        pageControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        pageControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)]

    private lazy var pageControlHorizontalConstraints: [NSLayoutConstraint] = [
        pageControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                            constant: -Constants.largePadding),
        pageControl.topAnchor.constraint(equalTo: collectionView.bottomAnchor,
                                         constant: Constants.largePadding),
        pageControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        pageControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                              constant: -Constants.trailingCollectionPadding)
    ]

    private lazy var optionsStackViewConstraints: [NSLayoutConstraint] = {
        let isSmallDevice = UIDevice.current.isNonNotchSmallScreen()

        let bottomPadding = isSmallDevice ?
        Constants.buttonsContainerBottomPaddingForSmallDevice :
        Constants.buttonsContainerBottomPadding

        return [optionsStackView.topAnchor.constraint(equalTo: pageControl.bottomAnchor,
                                                      constant: Constants.saveToGalleryTopConstant(pages.count)),
                optionsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                          constant: Constants.padding),
                optionsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                           constant: -Constants.padding),
                optionsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                         constant: -bottomPadding)
        ]
    }()

    private lazy var optionsStackViewHorizontalConstraints: [NSLayoutConstraint] = [
        optionsStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        optionsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                         constant: -Constants.padding),
        optionsStackView.widthAnchor.constraint(equalTo: view.widthAnchor,
                                                multiplier: 0.38)
    ]

    private lazy var optionsStackViewIpadConstraints: [NSLayoutConstraint] = [
        optionsStackView.topAnchor.constraint(equalTo: pageControl.bottomAnchor,
                                              constant: Constants.saveToGalleryTopConstant(pages.count)),
        optionsStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        optionsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                 constant: -Constants.bottomPadding)
    ]

    private lazy var optionsStackViewConstraintsWithBottomBar: [NSLayoutConstraint] = {
        // Account for bottom navigation bar height plus padding
        let bottomPadding = Constants.bottomNavigationBarHeight + Constants.padding

        return [
            optionsStackView.topAnchor.constraint(equalTo: pageControl.bottomAnchor,
                                                  constant: Constants.saveToGalleryTopConstant(pages.count)),
            optionsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                      constant: Constants.padding),
            optionsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                       constant: -Constants.padding),
            optionsStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor,
                                                     constant: -bottomPadding)
        ]
    }()

    private lazy var optionsStackViewIpadConstraintsWithBottomBar: [NSLayoutConstraint] = {
        // Account for bottom navigation bar height plus padding
        let bottomPadding = Constants.bottomNavigationBarHeight + Constants.padding

        return [
            optionsStackView.topAnchor.constraint(equalTo: pageControl.bottomAnchor,
                                                  constant: Constants.saveToGalleryTopConstant(pages.count)),
            optionsStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            optionsStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor,
                                                     constant: -bottomPadding)
        ]
    }()

    private lazy var processButtonConstraints: [NSLayoutConstraint] = [
        processButton.widthAnchor.constraint(greaterThanOrEqualToConstant: Constants.buttonSize.width),
        processButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.buttonSize.height)
    ]

    private lazy var buttonsStackViewContainerConstraints: [NSLayoutConstraint] = [
        buttonsStackViewContainer.topAnchor.constraint(equalTo: buttonsContainerWrapper.topAnchor,
                                                       constant: 0),
        buttonsStackViewContainer.bottomAnchor.constraint(equalTo: buttonsContainerWrapper.bottomAnchor,
                                                          constant: 0),
        buttonsStackViewContainer.centerXAnchor.constraint(equalTo: optionsStackView.centerXAnchor)
    ]

    private lazy var bottomNavigationBarAdditionalConstraints: [NSLayoutConstraint] = [
        pageControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                            constant: -Constants.pageControlBottomPadding),
        collectionView.bottomAnchor.constraint(greaterThanOrEqualTo: pageControl.topAnchor,
                                               constant: -Constants.largePadding)
    ]

    private var bottomNavigationBarConstraints: [NSLayoutConstraint] = []

    private var shouldShowSaveToGalleryView: Bool {
        let isSaveToGalleryAllowed: Bool

        // TODO: this logic is in progress will be covered in the ticket: PP-2084
        let status = PHPhotoLibrary.authorizationStatus()
        if #available(iOS 14, *) {
            // iOS 14+ uses the new authorization API with access levels
            isSaveToGalleryAllowed = status == .authorized || status == .limited || status == .notDetermined
        } else {
            // iOS 13 uses the legacy authorization API
            isSaveToGalleryAllowed = status == .authorized || status == .notDetermined
        }

        let isSaveToGalleryEnabled = giniConfiguration.savePhotosLocallyEnabled
        let pagesContainsPhotos = pages.contains(where: { !$0.document.isImported })

        return isSaveToGalleryAllowed && isSaveToGalleryEnabled && pagesContainsPhotos
    }

    // MARK: - Init

    /**
     Called to initialize the ReviewViewController

     - parameter pages: the documents to be initalized with
     - parameter giniConfiguration: the configuration of the SDK

     - note: Internal usage only.
     */

    public init(pages: [GiniCapturePage], giniConfiguration: GiniConfiguration) {
        self.pages = pages
        self.giniConfiguration = giniConfiguration
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(imageDocuments:) has not been implemented")
    }
}

// MARK: - BottomNavigation

extension ReviewViewController {
    private func configureBottomNavigationBar() {
        if giniConfiguration.bottomNavigationBarEnabled {
            if let bottomBar = giniConfiguration.reviewNavigationBarBottomAdapter {
                navigationBarBottomAdapter = bottomBar
            } else {
                navigationBarBottomAdapter = DefaultReviewBottomNavigationBarAdapter()
            }
            navigationBarBottomAdapter?.setMainButtonClickedActionCallback { [weak self] in
                guard let self = self else { return }
                self.didTapProcessDocument()
            }
            navigationBarBottomAdapter?.setSecondaryButtonClickedActionCallback { [weak self] in
                guard let self = self else { return }
                GiniAnalyticsManager.track(event: .addPagesTapped, screenName: .review)
                self.setCellStatus(for: self.currentPage, isActive: false)
                self.delegate?.reviewDidTapAddImage(self)
            }

            if let navigationBar =
                navigationBarBottomAdapter?.injectedView() {
                view.addSubview(navigationBar)
                layoutBottomNavigationBar(navigationBar)
            }
        }
    }

    private func layoutBottomNavigationBar(_ navigationBar: UIView) {
        bottomNavigationBar = navigationBar
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationBar)

        bottomNavigationBarConstraints = [
            navigationBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: Constants.bottomNavigationBarHeight)
        ]

        NSLayoutConstraint.activate(bottomNavigationBarConstraints)
        view.bringSubviewToFront(navigationBar)
        view.layoutSubviews()
    }
}

// MARK: - UIViewController

extension ReviewViewController {
    override public func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        addConstraints()
        configureBottomNavigationBar()
        addLoadingView()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !giniConfiguration.multipageEnabled || pages.count == 1 {
            setCellStatus(for: 0, isActive: true)
        } else {
            if resetToEnd {
                resetToEnd = false
            }
            setCellStatus(for: currentPage, isActive: true)
        }
        collectionView.reloadData()

        GiniAnalyticsManager.trackScreenShown(screenName: .review)
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size = cellSize()
        collectionViewHeightConstraint.constant = size.height + 4
        updateLayout()
        DispatchQueue.main.async {
            guard self.previousScreenHeight != UIScreen.main.bounds.height else { return }
            guard self.pages.count > 1 else { return }
            self.setCellStatus(for: self.currentPage, isActive: false)
            self.collectionView.reloadData()

            self.scrollToItem(at: IndexPath(row: self.currentPage, section: 0))

            self.previousScreenHeight = UIScreen.main.bounds.height
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.setCellStatus(for: self.currentPage, isActive: true)
            }
        }
    }

    private func updateLayout() {
        if UIDevice.current.isIpad {
            updateLayoutForIpad()
        } else {
            updateLayoutForIphone()
        }
    }

    // MARK: iPad - layout updates
    private func updateLayoutForIpad() {
        buttonsStackViewContainer.spacing = Constants.buttonContainerSpacing
        optionsStackView.spacing = shouldShowSaveToGalleryView ? Constants.saveToGalleryBottomConstant : 0

        // Handle bottom navigation bar placement (always use portrait behavior)
        if giniConfiguration.bottomNavigationBarEnabled {
            removeButtonsFromOptionsStack()
        } else {
            // Ensure buttons are in optionsStackView when bottom nav is disabled
            if buttonsStackViewContainer.superview != buttonsContainerWrapper {
                buttonsContainerWrapper.addSubview(buttonsStackViewContainer)
            }
            if !optionsStackView.arrangedSubviews.contains(buttonsContainerWrapper) {
                optionsStackView.addArrangedSubview(buttonsContainerWrapper)
            }
            NSLayoutConstraint.activate(buttonsStackViewContainerConstraints)
        }

        // Deactivate all constraints first
        NSLayoutConstraint.deactivate(pageControlConstraints
                                      + optionsStackViewIpadConstraints
                                      + optionsStackViewIpadConstraintsWithBottomBar
                                      + collectionViewConstraints)

        // iPad always uses portrait-style constraints regardless of orientation
        // Activate appropriate constraints based on bottom navigation bar state
        let constraintsToActivate = giniConfiguration.bottomNavigationBarEnabled
        ? pageControlConstraints + optionsStackViewIpadConstraintsWithBottomBar + collectionViewConstraints
        : pageControlConstraints + optionsStackViewIpadConstraints + collectionViewConstraints

        NSLayoutConstraint.activate(constraintsToActivate)
    }

    // MARK: iPhone - layout updates
    private func updateLayoutForIphone() {
        let isLandscape = UIDevice.current.isLandscape

        configureButtonContainer(isLandscape: isLandscape)
        handleBottomNavigationBarPlacement(isLandscape: isLandscape)
        updateiPhoneConstraints(isLandscape: isLandscape)
    }

    private func updateiPhoneConstraints(isLandscape: Bool) {
        let shouldShowBottomNav = giniConfiguration.bottomNavigationBarEnabled && !isLandscape

        let portraitConstraints = getPortraitConstraints(shouldShowBottomNav: shouldShowBottomNav)
        let landscapeConstraints = pageControlHorizontalConstraints
        + optionsStackViewHorizontalConstraints
        + collectionViewHorizontalConstraints

        let constraintsToActivate = isLandscape ? landscapeConstraints : portraitConstraints
        let constraintsToDeactivate = isLandscape
        ? getPortraitConstraintsToDeactivate()
        : getLandscapeConstraintsToDeactivate()

        NSLayoutConstraint.deactivate(constraintsToDeactivate)
        NSLayoutConstraint.activate(constraintsToActivate)
    }

    private func getPortraitConstraints(shouldShowBottomNav: Bool) -> [NSLayoutConstraint] {
        if shouldShowBottomNav {
            // Portrait with bottom navigation bar
            return pageControlConstraints
            + optionsStackViewConstraintsWithBottomBar
            + collectionViewConstraints
        } else {
            // Portrait without bottom navigation bar
            return pageControlConstraints
            + optionsStackViewConstraints
            + collectionViewConstraints
        }
    }

    // MARK: - Deactivating constraints - iPhone
    private func getPortraitConstraintsToDeactivate() -> [NSLayoutConstraint] {
        return pageControlConstraints
        + optionsStackViewConstraints
        + optionsStackViewConstraintsWithBottomBar
        + collectionViewConstraints
    }

    private func getLandscapeConstraintsToDeactivate() -> [NSLayoutConstraint] {
        return pageControlHorizontalConstraints
        + optionsStackViewHorizontalConstraints
        + collectionViewHorizontalConstraints
        + optionsStackViewConstraintsWithBottomBar
    }

    private func configureButtonContainer(isLandscape: Bool) {
        buttonsStackViewContainer.axis = isLandscape ? .vertical : .horizontal

        if isLandscape {
            buttonsStackViewContainer.spacing = shouldShowSaveToGalleryView ?
            Constants.buttonContainerWithSaveToGalleryHorizontalSpacing : Constants.buttonContainerSpacing
            optionsStackView.spacing = Constants.saveToGalleryBottomConstant
        } else {
            buttonsStackViewContainer.spacing = Constants.buttonContainerSpacing
            optionsStackView.spacing = shouldShowSaveToGalleryView ? Constants.saveToGalleryBottomConstant : 0
        }
    }

    private func handleBottomNavigationBarPlacement(isLandscape: Bool) {
        guard giniConfiguration.bottomNavigationBarEnabled else { return }

        if isLandscape && UIDevice.current.isIphone {
            // iPhone landscape: buttons in optionsStackView
            setupButtonsInOptionsStack()
        } else {
            // iPhone portrait or iPad (both orientations): buttons in bottom nav bar
            removeButtonsFromOptionsStack()
        }
    }

    private func setupButtonsInOptionsStack() {
        // In landscape, add buttons to optionsStackView (like when bottom nav is disabled)

        // Deactivate bottom navigation bar constraints before removing it
        NSLayoutConstraint.deactivate(bottomNavigationBarConstraints)
        bottomNavigationBar?.removeFromSuperview()

        // Add buttonsStackViewContainer to buttonsContainerWrapper if not already there
        if buttonsStackViewContainer.superview != buttonsContainerWrapper {
            buttonsContainerWrapper.addSubview(buttonsStackViewContainer)
        }

        // Add buttonsContainerWrapper to optionsStackView if not already there
        if !optionsStackView.arrangedSubviews.contains(buttonsContainerWrapper) {
            optionsStackView.addArrangedSubview(buttonsContainerWrapper)
        }

        // Activate button container constraints when adding to optionsStackView
        NSLayoutConstraint.activate(buttonsStackViewContainerConstraints)

        addLoadingView()
    }

    private func removeButtonsFromOptionsStack() {
        // In portrait, use bottom navigation bar and remove buttons from optionsStackView

        // Add bottom navigation bar back if it's not in the view hierarchy
        if let bottomBar = bottomNavigationBar, bottomBar.superview == nil {
            view.addSubview(bottomBar)
            NSLayoutConstraint.activate(bottomNavigationBarConstraints)
            view.bringSubviewToFront(bottomBar)
        }

        // Deactivate button container constraints before removing from optionsStackView
        NSLayoutConstraint.deactivate(buttonsStackViewContainerConstraints)

        // Remove buttonsContainerWrapper from optionsStackView if it's there
        if optionsStackView.arrangedSubviews.contains(buttonsContainerWrapper) {
            optionsStackView.removeArrangedSubview(buttonsContainerWrapper)
            buttonsContainerWrapper.removeFromSuperview()
        }

        loadingIndicator?.removeFromSuperview()
    }

    private func setupView() {
        title = NSLocalizedStringPreferredFormat("ginicapture.multipagereview.title",
                                                 comment: "Screen title")
        view.backgroundColor = GiniColor(light: .GiniCapture.light2,
                                         dark: .GiniCapture.dark2).uiColor()

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(tipLabel)
        contentView.addSubview(collectionView)
        contentView.addSubview(pageControl)
        contentView.addSubview(optionsStackView)

        if giniConfiguration.multipageEnabled {
            buttonsStackViewContainer.addArrangedSubview(addPagesButton)
        }

        if !giniConfiguration.bottomNavigationBarEnabled {
            buttonsContainerWrapper.addSubview(buttonsStackViewContainer)
            optionsStackView.addArrangedSubview(buttonsContainerWrapper)
        }

        edgesForExtendedLayout = []
    }

    // MARK: - Loading indicator

    private func addLoadingView() {
        let isBottomNavDisabled = !giniConfiguration.bottomNavigationBarEnabled
        let isButtonInView = buttonsStackViewContainer.superview != nil
        let isOnIphone = UIDevice.current.isIphone

        guard isBottomNavDisabled || (isButtonInView && isOnIphone) else { return }
        if let loadingIndicator {
            loadingIndicator.removeFromSuperview()
            self.loadingIndicator = nil
        }

        let loadingIndicator: UIView

        if let customLoadingIndicator = giniConfiguration.onButtonLoadingIndicator?.injectedView() {
            loadingIndicator = customLoadingIndicator
        } else {
            loadingIndicator = loadingIndicatorView
        }

        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
        view.bringSubviewToFront(loadingIndicator)

        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: processButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: processButton.centerYAnchor),
            loadingIndicator.widthAnchor.constraint(equalToConstant: Constants.loadingIndicatorSize),
            loadingIndicator.heightAnchor.constraint(equalToConstant: Constants.loadingIndicatorSize)
        ])
        self.loadingIndicator = loadingIndicator
    }

    private func showAnimation() {
        if let loadingIndicator = giniConfiguration.onButtonLoadingIndicator {
            loadingIndicator.startAnimation()
        } else {
            loadingIndicatorView.startAnimating()
        }
    }

    private func hideAnimation() {
        if let loadingIndicator = giniConfiguration.onButtonLoadingIndicator {
            loadingIndicator.stopAnimation()
        } else {
            loadingIndicatorView.stopAnimating()
        }
    }

    /**
     Updates the collections with the given pages.
     
     - parameter pages: Pages to be used in the collections.
     */

    public func updateCollections(with pages: [GiniCapturePage], finishedUpload: Bool = true) {
        DispatchQueue.main.async {
            if self.giniConfiguration.bottomNavigationBarEnabled {
                self.navigationBarBottomAdapter?.set(loadingState: !finishedUpload)
            }

            if self.giniConfiguration.multipageEnabled {
                if finishedUpload {
                    self.processButton.alpha = 1
                    self.processButton.isEnabled = true
                    self.hideAnimation()
                    return
                }

                self.processButton.alpha = 0.3
                self.processButton.isEnabled = false
                self.showAnimation()
            }
        }

        self.pages = pages
        // Check how to avoid the call of this method because is causing a crash if the view is not yet loaded
        // The parent method is called from GiniScreenAPICoordinator -> addToDocuments
        updateViewForNewPages()

        guard !finishedUpload else { return }
        if pages.isNotEmpty {
            currentPage = pages.count - 1
        }
        collectionView.reloadData()
        // Update cell status only if pages not empty
        if pages.isNotEmpty {
            guard pages.count > 1 else { return }
            self.scrollToItem(at: IndexPath(row: currentPage, section: 0))
            pageControl.currentPage = currentPage
        }
    }

    private func updateViewForNewPages() {
        saveToGalleryView.isHidden = !shouldShowSaveToGalleryView

        if isViewLoaded && view.window != nil {
            updateLayout()
        }
    }
}

// MARK: - Private methods

extension ReviewViewController {
    private func addConstraints() {
        collectionViewHeightConstraint.priority = .defaultLow

        NSLayoutConstraint.activate(scrollViewConstraints)
        NSLayoutConstraint.activate(contentViewConstraints)
        NSLayoutConstraint.activate(tipLabelConstraints)
        NSLayoutConstraint.activate(processButtonConstraints) // botton size constraints

        // Only add button container constraints when bottomNavigationBar is disabled
        if !giniConfiguration.bottomNavigationBarEnabled {
            NSLayoutConstraint.activate(buttonsStackViewContainerConstraints)
        }
        // Let updateLayout() handle device/orientation-specific constraints:
        // - collectionViewConstraints (portrait) vs collectionViewHorizontalConstraints (landscape)
        // - pageControlConstraints (portrait) vs pageControlHorizontalConstraints (landscape)
        // - optionsStackViewConstraints (portrait) vs optionsStackViewHorizontalConstraints (landscape)
        updateLayout()
    }

    private func scrollToItem(at indexPath: IndexPath) {
        let iphoneLandscape = UIDevice.current.isIphoneAndLandscape
        let scrollPosition: UICollectionView.ScrollPosition = {
            guard iphoneLandscape else {
                return .centeredHorizontally
            }
            if pages.count > 2, indexPath.row == 0 {
                return .left
            } else if self.pages.count > 3, indexPath.row == (pages.count - 1) {
                return .right
            } else {
                return .centeredHorizontally
            }
        }()
        if scrollPosition == .centeredHorizontally {
            collectionView.contentInset.left = 0
            collectionView.contentInset.right = 0
        } else if scrollPosition == .left || scrollPosition == .right {
            let cellWidth = cellSize().width
            let cellSpacing = {
                guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
                    return 0.0
                }
                return layout.minimumInteritemSpacing
            }()
            let sheetItemCount: CGFloat = 3
            let sheetFullWidth = (cellWidth * sheetItemCount) + (cellSpacing * (sheetItemCount - 1))
            let viewWidth = collectionView.frame.width

            let padding = (viewWidth - sheetFullWidth) / 2
            collectionView.contentInset.left = padding
            collectionView.contentInset.right = padding
        }

        collectionView.scrollToItem(at: indexPath, at: scrollPosition, animated: true)
    }

    @objc
    private func pageControlSelectionAction(_ sender: UIPageControl) {
        let index = IndexPath(item: sender.currentPage, section: 0)
        setCellStatus(for: currentPage, isActive: false)
        currentPage = sender.currentPage
        scrollToItem(at: index)
    }

    @objc
    private func didTapProcessDocument() {
        let eventProperties = [GiniAnalyticsProperty(key: .numberOfPagesScanned,
                                                     value: pages.count)]

        GiniAnalyticsManager.track(event: .proceedTapped,
                                   screenName: .review,
                                   properties: eventProperties)
        delegate?.reviewDidTapProcess(self, shouldSaveToGallery: saveToGalleryView.isOn)
    }

    private func deleteItem(at indexPath: IndexPath) {
        let pageToDelete = pages[indexPath.row]
        pages.remove(at: indexPath.row)
        collectionView.deleteItems(at: [indexPath])
        setCurrentPage(basedOn: collectionView)
        delegate?.review(self, didDelete: pageToDelete)
        updateViewForNewPages()
        if !pages.isEmpty {
            scrollToItem(at: IndexPath(row: currentPage, section: 0))
        }
    }

    private func didTapAddPages() {
        GiniAnalyticsManager.track(event: .addPagesTapped, screenName: .review)
        setCellStatus(for: currentPage, isActive: false)
        delegate?.reviewDidTapAddImage(self)
    }

    @objc
    private func swipeHandler(sender: UISwipeGestureRecognizer) {
        guard pages.count > 1 else { return }
        if sender.direction == .left {
            guard currentPage < pages.count - 1 else { return }
            setCellStatus(for: currentPage, isActive: false)
            currentPage += 1
            scrollToItem(at: IndexPath(row: currentPage, section: 0))
            pageControl.currentPage = currentPage

            GiniAnalyticsManager.track(event: .pageSwiped, screenName: .review)

        } else if sender.direction == .right {
            guard currentPage > 0 else { return }
            setCellStatus(for: currentPage, isActive: false)
            currentPage -= 1
            scrollToItem(at: IndexPath(row: currentPage, section: 0))
            pageControl.currentPage = currentPage

            GiniAnalyticsManager.track(event: .pageSwiped, screenName: .review)
        }
    }

    private func cellSize() -> CGSize {
        if UIDevice.current.isIpad {
            return cellSizeForIpad()
        } else {
            return cellSizeForiPhone()
        }
    }

    private func cellSizeForIpad() -> CGSize {
        // Calculate available space
        var availableHeight = view.bounds.height
        availableHeight -= 260 // Base overhead

        if giniConfiguration.bottomNavigationBarEnabled {
            availableHeight -= Constants.bottomNavigationBarHeight
            availableHeight -= Constants.padding
        }

        if shouldShowSaveToGalleryView {
            availableHeight -= (saveToGalleryView.frame.height
                                + Constants.saveToGalleryBottomConstant
                                + Constants.saveToGalleryTopConstant(pages.count))
        }

        let width = availableHeight / Constants.a4Ratio
        return CGSize(width: width, height: availableHeight)
    }

    private func cellSizeForiPhone() -> CGSize {
        let baseMultiplier = calculateHeightMultiplier()
        let height = view.bounds.height * baseMultiplier
        let width = height / Constants.a4Ratio
        return CGSize(width: width, height: height)
    }

    private func calculateHeightMultiplier() -> CGFloat {
        let isLandscape = UIDevice.current.isLandscape
        let isSmallDevice = UIDevice.current.isNonNotchSmallScreen()

        // Handle small devices (iPhone SE, iPhone 6/7/8, etc.)
        if isSmallDevice {
            if isLandscape {
                return Constants.smallDeviceLandscapeHeightMultiplier
            } else {
                // For small devices in portrait, use a smaller multiplier
                // to ensure everything fits on screen
                return Constants.smallDevicePortraitHeightMultiplier(giniConfiguration.bottomNavigationBarEnabled)
            }
        }

        if isLandscape {
            // Multiplier accounts for tip label, page control, safe areas, and paddings
            return Constants.landscapeHeightMultiplier
        } else {
            // Portrait multiplier based on device type and bottom navigation bar state
            var multiplier: CGFloat = view.safeAreaInsets.bottom > 0
            ? Constants.portraitHeightMultiplierWithSafeArea(giniConfiguration.bottomNavigationBarEnabled)
            : Constants.portraitHeightMultiplierWithoutSafeArea(giniConfiguration.bottomNavigationBarEnabled)

            // Adjust for saveToGalleryView in portrait only
            if shouldShowSaveToGalleryView {
                multiplier -= Constants.saveToGalleryHeightAdjustment
            }

            return multiplier
        }
    }
}

// MARK: UICollectionViewDataSource

extension ReviewViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageControl.numberOfPages = pages.count
        pageControl.isHidden = !(pages.count > 1)

        return pages.count
    }

    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let page = pages[indexPath.row]
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewCollectionCell.reuseIdentifier,
                                                         for: indexPath) as? ReviewCollectionCell {
            cell.delegate = self
            cell.isActive = currentPage == indexPath.row
            return presenter.setUp(cell, with: page, at: indexPath)
        }
        fatalError("ReviewCollectionCell wasn't initialized")
    }
}

// MARK: - ReviewCollectionsAdapterDelegate

extension ReviewViewController: ReviewCollectionCellPresenterDelegate {
    func multipage(_ reviewCollectionCellPresenter: ReviewCollectionCellPresenter,
                   didUpdateCellAt indexPath: IndexPath) {
            collectionView.reloadItems(at: [indexPath])
    }

    func multipage(_ reviewCollectionCellPresenter: ReviewCollectionCellPresenter,
                   didUpdateElementIn collectionView: UICollectionView,
                   at indexPath: IndexPath) {
        collectionView.reloadItems(at: [indexPath])
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension ReviewViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize()
    }

    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAt section: Int) -> UIEdgeInsets {
        let itemSize = self.collectionView(collectionView,
                                           layout: collectionViewLayout,
                                           sizeForItemAt: IndexPath(row: 0, section: 0)).width

        let trailingPadding = currentInterfaceOrientation.isLandscape &&
                              UIDevice.current.isIphone ? Constants.trailingCollectionPadding : 0

        let margin = (self.view.bounds.width - trailingPadding - itemSize) / 2
        return UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin)
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let page = pages[indexPath.row]
        GiniAnalyticsManager.track(event: .fullScreenPageTapped, screenName: .review)
        delegate?.review(self, didSelectPage: page)
    }

    private func setCurrentPage(basedOn scrollView: UIScrollView) {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        else { return }
        let offset = scrollView.contentOffset
        let cellWidthIncludingSpacing = cellSize().width + layout.minimumLineSpacing
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        currentPage = max(min(Int(round(index)), pages.count - 1), 0)
        self.pageControl.currentPage = currentPage
    }

    private func setCellStatus(for index: Int, isActive: Bool) {
        let indexToSet = min(index, pages.count - 1)
        let cellIndexPath = IndexPath(row: indexToSet, section: 0)

        let cell = collectionView.cellForItem(at: cellIndexPath) as? ReviewCollectionCell
        cell?.isActive = isActive
    }
}

// MARK: ReviewCollectionViewDelegate

extension ReviewViewController: ReviewCollectionViewDelegate {
    func didTapDelete(on cell: ReviewCollectionCell) {
        guard let indexpath = collectionView.indexPath(for: cell) else { return }
        deleteItem(at: indexpath)
        GiniAnalyticsManager.track(event: .deletePagesTapped, screenName: .review)
        setCurrentPage(basedOn: collectionView)
    }
}

// MARK: Constants

extension ReviewViewController {
    private enum Constants {
        static let a4Ratio = 1.4142
        static let padding: CGFloat = 16
        static let tipLabelPadding: CGFloat = 8
        static let largePadding: CGFloat = 32
        static let bottomPadding: CGFloat = 50
        static let pageControlBottomPadding: CGFloat = 130
        static let buttonSize: CGSize = CGSize(width: 126, height: 50)
        static let titleHeight: CGFloat = 18
        static let maxTitleHeight: CGFloat = 100
        static let bottomNavigationBarHeight: CGFloat = 114
        static let trailingCollectionPadding: CGFloat = 275
        static let loadingIndicatorSize: CGFloat = 45

        static let buttonContainerHorizontalTrailingPadding: (Bool) -> CGFloat = { shouldShowSaveToGallery in
            shouldShowSaveToGallery ? 24.0 : 82.0
        }

        static let buttonsContainerTopPadding: CGFloat = 15.0
        static let buttonsContainerBottomPadding: CGFloat = 26.0

        // Small device padding (iPhone SE, iPhone 6/7/8, etc.)
        static let buttonsContainerBottomPaddingForSmallDevice: CGFloat = 14.0

        static let buttonContainerSpacing: CGFloat = UIDevice.current.isIphoneAndLandscape ? 24.0 : 8.0
        static let buttonContainerWithSaveToGalleryHorizontalSpacing: CGFloat = 28.0
        // Figma is 24 but we have some internal padding in the pagecontrol component aroung 8
        // in total so divided by 2 will be -4 on top to match the figma
        static let pageControlTopConstant: CGFloat = 16.0

        static let saveToGalleryTopConstant: (Int) -> CGFloat = { pagesCount in
            let isSmallDevice = UIDevice.current.isNonNotchSmallScreen()
            if isSmallDevice {
                // Figma is 27 but we have some internal padding in the pagecontrol component around 8
                // in total so divided by 2 will be -4 on top to match the figma
                return pagesCount > 1 ? 0.0 : 10.0
            } else {

                return pagesCount > 1 ? 0.0 : 23.0
            }
        }

        static let saveToGalleryBottomConstant: CGFloat = UIDevice.current.isPortrait ? 11.0 : 28.0
        static let collectionViewHorizontalSpaceLandscape: CGFloat = 24.0

        // Cell size multipliers
        static let landscapeHeightMultiplier: CGFloat = 0.55
        static let saveToGalleryHeightAdjustment: CGFloat = 0.08

        // Portrait multipliers based on bottom navigation bar state
        static let portraitHeightMultiplierWithSafeArea: (Bool) -> CGFloat = { bottomNavEnabled in
            bottomNavEnabled ? 0.52 : 0.58
        }

        static let portraitHeightMultiplierWithoutSafeArea: (Bool) -> CGFloat = { bottomNavEnabled in
            bottomNavEnabled ? 0.42 : 0.5
        }

        // Small device multipliers (iPhone SE, iPhone 6/7/8, etc.)
        static let smallDevicePortraitHeightMultiplier: (Bool) -> CGFloat = { bottomNavEnabled in
            bottomNavEnabled ? 0.35 : 0.45
        }

        static let smallDeviceLandscapeHeightMultiplier: CGFloat = 0.5
    }
}
// swiftlint:enable file_length
