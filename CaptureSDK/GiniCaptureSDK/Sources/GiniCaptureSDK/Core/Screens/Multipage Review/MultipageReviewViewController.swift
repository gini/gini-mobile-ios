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
     Called when a user reorder the pages collection
     
     - parameter viewController: `MultipageReviewViewController` where the pages are reviewed.
     - parameter pages: Reordered pages collection
     */
    func multipageReview(_ viewController: MultipageReviewViewController,
                         didReorder pages: [GiniCapturePage])
    /**
     Called when a user rotates one of the pages.
     
     - parameter viewController: `MultipageReviewViewController` where the pages are reviewed.
     - parameter page: `GiniCapturePage` rotated.
     */
    func multipageReview(_ viewController: MultipageReviewViewController,
                         didRotate page: GiniCapturePage)
    
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
}

//swiftlint:disable file_length
public final class MultipageReviewViewController: UIViewController {
    
    /**
     The object that acts as the delegate of the multipage review view controller.
     */
    public weak var delegate: MultipageReviewViewControllerDelegate?
    
    var pages: [GiniCapturePage]
    fileprivate var currentSelectedItemPosition: Int = 0
    fileprivate let giniConfiguration: GiniConfiguration
    fileprivate lazy var presenter: MultipageReviewCollectionCellPresenter = {
        let presenter = MultipageReviewCollectionCellPresenter()
        presenter.delegate = self
        return presenter
    }()
    
    // MARK: - UI initialization
    
    lazy var mainCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        
        var collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 13.0, *) {
            collection.backgroundColor = Colors.Gini.dynamicVeryLightGray
        } else {
            collection.backgroundColor = Colors.Gini.veryLightGray
        }
        
        collection.dataSource = self
        collection.delegate = self
        collection.isPagingEnabled = true
        collection.showsHorizontalScrollIndicator = false
        collection.register(MultipageReviewMainCollectionCell.self,
                            forCellWithReuseIdentifier: MultipageReviewMainCollectionCell.identifier)
        return collection
    }()
    
    var pagesCollectionInsets: UIEdgeInsets {
        let sideInset: CGFloat = (pagesCollection.frame.width -
            MultipageReviewPagesCollectionCell.size(in: pagesCollection).width) / 2
        return UIEdgeInsets(top: 16, left: sideInset, bottom: 16, right: 0)
    }
    
    lazy var pagesCollectionContainer: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.from(giniColor: giniConfiguration.multipagePagesContainerAndToolBarColor)
        return view
    }()
    
    lazy var pagesCollectionTopBorder: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemGray2
        } else {
            view.backgroundColor = .lightGray
        }
        
        return view
    }()
    
    lazy var pagesCollectionBottomTipLabel: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = .localized(resource: MultipageReviewStrings.dragAndDropTipMessage)
        textView.font = textView.font?.withSize(11)
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = false
        textView.backgroundColor = .clear
        return textView
    }()
    
    lazy var pagesCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        var collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.dataSource = self
        collection.delegate = self
        collection.backgroundColor = UIColor.clear
        collection.showsHorizontalScrollIndicator = false
        
        collection.register(MultipageReviewPagesCollectionCell.self,
                            forCellWithReuseIdentifier: MultipageReviewPagesCollectionCell.identifier)
        collection.register(MultipageReviewPagesCollectionFooter.self,
                            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                            withReuseIdentifier: MultipageReviewPagesCollectionFooter.identifier)
        return collection
    }()
    
    lazy var toolBar: UIToolbar = {
        let toolBar = UIToolbar(frame: .zero)
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        toolBar.barTintColor = UIColor.from(giniColor: giniConfiguration.multipagePagesContainerAndToolBarColor)
        toolBar.isTranslucent = false
        toolBar.alpha = 0
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: self,
                                            action: nil)
        var items = [flexibleSpace,
                     self.rotateButton,
                     flexibleSpace,
                     flexibleSpace,
                     self.deleteButton,
                     flexibleSpace]
        
        toolBar.setItems(items, animated: false)
        
        return toolBar
    }()
    
    var reorderContainerTooltipView: ToolTipView?
    fileprivate var opaqueView: UIView?
    
    lazy var rotateButton: UIBarButtonItem = {
        let button = barButtonItem(withImage: UIImageNamedPreferred(named: "rotateImageIcon"),
                             insets: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2),
                             action: #selector(rotateImageButtonAction))
        
        button.accessibilityLabel = NSLocalizedStringPreferredFormat("ginicapture.review.rotateButton", comment: "Rotate button")
        return button
    }()
    
    lazy var deleteButton: UIBarButtonItem = {
        return barButtonItem(withImage: UIImageNamedPreferred(named: "trashIcon"),
                             insets: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2),
                             action: #selector(deleteImageButtonAction))
    }()
    
    fileprivate lazy var pagesCollectionTipLabelHeightConstraint: NSLayoutConstraint = {
        let constraint = NSLayoutConstraint(item: self.pagesCollectionBottomTipLabel,
                                            attribute: .height,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 1.0,
                                            constant: 0)
        return constraint
    }()
    
    fileprivate lazy var longPressGesture = UILongPressGestureRecognizer(target: self,
                                                                         action: #selector(self.handleLongGesture))
    
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
    override public func loadView() {
        super.loadView()
        view.addSubview(mainCollection)
        view.addSubview(toolBar)
        view.insertSubview(pagesCollectionContainer, belowSubview: toolBar)
        pagesCollectionContainer.addSubview(pagesCollection)
        pagesCollectionContainer.addSubview(pagesCollectionTopBorder)
        pagesCollectionContainer.addSubview(pagesCollectionBottomTipLabel)
        
        addConstraints()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = mainCollection.backgroundColor
        mainCollection.contentInsetAdjustmentBehavior = .never
        edgesForExtendedLayout = []
        
        longPressGesture.delaysTouchesBegan = true
        pagesCollection.addGestureRecognizer(longPressGesture)
        
        if ToolTipView.shouldShowReorderPagesButtonToolTip {
            createReorderPagesTip()
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectItem(at: currentSelectedItemPosition)
        changeReorderTipVisibility(to: pages.count < 2)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showToolbar()
        
        reorderContainerTooltipView?.show {
            self.opaqueView?.alpha = 1
            self.deleteButton.isEnabled = false
            self.rotateButton.isEnabled = false
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            ToolTipView.shouldShowReorderPagesButtonToolTip = false
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reorderContainerTooltipView?.arrangeViews()
        opaqueView?.frame = self.mainCollection.frame
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let self = self else {
                return
            }
            
            self.reorderContainerTooltipView?.arrangeViews()
            
        })
    }
    
    /**
     Updates the collections with the given pages.
     
     - parameter pages: Pages to be used in the collections.
     */
    
    public func updateCollections(with pages: [GiniCapturePage], animated: Bool = false) {
        let diff = self.pages.diffIndexes(with: pages)
        
        let updatedIndexPaths = diff.updated.map { IndexPath(row: $0, section: 0) }
        let removedIndexPaths = diff.removed.map { IndexPath(row: $0, section: 0) }
        let insertedIndexPaths = diff.inserted.map { IndexPath(row: $0, section: 0) }
        
        reload(pagesCollection,
               pages: pages,
               indexPaths: (updatedIndexPaths, removedIndexPaths, insertedIndexPaths),
               animated: true) { [weak self] _ in
                guard let self = self else { return }
                self.selectItem(at: self.currentSelectedItemPosition)
        }
        
        mainCollection.reloadData()
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
    
    func selectItem(at position: Int, in section: Int = 0, animated: Bool = true) {
        guard self.pages.count > 0 else {
            return
        }
        
        var indexPathRow = position
        if position < 0 || position >= self.pages.count {
            indexPathRow = 0
        }
        
        let indexPath = IndexPath(row: indexPathRow, section: section)
        pagesCollection.selectItem(at: indexPath,
                                   animated: animated,
                                   scrollPosition: .centeredHorizontally)
        
        collectionView(pagesCollection, didSelectItemAt: indexPath)
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
    
    fileprivate func changeTitle(withPage page: Int) {
        title = .localized(resource: MultipageReviewStrings.titleMessage, args: page, pages.count)
    }
    
    fileprivate func changeReorderTipVisibility(to hidden: Bool) {
        pagesCollectionBottomTipLabel.isHidden = hidden
        pagesCollectionTipLabelHeightConstraint.constant = hidden ? 0 : 30
    }
    
    @objc fileprivate func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            guard let selectedIndexPath = self.pagesCollection
                .indexPathForItem(at: gesture.location(in: self.pagesCollection)) else {
                    break
            }
            pagesCollection.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            if let collectionView = gesture.view as? UICollectionView, collectionView == pagesCollection {
                let gesturePosition = gesture.location(in: collectionView)
                let maxY = (collectionView.frame.height / 2) + pagesCollectionInsets.top
                let minY = (collectionView.frame.height / 2) - pagesCollectionInsets.top
                let y = gesturePosition.y > minY ? min(maxY, gesturePosition.y) : minY
                pagesCollection.updateInteractiveMovementTargetPosition(CGPoint(x: gesturePosition.x, y: y))
            }
        case .ended:
            pagesCollection.endInteractiveMovement()
        default:
            pagesCollection.cancelInteractiveMovement()
        }
    }
    
    fileprivate func createReorderPagesTip() {
        let opaqueView = OpaqueViewFactory.create(with: giniConfiguration.multipageToolTipOpaqueBackgroundStyle)
        opaqueView.alpha = 0
        self.opaqueView = opaqueView
        self.view.addSubview(opaqueView)
        
        reorderContainerTooltipView = ToolTipView(text: .localized(resource: MultipageReviewStrings.reorderContainerTooltipMessage),
                                  giniConfiguration: giniConfiguration,
                                  referenceView: pagesCollectionContainer,
                                  superView: view,
                                  position: .above,
                                  distanceToRefView: .zero)
        
        reorderContainerTooltipView?.willDismiss = { [weak self] in
            guard let self = self else { return }
            self.closeTooltip()
        }
        
        reorderContainerTooltipView?.willDismissOnCloseButtonTap = { [weak self] in
            guard let self = self else { return }
            self.closeTooltip()
        }
    }
    
    fileprivate func closeTooltip(){
        self.opaqueView?.removeFromSuperview()
        self.deleteButton.isEnabled = true
        self.rotateButton.isEnabled = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.reorderContainerTooltipView = nil
    }
    
    fileprivate func showToolbar() {
        UIView.animate(withDuration: AnimationDuration.fast, animations: {
            self.toolBar.alpha = 1
        }, completion: { _ in
            self.pagesCollectionContainer.alpha = 1
        })
    }
    
    fileprivate func pagesCollectionMaxHeight(in device: UIDevice = UIDevice.current) -> CGFloat {
        return device.isIpad ? 300 : 224
    }
    
    fileprivate func addConstraints() {
        // mainCollection
        Constraints.active(item: mainCollection, attr: .bottom, relatedBy: .equal, to: pagesCollectionContainer,
                           attr: .top)
        Constraints.active(item: mainCollection, attr: .top, relatedBy: .equal, to: view.safeAreaLayoutGuide,
                           attr: .top)
        Constraints.active(item: mainCollection, attr: .trailing, relatedBy: .equal, to: view, attr: .trailing)
        Constraints.active(item: mainCollection, attr: .leading, relatedBy: .equal, to: view, attr: .leading)
        
        // toolBar
        Constraints.active(item: toolBar, attr: .bottom, relatedBy: .equal, to: view.safeAreaLayoutGuide,
                           attr: .bottom)
        Constraints.active(item: toolBar, attr: .trailing, relatedBy: .equal, to: view, attr: .trailing)
        Constraints.active(item: toolBar, attr: .leading, relatedBy: .equal, to: view, attr: .leading)
        
        // pagesCollectionContainer
        Constraints.active(item: pagesCollectionContainer, attr: .bottom, relatedBy: .equal, to: toolBar, attr: .top)
        Constraints.active(item: pagesCollectionContainer, attr: .trailing, relatedBy: .equal, to: view,
                           attr: .trailing)
        Constraints.active(item: pagesCollectionContainer, attr: .leading, relatedBy: .equal, to: view, attr: .leading)
        
        // pagesCollectionTopBorder
        Constraints.active(item: pagesCollectionTopBorder, attr: .top, relatedBy: .equal,
                           to: pagesCollectionContainer, attr: .top)
        Constraints.active(item: pagesCollectionTopBorder, attr: .leading, relatedBy: .equal,
                           to: pagesCollectionContainer, attr: .leading)
        Constraints.active(item: pagesCollectionTopBorder, attr: .trailing, relatedBy: .equal,
                           to: pagesCollectionContainer, attr: .trailing)
        Constraints.active(item: pagesCollectionTopBorder, attr: .height, relatedBy: .equal, to: nil,
                           attr: .notAnAttribute, constant: 0.5)
        
        // pagesCollection
        Constraints.active(item: pagesCollection, attr: .bottom, relatedBy: .equal, to: pagesCollectionBottomTipLabel,
                           attr: .top)
        Constraints.active(item: pagesCollection, attr: .top, relatedBy: .equal, to: pagesCollectionContainer,
                           attr: .top)
        Constraints.active(item: pagesCollection, attr: .trailing, relatedBy: .equal, to: view, attr: .trailing)
        Constraints.active(item: pagesCollection, attr: .leading, relatedBy: .equal, to: view, attr: .leading)
        Constraints.active(item: pagesCollection, attr: .height, relatedBy: .equal, to: view, attr: .height,
                           multiplier: 2 / 5, priority: 999)
        Constraints.active(item: pagesCollection, attr: .height, relatedBy: .lessThanOrEqual, to: nil,
                           attr: .notAnAttribute, constant: pagesCollectionMaxHeight())
        
        // pagesCollectionBottomTipLabel
        Constraints.active(item: pagesCollectionBottomTipLabel, attr: .bottom, relatedBy: .equal,
                           to: pagesCollectionContainer, attr: .bottom)
        Constraints.active(constraint: pagesCollectionTipLabelHeightConstraint)
        Constraints.active(item: pagesCollectionBottomTipLabel, attr: .centerX, relatedBy: .equal,
                           to: pagesCollectionContainer, attr: .centerX)
    }
}

// MARK: - Toolbar actions

extension MultipageReviewViewController {
    
    fileprivate func deleteItem(at indexPath: IndexPath) {
        let pageToDelete = pages[indexPath.row]
        pages.remove(at: indexPath.row)
        mainCollection.deleteItems(at: [indexPath])
        delegate?.multipageReview(self, didDelete: pageToDelete)
        deleteButton.isEnabled = false
        
        pagesCollection.performBatchUpdates({
            self.pagesCollection.deleteItems(at: [indexPath])
        }, completion: { _ in
            if self.pages.count > 0 {
                if indexPath.row != self.pages.count {
                    self.reloadPagesStarting(from: indexPath)
                }
                
                self.selectItem(at: min(indexPath.row, self.pages.count - 1))
            }
            self.deleteButton.isEnabled = true
        })
    }
    
    private func reloadPagesStarting(from indexPath: IndexPath) {
        var indexes = IndexPath.indexesBetween(indexPath,
                                               and: IndexPath(row: pages.count,
                                                              section: 0))
        indexes.append(indexPath)
        pagesCollection.reloadItems(at: indexes)
    }
    
    @objc fileprivate func rotateImageButtonAction() {
		let currentIndexPath = IndexPath(row: currentSelectedItemPosition, section: 0)
		presenter.rotateThumbnails(for: pages[currentIndexPath.row])
		
		mainCollection.reloadItems(at: [currentIndexPath])
		pagesCollection.reloadItems(at: [currentIndexPath])
		
		selectItem(at: currentIndexPath.row)
		delegate?.multipageReview(self, didRotate: pages[currentIndexPath.row])
	}
	
    @objc fileprivate func deleteImageButtonAction() {
		let indexPath = IndexPath(row: currentSelectedItemPosition, section: 0)
		deleteItem(at: indexPath)
    }
    
}

// MARK: UICollectionViewDataSource

extension MultipageReviewViewController: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let page = pages[indexPath.row]
        let isSelected = self.currentSelectedItemPosition == indexPath.row
        let collectionCell: MultipageReviewCollectionCellPresenter.MultipageCollectionCellType
        
        if collectionView == mainCollection {
            let cell = mainCollection
                .dequeueReusableCell(withReuseIdentifier: MultipageReviewMainCollectionCell.identifier,
                                     for: indexPath) as? MultipageReviewMainCollectionCell
            collectionCell = .main(cell!, didFailUpload(page: page, indexPath: indexPath))
        } else {
            let cell = pagesCollection
                .dequeueReusableCell(withReuseIdentifier: MultipageReviewPagesCollectionCell.identifier,
                                     for: indexPath) as? MultipageReviewPagesCollectionCell
            collectionCell = .pages(cell!)
        }

        return presenter.setUp(collectionCell, with: page, isSelected: isSelected, at: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               viewForSupplementaryElementOfKind kind: String,
                               at indexPath: IndexPath) -> UICollectionReusableView {
        let footer = collectionView
            .dequeueReusableSupplementaryView(ofKind: kind,
                                              withReuseIdentifier: MultipageReviewPagesCollectionFooter.identifier,
                                              for: indexPath) as? MultipageReviewPagesCollectionFooter
        footer?.updateMaskConstraints(with: collectionView)
        footer?.trailingConstraint?.constant = -MultipageReviewPagesCollectionFooter.padding(in: collectionView).right
        footer?.addLabel.font = giniConfiguration.customFont.with(weight: .bold, size: 12, style: .footnote)
        footer?.didTapAddButton = { [weak self] in
            guard let self = self else { return }
            self.delegate?.multipageReviewDidTapAddImage(self)
        }
        
        return footer!
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               moveItemAt sourceIndexPath: IndexPath,
                               to destinationIndexPath: IndexPath) {
        if collectionView == pagesCollection {
            var indexes = IndexPath.indexesBetween(sourceIndexPath, and: destinationIndexPath)
            indexes.append(sourceIndexPath)
            
            let elementMoved = pages.remove(at: sourceIndexPath.row)
            pages.insert(elementMoved, at: destinationIndexPath.row)

            // This is needed because this method is called before the dragging animation finishes.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [weak self] in
                guard let self = self else { return }
                self.pagesCollection.reloadData()               
                self.selectItem(at: destinationIndexPath.row)
                self.delegate?.multipageReview(self, didReorder: self.pages)
            })
        }
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
                   didUpdate cell: MultipageReviewCollectionCellPresenter.MultipageCollectionCellType,
                   at indexPath: IndexPath) {
        switch cell {
        case .main:
            mainCollection.reloadItems(at: [indexPath])
        case .pages:
            pagesCollection.reloadItems(at: [indexPath])
        }
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
        return collectionView == mainCollection ?
            collectionView.frame.size :
            MultipageReviewPagesCollectionCell.size(in: collectionView)
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               referenceSizeForFooterInSection section: Int) -> CGSize {
        guard collectionView == pagesCollection else {
            return .zero
        }
        
        return MultipageReviewPagesCollectionFooter.size(in: collectionView)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == pagesCollection {
            if pages.count > 1 {
                mainCollection.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
                pagesCollection.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
            changeTitle(withPage: indexPath.row + 1)
            currentSelectedItemPosition = indexPath.row
			mainCollection.reloadData()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAt section: Int) -> UIEdgeInsets {
        return collectionView == mainCollection ? .zero : pagesCollectionInsets
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == mainCollection {
            if let indexPath = visibleCell(in: mainCollection) {
                selectItem(at: indexPath.row)
            }
        }
    }
    
    func visibleCell(in collectionView: UICollectionView) -> IndexPath? {
        collectionView.layoutIfNeeded() // It is needed due to a bug in UIKit.
        return collectionView.indexPathsForVisibleItems.first
    }
        
    private func frame(for imageView: UIImageView, from coordinateSpace: UICoordinateSpace) -> CGRect {
        guard let image = imageView.image else { return .zero }
        let origin = view.convert(imageView.frame.origin, to: coordinateSpace)
        let imageWidth = imageView.frame.size.height * image.size.width / image.size.height
        let imageOriginX = (imageView.frame.size.width - imageWidth) / 2
        
        return CGRect(origin: CGPoint(x: imageOriginX, y: origin.y),
                      size: CGSize(width: imageWidth, height: imageView.frame.size.height))
    }
    
}
