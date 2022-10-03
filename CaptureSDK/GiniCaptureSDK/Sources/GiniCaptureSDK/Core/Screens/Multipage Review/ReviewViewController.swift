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
 */
public protocol ReviewViewControllerDelegate: AnyObject {
    /**
     Called when a user deletes one of the pages.
     
     - parameter viewController: `ReviewViewController` where the pages are reviewed.
     - parameter page: Page deleted.
     */
    func review(_ viewController: ReviewViewController,
                         didDelete page: GiniCapturePage)
    
    /**
     Called when a user taps on the error action when the errored page
     
     - parameter viewController: `ReviewViewController` where the pages are reviewed.
     - parameter errorAction: `NoticeActionType` selected.
     - parameter page: Page where the error action has been triggered
     */
    func review(_ viewController: ReviewViewController,
                         didTapRetryUploadFor page: GiniCapturePage)
    
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
}

//swiftlint:disable file_length
public final class ReviewViewController: UIViewController {
    
    /**
     The object that acts as the delegate of the review view controller.
     */
    public weak var delegate: ReviewViewControllerDelegate?
    
    var pages: [GiniCapturePage]
    fileprivate let giniConfiguration: GiniConfiguration
    fileprivate lazy var presenter: ReviewCollectionCellPresenter = {
        let presenter = ReviewCollectionCellPresenter()
        presenter.delegate = self
        return presenter
    }()
    
    // MARK: - UI initialization
    
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
        pageControl.addTarget(self, action: #selector(pageControlTapHandler(sender:)), for: .touchUpInside)

        return pageControl
    }()

    private lazy var processButton: MultilineTitleButton = {
        let button = MultilineTitleButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = giniConfiguration.textStyleFonts[.bodyBold]
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.layer.cornerRadius = 16
        button.backgroundColor = UIColor.GiniCapture.accent1
        button.setTitle(NSLocalizedStringPreferredFormat("ginicapture.multipagereview.mainButtonTitle",
                                                         comment: "Process button title"), for: .normal)
        button.addTarget(self, action: #selector(didTapProcessDocument), for: .touchUpInside)
        return button
    }()

    private var addPagesButtonView: AddPageButtonView?

    private lazy var cellSize: CGSize = {
        return calculatedCellSize()
    }()

    private var currentPage: Int = 0 {
        didSet {
            setCellStatus(for: currentPage, isActive: true)
        }
    }

    // MARK: - Init
    
    public init(pages: [GiniCapturePage], giniConfiguration: GiniConfiguration) {
        self.pages = pages
        self.giniConfiguration = giniConfiguration
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(imageDocuments:) has not been implemented")
    }
}

// MARK: - UIViewController

extension ReviewViewController {
    override public func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedStringPreferredFormat("ginicapture.multipagereview.title",
                                                 comment: "Screen title")
        view.backgroundColor = GiniColor(light: UIColor.GiniCapture.light2, dark: UIColor.GiniCapture.dark2).uiColor()
        view.addSubview(tipLabel)
        view.addSubview(collectionView)
        view.addSubview(pageControl)
        view.addSubview(processButton)

        addPagesButtonView = AddPageButtonView().loadNib() as? AddPageButtonView
        addPagesButtonView?.translatesAutoresizingMaskIntoConstraints = false
        addPagesButtonView?.isHidden = !giniConfiguration.multipageEnabled
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapAddPagesButton))
        addPagesButtonView?.addGestureRecognizer(gestureRecognizer)
        view.addSubview(addPagesButtonView!)
        edgesForExtendedLayout = []

        addConstraints()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.setCellStatus(for: self.currentPage, isActive: true)
        }
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        collectionView.contentInsetAdjustmentBehavior = .never

        // cellSize needs to be updated when the screen is rotated
        self.cellSize = calculatedCellSize()

        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    /**
     Updates the collections with the given pages.
     
     - parameter pages: Pages to be used in the collections.
     */

    public func updateCollections(with pages: [GiniCapturePage]) {
        setCellStatus(for: currentPage, isActive: false, animated: false)
        self.pages = pages
        collectionView.reloadData()

        // Update cell status only if pages not empty and view is visible
        if pages.isNotEmpty && viewIfLoaded?.window != nil {
            DispatchQueue.main.async {
                self.setCellStatus(for: self.currentPage, isActive: true, animated: false)
            }
        }
    }
}

// MARK: - Private methods

extension ReviewViewController {
    private func addConstraints() {
        NSLayoutConstraint.activate([
            tipLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tipLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tipLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            collectionView.topAnchor.constraint(equalTo: tipLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            pageControl.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 32),
            pageControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            processButton.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 32),
            processButton.widthAnchor.constraint(equalToConstant: 204),
            processButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            processButton.heightAnchor.constraint(equalToConstant: 50),
            processButton.bottomAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),

            addPagesButtonView!.centerYAnchor.constraint(equalTo: processButton.centerYAnchor),
            addPagesButtonView!.leadingAnchor.constraint(equalTo: processButton.trailingAnchor, constant: 8)
        ])
    }

    @objc
    private func pageControlTapHandler(sender:UIPageControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: { [weak self] in
            self?.collectionView.scrollToItem(at: IndexPath(row: sender.currentPage, section: 0),
                                              at: .centeredHorizontally, animated: true)
            guard let self = self else { return }
            self.setCellStatus(for: self.currentPage, isActive: false)
            self.currentPage = sender.currentPage
        })
    }

    @objc
    private func didTapAddPagesButton() {
        delegate?.reviewDidTapAddImage(self)
    }

    @objc
    private func didTapProcessDocument() {
        delegate?.reviewDidTapProcess(self)
    }

    private func calculatedCellSize() -> CGSize {
        let a4Ratio = 1.4142
        if UIDevice.current.isIpad {
            let height = self.view.bounds.height - 260
            let width = height / a4Ratio
            return CGSize(width: width, height: height)
        } else {
            if view.safeAreaInsets.bottom > 0 {
                let height = self.view.bounds.height * 0.6
                let width = height / a4Ratio
                let cellSize = CGSize(width: width, height: height)
                return cellSize
            } else {
                let height = self.view.bounds.height * 0.5
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:
                                                        ReviewCollectionCell.reuseIdentifier,
                                 for: indexPath) as! ReviewCollectionCell
        cell.delegate = self
        return presenter.setUp(cell, with: page, at: indexPath)
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

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setCurrentPage(basedOn: scrollView)
        let offset = calulateOffset(for: scrollView)
        scrollView.setContentOffset(offset, animated: true)
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        setCellStatus(for: currentPage, isActive: false)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        setCurrentPage(basedOn: scrollView)
        let offset = calulateOffset(for: scrollView)
        scrollView.setContentOffset(offset, animated: true)
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

    private func calulateOffset(for scrollView: UIScrollView) -> CGPoint {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        else { return CGPoint.zero }
        let cellWidthIncludingSpacing = cellSize.width + layout.minimumLineSpacing

        var offset = scrollView.contentOffset
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = round(index)

        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left,
                         y: -scrollView.contentInset.top)

        return offset
    }

    private func setCellStatus(for index: Int, isActive: Bool, animated: Bool = true) {
        let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? ReviewCollectionCell
        cell?.setActiveStatus(isActive, animated: animated)
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
