//
//  MultipageReviewViewController.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 1/26/18.
//

import UIKit

/**
 The MultipageReviewViewControllerDelegate protocol defines methods that allow you to handle user actions in the
 MultipageReviewViewControllerDelegate
 (rotate, reorder, tap add, delete...)
 
 - note: Component API only.
 */
public protocol MultipageReviewViewControllerDelegate: AnyObject {
    /**
     Called when a user deletes one of the pages.
     
     - parameter viewController: `MultipageReviewViewController` where the pages are reviewed.
     - parameter page: Page deleted.
     */
    func multipageReview(_ viewController: MultipageReviewViewController,
                         didDelete page: GiniCapturePage)
    
    /**
     Called when a user taps on the error action when the errored page
     
     - parameter viewController: `MultipageReviewViewController` where the pages are reviewed.
     - parameter errorAction: `NoticeActionType` selected.
     - parameter page: Page where the error action has been triggered
     */
    func multipageReview(_ viewController: MultipageReviewViewController,
                         didTapRetryUploadFor page: GiniCapturePage)
    
    /**
     Called when a user taps on the add page button
     
     - parameter viewController: `MultipageReviewViewController` where the pages are reviewed.
     */
    func multipageReviewDidTapAddImage(_ viewController: MultipageReviewViewController)
    /**
     Called when a user taps on the process documents button

     - parameter viewController: `MultipageReviewViewController` where the pages are reviewed.
     */
    func multipageReviewDidTapProcess(_ viewController: MultipageReviewViewController)
}

//swiftlint:disable file_length
public final class MultipageReviewViewController: UIViewController {
    
    /**
     The object that acts as the delegate of the multipage review view controller.
     */
    public weak var delegate: MultipageReviewViewControllerDelegate?
    
    var pages: [GiniCapturePage]
    fileprivate let giniConfiguration: GiniConfiguration
    fileprivate lazy var presenter: MultipageReviewCollectionCellPresenter = {
        let presenter = MultipageReviewCollectionCellPresenter()
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
        collection.register(MultipageReviewMainCollectionCell.self,
                            forCellWithReuseIdentifier: MultipageReviewMainCollectionCell.reuseIdentifier)
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
        tipLabel.text = "Make sure the payment details are visible"

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
        button.setTitle("Process documents", for: .normal)
        return button
    }()

    private var addPagesButtonView: AddPageButtonView?

    private lazy var cellSize: CGSize = {
        let width = self.view.bounds.width - 64
        let height = width * 1.4142 // A4 aspect ratio
        return CGSize(width: width, height: height)
    }()
    
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

extension MultipageReviewViewController {
    override public func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = GiniColor(light: UIColor.GiniCapture.light2, dark: UIColor.GiniCapture.dark2).uiColor()
        view.addSubview(tipLabel)
        view.addSubview(collectionView)
        view.addSubview(pageControl)
        view.addSubview(processButton)

        processButton.addTarget(self, action: #selector(didTapProcessDocument), for: .touchUpInside)
        addPagesButtonView = AddPageButtonView().loadNib() as? AddPageButtonView
        addPagesButtonView?.translatesAutoresizingMaskIntoConstraints = false
        addPagesButtonView?.isHidden = !giniConfiguration.multipageEnabled
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapAddPagesButton))
        addPagesButtonView?.addGestureRecognizer(gestureRecognizer)
        view.addSubview(addPagesButtonView!)
        edgesForExtendedLayout = []

        addConstraints()
    }
    
    /**
     Updates the collections with the given pages.
     
     - parameter pages: Pages to be used in the collections.
     */

    public func updateCollections(with pages: [GiniCapturePage]) {
        self.pages = pages
        collectionView.reloadData()
    }

    
    private func reload(_ collection: UICollectionView,
                        pages: [GiniCapturePage],
                        indexPaths: (updated: [IndexPath], removed: [IndexPath], inserted: [IndexPath]),
                        animated: Bool, completion: @escaping (Bool) -> Void) {
        // When the collection has not been loaded before, the data should be reloaded
        guard collection.numberOfItems(inSection: 0) > 0 else {
            self.pages = pages
            collection.reloadData()
            return
        }
        
        collection.performBatchUpdates(animated: animated, updates: {[weak self] in
            self?.pages = pages
            collection.reloadItems(at: indexPaths.updated)
            collection.deleteItems(at: indexPaths.removed)
            collection.insertItems(at: indexPaths.inserted)
        }, completion: completion)
    }
}

// MARK: - Private methods

extension MultipageReviewViewController {
    fileprivate func barButtonItem(withImage image: UIImage?,
                                   insets: UIEdgeInsets,
                                   action: Selector) -> UIBarButtonItem {
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.imageEdgeInsets = insets
        button.layer.cornerRadius = 5
        button.tintColor = giniConfiguration.multipageToolbarItemsColor
        
        // This is needed since on iOS 9 and below,
        // the buttons are not resized automatically when using autolayout
        if let image = image {
            button.frame = CGRect(origin: .zero, size: image.size)
        }
        
        return UIBarButtonItem(customView: button)
    }
    
    fileprivate func pagesCollectionMaxHeight(in device: UIDevice = UIDevice.current) -> CGFloat {
        return device.isIpad ? 300 : 224
    }
    
    fileprivate func addConstraints() {
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
            processButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
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
        })
    }

    @objc
    private func didTapAddPagesButton() {
        delegate?.multipageReviewDidTapAddImage(self)
    }

    @objc
    private func didTapProcessDocument() {
        delegate?.multipageReviewDidTapProcess(self)
    }
}

// MARK: - Toolbar actions

extension MultipageReviewViewController {
    
    fileprivate func deleteItem(at indexPath: IndexPath) {
        let pageToDelete = pages[indexPath.row]
        pages.remove(at: indexPath.row)
        collectionView.deleteItems(at: [indexPath])
        delegate?.multipageReview(self, didDelete: pageToDelete)
    }
}

// MARK: UICollectionViewDataSource

extension MultipageReviewViewController: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageControl.numberOfPages = pages.count
        pageControl.isHidden = !(pages.count > 1)

        return pages.count
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let page = pages[indexPath.row]

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:
                                                        MultipageReviewMainCollectionCell.reuseIdentifier,
                                 for: indexPath) as! MultipageReviewMainCollectionCell

        return presenter.setUp(cell, with: page, at: indexPath)
    }
    
    private func didFailUpload(page: GiniCapturePage, indexPath: IndexPath) -> ((NoticeActionType) -> Void) {
        return {[weak self] action in
            guard let self = self else { return }
            switch action {
            case .retry:
                self.delegate?.multipageReview(self, didTapRetryUploadFor: page)
            case .retake:
                self.deleteItem(at: indexPath)
                self.delegate?.multipageReviewDidTapAddImage(self)
            }
        }
    }
}

// MARK: - MultipageReviewCollectionsAdapterDelegate

extension MultipageReviewViewController: MultipageReviewCollectionCellPresenterDelegate {
    func multipage(_ reviewCollectionCellPresenter: MultipageReviewCollectionCellPresenter,
                   didUpdateCellAt indexPath: IndexPath) {
            collectionView.reloadItems(at: [indexPath])
    }
    
    func multipage(_ reviewCollectionCellPresenter: MultipageReviewCollectionCellPresenter,
                   didUpdateElementIn collectionView: UICollectionView,
                   at indexPath: IndexPath) {
        collectionView.reloadItems(at: [indexPath])
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension MultipageReviewViewController: UICollectionViewDelegateFlowLayout {

    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }

    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setCurrentPage(basedOn: scrollView)
        let offset = calulateOffset(for: scrollView)
        scrollView.setContentOffset(offset, animated: true)
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
        let roundedIndex = round(index)
        self.pageControl.currentPage = Int(roundedIndex)
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
}
