//
//  MultipageReviewPagesCollectionFooter.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 4/26/18.
//

import UIKit

final class MultipageReviewPagesCollectionFooter: UICollectionReusableView {
    
    static let identifier = "MultipageReviewPagesCollectionFooterIdentifier"
    var didTapAddButton: (() -> Void)?
    static let defaultPadding: CGFloat = 10
    
    var trailingConstraint: NSLayoutConstraint?
    fileprivate var roundMaskHeightConstraint: NSLayoutConstraint?
    fileprivate var roundMaskWidthConstraint: NSLayoutConstraint?

    fileprivate lazy var roundMask: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .gray
        view.layer.cornerRadius = 5.0
        view.layer.masksToBounds = true
        return view
    }()
    
    fileprivate lazy var addButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImageNamedPreferred(named: "addCircleIcon"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(addImageButtonAction), for: .touchUpInside)
        return button
    }()
    
    lazy var addLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = .localized(resource: MultipageReviewStrings.addButtonLabel)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(roundMask)
        roundMask.addSubview(addButton)
        roundMask.addSubview(addLabel)
        
        addInnerShadow()
        addConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func size(in collectionView: UICollectionView) -> CGSize {
        let padding = self.padding(in: collectionView)
        let height = MultipageReviewPagesCollectionFooter.contentSize(in: collectionView).height
        let width = MultipageReviewPagesCollectionFooter.contentSize(in: collectionView).width +
            padding.left +
            padding.right
        
        return CGSize(width: width, height: height)
    }
    
    class func padding(in collectionView: UICollectionView? = nil) -> UIEdgeInsets {
        var rightPadding: CGFloat = defaultPadding
        if let collectionView = collectionView {
            rightPadding = ((collectionView.frame.width -
                MultipageReviewPagesCollectionCell.size(in: collectionView).width) / 2)
        }
        
        return UIEdgeInsets(top: defaultPadding, left: defaultPadding, bottom: defaultPadding, right: rightPadding)
    }
    
    func updateMaskConstraints(with collectionView: UICollectionView) {
        roundMaskHeightConstraint?.constant = MultipageReviewPagesCollectionFooter
            .contentSize(in: collectionView).height
        roundMaskWidthConstraint?.constant = MultipageReviewPagesCollectionFooter
            .contentSize(in: collectionView).width
    }
}

// MARK: - Private methods

extension MultipageReviewPagesCollectionFooter {
    
    @objc fileprivate func addImageButtonAction() {
        UIImpactFeedbackGenerator().impactOccurred()
        didTapAddButton?()
    }
    
    fileprivate func addInnerShadow() {
        let innerShadow = CALayer()
        innerShadow.frame = bounds
        
        let path = UIBezierPath(rect: innerShadow.bounds.insetBy(dx: -3, dy: -3))
        let cutout = UIBezierPath(rect: innerShadow.bounds).reversing()
        path.append(cutout)
        innerShadow.shadowPath = path.cgPath
        innerShadow.masksToBounds = true
        
        innerShadow.shadowColor = UIColor.black.cgColor
        innerShadow.shadowOffset = CGSize.zero
        innerShadow.shadowOpacity = 0.5
        innerShadow.shadowRadius = 3
        
        roundMask.layer.addSublayer(innerShadow)
    }
    
    fileprivate class func contentSize(in collectionView: UICollectionView) -> CGSize {
        return MultipageReviewPagesCollectionCell.size(in: collectionView)
    }
    
    fileprivate func addConstraints() {
        // roundMask
        roundMaskHeightConstraint = NSLayoutConstraint(item: roundMask,
                                                       attribute: .height,
                                                       relatedBy: .equal,
                                                       toItem: nil,
                                                       attribute: .notAnAttribute,
                                                       multiplier: 1.0,
                                                       constant: 0)
        roundMaskWidthConstraint = NSLayoutConstraint(item: roundMask,
                                                       attribute: .width,
                                                       relatedBy: .equal,
                                                       toItem: nil,
                                                       attribute: .notAnAttribute,
                                                       multiplier: 1.0,
                                                       constant: 0)
        Constraints.active(constraint: roundMaskHeightConstraint!)
        Constraints.active(constraint: roundMaskWidthConstraint!)
        Constraints.active(item: roundMask, attr: .centerY, relatedBy: .equal, to: self, attr: .centerY)
        
        // addButton
        Constraints.active(item: addButton, attr: .centerX, relatedBy: .equal, to: roundMask, attr: .centerX)
        Constraints.active(item: addButton, attr: .centerY, relatedBy: .equal, to: roundMask,
                           attr: .centerY, constant: -20)
        Constraints.active(item: addButton, attr: .height, relatedBy: .equal, to: nil,
                           attr: .notAnAttribute, constant: 60, priority: 999)
        Constraints.active(item: addButton, attr: .width, relatedBy: .equal, to: addButton, attr: .height)
        Constraints.active(item: addButton, attr: .top, relatedBy: .greaterThanOrEqual, to: roundMask,
                           attr: .top, constant: MultipageReviewPagesCollectionFooter.padding().top, priority: 999)
        
        // addLabel
        Constraints.active(item: addLabel, attr: .top, relatedBy: .equal, to: addButton, attr: .bottom,
                           constant: MultipageReviewPagesCollectionFooter.padding().top)
        Constraints.active(item: addLabel, attr: .bottom, relatedBy: .lessThanOrEqual, to: roundMask, attr: .bottom,
                           constant: -MultipageReviewPagesCollectionFooter.padding().bottom)
        Constraints.active(item: addLabel, attr: .leading, relatedBy: .equal, to: roundMask, attr: .leading,
                           constant: MultipageReviewPagesCollectionFooter.padding().left)
        Constraints.active(item: addLabel, attr: .trailing, relatedBy: .equal, to: roundMask, attr: .trailing,
                           constant: -MultipageReviewPagesCollectionFooter.padding().right, priority: 999)
        
        // Since it is not possible to add an inset to the footer, but only to the section
        // (header and footer are not part of the section), we add a right inset dynamically through a
        // constraint in our round container view (roundMask).
        trailingConstraint = NSLayoutConstraint(item: roundMask,
                                                attribute: .trailing,
                                                relatedBy: .equal,
                                                toItem: self,
                                                attribute: .trailing,
                                                multiplier: 1.0,
                                                constant: -MultipageReviewPagesCollectionFooter.padding().right)
        Constraints.active(constraint: trailingConstraint!)
    }
}
