//
//  ReviewViewController.swift
//  GiniCapture
//
//  Created by Vizaknai David on 28.09.2022
//

import UIKit

/**
 The ReviewViewControllerDelegate protocol defines methods that allow you to handle user actions in the
 ReviewViewControllerDelegate
 (tap add, delete...)
 
 - note: Component API only.
 - TODO:  - REMOVE Componen API
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
    func reviewDidTapProcess(_ viewController: ReviewViewController)

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

  - note: Component API only.
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
        layout.minimumInteritemSpacing = 1

        var collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = GiniColor(light: UIColor.GiniCapture.light2,
                                               dark: UIColor.GiniCapture.dark2).uiColor()
        collection.dataSource = self
        collection.delegate = self
        collection.showsHorizontalScrollIndicator = false
        collection.register(ReviewCollectionCell.self,
                            forCellWithReuseIdentifier: ReviewCollectionCell.reuseIdentifier)

        collection.isScrollEnabled = false
        collection.contentInsetAdjustmentBehavior = .never

        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler(sender:)))
        swipeLeftRecognizer.direction = .left
        collection.addGestureRecognizer(swipeLeftRecognizer)

        let swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler(sender:)))
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
        tipLabel.textColor = GiniColor(light: .GiniCapture.dark1, dark: .GiniCapture.light1).uiColor()
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
        pageControl.pageIndicatorTintColor = GiniColor(light: UIColor.GiniCapture.dark1,
                                                       dark: UIColor.GiniCapture.light1)
                                                       .uiColor().withAlphaComponent(0.3)
        pageControl.currentPageIndicatorTintColor = GiniColor(light: UIColor.GiniCapture.dark1,
                                                              dark: UIColor.GiniCapture.light1).uiColor()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.isAccessibilityElement = true
        pageControl.addTarget(self, action: #selector(pageControlTapHandler(sender:)), for: .touchUpInside)

        return pageControl
    }()

    private lazy var processButton: MultilineTitleButton = {
        let button = MultilineTitleButton()
        button.configure(with: giniConfiguration.primaryButtonConfiguration)
        button.titleLabel?.font = giniConfiguration.textStyleFonts[.bodyBold]
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedStringPreferredFormat("ginicapture.multipagereview.mainButtonTitle",
                                                        comment: "Process button title"), for: .normal)
        button.addTarget(self, action: #selector(didTapProcessDocument), for: .touchUpInside)
        return button
    }()

    private lazy var addPagesButton: BottomLabelButton = {
        let addPagesButton = BottomLabelButton()
        addPagesButton.translatesAutoresizingMaskIntoConstraints = false
        addPagesButton.setupButton(with: UIImageNamedPreferred(named: "plus_icon") ?? UIImage(),
                                   name: NSLocalizedStringPreferredFormat(
                                    "ginicapture.multipagereview.secondaryButtonTitle",
                                        comment: "Add pages button title"))
        addPagesButton.isHidden = !giniConfiguration.multipageEnabled
        addPagesButton.actionLabel.font = giniConfiguration.textStyleFonts[.bodyBold]
        addPagesButton.configure(with: giniConfiguration.addPageButtonConfiguration)
        addPagesButton.didTapButton = { [weak self] in
            guard let self = self else { return }
            self.setCellStatus(for: self.currentPage, isActive: false)
            self.delegate?.reviewDidTapAddImage(self)
        }
        return addPagesButton
    }()

    private lazy var buttonContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var loadingIndicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        indicatorView.hidesWhenStopped = true
        indicatorView.style = .whiteLarge
        indicatorView.color = GiniColor(light: UIColor.GiniCapture.dark3, dark: UIColor.GiniCapture.light3).uiColor()
        return indicatorView
    }()

    private lazy var cellSize: CGSize = {
        return calculatedCellSize()
    }()

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
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    ]

    private lazy var contenViewConstraints: [NSLayoutConstraint] = [
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
        contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor),
        contentView.bottomAnchor.constraint(greaterThanOrEqualTo: scrollView.bottomAnchor)
    ]

    private lazy var tipLabelConstraints: [NSLayoutConstraint] = [
        tipLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.padding),
        tipLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        tipLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        tipLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.titleHeight)]

    private lazy var collectionViewConstraints: [NSLayoutConstraint] = [
        collectionView.topAnchor.constraint(equalTo: tipLabel.bottomAnchor, constant: Constants.padding),
        collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        collectionViewHeightConstraint]

    private lazy var pageControlConstraints: [NSLayoutConstraint] = [
        pageControl.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: Constants.padding * 2),
        pageControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        pageControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)]

    private lazy var processButtonConstraints: [NSLayoutConstraint] = [
        processButton.topAnchor.constraint(equalTo: buttonContainer.topAnchor),
        processButton.widthAnchor.constraint(greaterThanOrEqualToConstant: Constants.buttonSize.width),
        processButton.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor),
        processButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.buttonSize.height),
        processButton.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor),
        processButton.trailingAnchor.constraint(lessThanOrEqualTo: buttonContainer.trailingAnchor)]

    private lazy var addPagesButtonConstraints: [NSLayoutConstraint] =  [
            addPagesButton.centerYAnchor.constraint(equalTo: processButton.centerYAnchor),
            addPagesButton.leadingAnchor.constraint(equalTo: processButton.trailingAnchor,
                                                    constant: Constants.padding),
            addPagesButton.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor)]

    private lazy var buttonContainerConstraints: [NSLayoutConstraint] = [
        buttonContainer.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: Constants.padding * 2),
        buttonContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        buttonContainer.bottomAnchor.constraint(greaterThanOrEqualTo: contentView.bottomAnchor,
                                              constant: -Constants.bottomPadding)
    ]

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
                self.delegate?.reviewDidTapProcess(self)
            }
            navigationBarBottomAdapter?.setSecondaryButtonClickedActionCallback { [weak self] in
                guard let self = self else { return }
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
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationBar)
        NSLayoutConstraint.activate([
            navigationBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: Constants.bottomNavigationBarHeight)
        ])
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
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size = calculatedCellSize()
        collectionViewHeightConstraint.constant = size.height + 4
        if UIDevice.current.isIpad {
            // cellSize needs to be updated when the screen is rotated
            self.cellSize = size

            DispatchQueue.main.async {
                guard self.previousScreenHeight != UIScreen.main.bounds.height else { return }
                guard self.pages.count > 1 else { return }
                self.setCellStatus(for: self.currentPage, isActive: false)
                self.collectionView.reloadData()

                self.collectionView.scrollToItem(at: IndexPath(row: self.currentPage, section: 0),
                                                  at: .centeredHorizontally, animated: true)

                self.previousScreenHeight = UIScreen.main.bounds.height
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.setCellStatus(for: self.currentPage, isActive: true)
                }
            }
        }
    }

    private func setupView() {
        title = NSLocalizedStringPreferredFormat("ginicapture.multipagereview.title",
                                                 comment: "Screen title")
        view.backgroundColor = GiniColor(light: UIColor.GiniCapture.light2, dark: UIColor.GiniCapture.dark2).uiColor()

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(tipLabel)
        contentView.addSubview(collectionView)
        contentView.addSubview(pageControl)
        if !giniConfiguration.bottomNavigationBarEnabled {
            contentView.addSubview(buttonContainer)
            buttonContainer.addSubview(processButton)
            if giniConfiguration.multipageEnabled {
                buttonContainer.addSubview(addPagesButton)
            }
        }
        edgesForExtendedLayout = []
    }

    // MARK: - Loading indicator

    private func addLoadingView() {
        guard !giniConfiguration.bottomNavigationBarEnabled else { return }
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
            loadingIndicator.widthAnchor.constraint(equalToConstant: 45),
            loadingIndicator.heightAnchor.constraint(equalToConstant: 45)
        ])
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
        guard !finishedUpload else { return }

        collectionView.reloadData()
        // Update cell status only if pages not empty
        if pages.isNotEmpty {
            guard pages.count > 1 else { return }
            DispatchQueue.main.async {
                self.setCellStatus(for: self.currentPage, isActive: false)

                self.collectionView.scrollToItem(at: IndexPath(row: self.pages.count - 1, section: 0),
                                                  at: .centeredHorizontally, animated: true)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    self.setCurrentPage(basedOn: self.collectionView)
                }
            }
        }
    }
}

// MARK: - Private methods

extension ReviewViewController {
    private func addConstraints() {
        collectionViewHeightConstraint.priority = .defaultLow

        NSLayoutConstraint.activate(scrollViewConstraints)
        NSLayoutConstraint.activate(contenViewConstraints)
        NSLayoutConstraint.activate(tipLabelConstraints)
        NSLayoutConstraint.activate(collectionViewConstraints)
        NSLayoutConstraint.activate(pageControlConstraints)

        if !giniConfiguration.bottomNavigationBarEnabled {
            NSLayoutConstraint.activate(buttonContainerConstraints)
            NSLayoutConstraint.activate(processButtonConstraints)
            if giniConfiguration.multipageEnabled {
                NSLayoutConstraint.activate(addPagesButtonConstraints)
            }
        } else {
            NSLayoutConstraint.activate([
                pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                    constant: -Constants.pageControlBottomPadding),
                collectionView.bottomAnchor.constraint(greaterThanOrEqualTo: pageControl.topAnchor,
                                                       constant: -Constants.padding * 2)
            ])
        }
    }

    @objc
    private func pageControlTapHandler(sender: UIPageControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: { [weak self] in
            self?.collectionView.scrollToItem(at: IndexPath(row: sender.currentPage, section: 0),
                                              at: .centeredHorizontally, animated: true)
            guard let self = self else { return }
            self.setCellStatus(for: self.currentPage, isActive: false)
            self.currentPage = sender.currentPage
        })
    }

    @objc
    private func didTapProcessDocument() {
        delegate?.reviewDidTapProcess(self)
    }

    @objc
    private func swipeHandler(sender: UISwipeGestureRecognizer) {
        guard pages.count > 1 else { return }
        if sender.direction == .left {
            guard currentPage < pages.count - 1 else { return }
            setCellStatus(for: currentPage, isActive: false)
            currentPage += 1
            collectionView.scrollToItem(at: IndexPath(row: currentPage, section: 0),
                                        at: .centeredHorizontally, animated: true)
            pageControl.currentPage = currentPage
        } else if sender.direction == .right {
            guard currentPage > 0 else { return }
            setCellStatus(for: currentPage, isActive: false)
            currentPage -= 1
            collectionView.scrollToItem(at: IndexPath(row: currentPage, section: 0),
                                        at: .centeredHorizontally, animated: true)
            pageControl.currentPage = currentPage
        }
    }

    private func calculatedCellSize() -> CGSize {
        let a4Ratio = 1.4142
        if UIDevice.current.isIpad {
            var height = self.view.bounds.height - 260
            if giniConfiguration.bottomNavigationBarEnabled {
                height -= Constants.bottomNavigationBarHeight
                height -= Constants.padding
            }
            let width = height / a4Ratio
            return CGSize(width: width, height: height)
        } else {
            if view.safeAreaInsets.bottom > 0 {
                var height = self.view.bounds.height * 0.6
                if giniConfiguration.bottomNavigationBarEnabled {
                    height -= Constants.bottomNavigationBarHeight
                    height -= Constants.padding
                }
                let width = height / a4Ratio
                let cellSize = CGSize(width: width, height: height)
                return cellSize
            } else {
                var height = self.view.bounds.height * 0.5
                if giniConfiguration.bottomNavigationBarEnabled {
                    height -= Constants.bottomNavigationBarHeight
                    height -= Constants.padding
                }
                let width = height / a4Ratio
                let cellSize = CGSize(width: width, height: height)
                return cellSize
            }

        }
    }
}

// MARK: - Toolbar actions

extension ReviewViewController {
    private func deleteItem(at indexPath: IndexPath) {
        let pageToDelete = pages[indexPath.row]
        pages.remove(at: indexPath.row)
        collectionView.deleteItems(at: [indexPath])
        delegate?.review(self, didDelete: pageToDelete)
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
        return cellSize
    }

    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAt section: Int) -> UIEdgeInsets {
        let margin = (self.view.bounds.width - cellSize.width) / 2
        return UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin)
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let page = pages[indexPath.row]
        delegate?.review(self, didSelectPage: page)
    }

    private func setCurrentPage(basedOn scrollView: UIScrollView) {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        else { return }
        let offset = scrollView.contentOffset
        let cellWidthIncludingSpacing = cellSize.width + layout.minimumLineSpacing
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        currentPage = Int(round(index))
        self.pageControl.currentPage = currentPage
    }

    private func setCellStatus(for index: Int, isActive: Bool) {
        let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? ReviewCollectionCell
        cell?.isActive = isActive
    }
}

// MARK: ReviewCollectionViewDelegate

extension ReviewViewController: ReviewCollectionViewDelegate {
    func didTapDelete(on cell: ReviewCollectionCell) {
        guard let indexpath = collectionView.indexPath(for: cell) else { return }
        deleteItem(at: indexpath)

        setCurrentPage(basedOn: collectionView)
    }
}

// MARK: Constants

extension ReviewViewController {
    private enum Constants {
        static let padding: CGFloat = 16
        static let bottomPadding: CGFloat = 50
        static let pageControlBottomPadding: CGFloat = 130
        static let buttonSize: CGSize = CGSize(width: 126, height: 50)
        static let titleHeight: CGFloat = 18
        static let bottomNavigationBarHeight: CGFloat = 114
    }
}
