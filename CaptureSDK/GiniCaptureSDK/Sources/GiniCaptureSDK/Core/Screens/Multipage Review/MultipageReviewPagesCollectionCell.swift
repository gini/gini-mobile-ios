//
//  MultipageReviewPagesCollectionCell.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 2/1/18.
//

import UIKit

final class MultipageReviewPagesCollectionCell: UICollectionViewCell {
    
    static let identifier = "MultipageReviewPagesCollectionCellIdentifier"
    static let shadowHeight: CGFloat = 2
    static let shadowRadius: CGFloat = 1
    let pageIndicatorCircleSize = CGSize(width: 25, height: 25)
    let stateViewSize = CGSize(width: 40, height: 40)
    
    private var _giniConfiguration: GiniConfiguration?
    
    var giniConfiguration: GiniConfiguration {
        set {
            _giniConfiguration = newValue
            applyConfiguration(giniConfiguration: giniConfiguration)
        }
        get {
            return _giniConfiguration ?? GiniConfiguration.shared
        }
    }
    
    private func applyConfiguration(giniConfiguration: GiniConfiguration) {
        draggableIcon.tintColor = giniConfiguration.multipageDraggableIconColor
        bottomContainer.backgroundColor = UIColor.from(giniColor: giniConfiguration.multipagePageBackgroundColor)
        pageIndicatorLabel.textColor = giniConfiguration.multipagePageIndicatorColor
        pageSelectedLine.backgroundColor = giniConfiguration.multipagePageSelectedIndicatorColor
        pageIndicatorCircle.layer.borderColor = UIColor.from(giniColor: giniConfiguration.indicatorCircleColor).cgColor
    }
    
    private lazy var roundMask: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5.0
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var documentImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = Colors.Gini.veryLightGray
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var stateView: PageStateView  = {
        let view = PageStateView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = self.stateViewSize.width / 2
        
        return view
    }()
    
    private lazy var traslucentBackground: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        return view
    }()
    
    lazy var draggableIcon: UIImageView = {
        let image = UIImage(named: "draggablePageIcon", in: Bundle(for: GiniCapture.self), compatibleWith: nil)
        let imageView = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = giniConfiguration.multipageDraggableIconColor
        return imageView
    }()
    
    lazy var bottomContainer: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = UIColor.from(giniColor: giniConfiguration.multipagePageBackgroundColor)
        
        return view
    }()
    
    lazy var pageIndicatorLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = giniConfiguration.multipagePageIndicatorColor
        return label
    }()
    
    private lazy var pageIndicatorCircle: UIView = {
        var view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame.size = self.pageIndicatorCircleSize
        view.layer.borderWidth = 1
        view.layer.cornerRadius = self.pageIndicatorCircleSize.width / 2
        updatePageIndicatorCircleColor(pageIndicatorCircle: view)
        return view
    }()
    
    lazy var pageSelectedLine: UIView = {
        var view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = giniConfiguration.multipagePageSelectedIndicatorColor
        view.alpha = 0
        return view
    }()
    
    override var isSelected: Bool {
        didSet {
            self.pageSelectedLine.alpha = isSelected ? 1 : 0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(roundMask)
        roundMask.addSubview(bottomContainer)
        roundMask.addSubview(pageSelectedLine)
        roundMask.addSubview(documentImage)
        roundMask.addSubview(traslucentBackground)
        roundMask.addSubview(stateView)
        bottomContainer.addSubview(pageIndicatorLabel)
        bottomContainer.addSubview(pageIndicatorCircle)
        bottomContainer.addSubview(draggableIcon)
        
        addShadow()
        addConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(frame:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                updatePageIndicatorCircleColor(pageIndicatorCircle: pageIndicatorCircle)
            }
        }
    }
    
    private func updatePageIndicatorCircleColor(pageIndicatorCircle: UIView) {
        
        pageIndicatorCircle.layer.borderColor = UIColor.from(giniColor: giniConfiguration.indicatorCircleColor).cgColor
    }
    
    //swiftlint:disable function_body_length
    fileprivate func addConstraints() {
        // roundMask
        Constraints.active(item: roundMask, attr: .top, relatedBy: .equal, to: self, attr: .top)
        Constraints.active(item: roundMask, attr: .leading, relatedBy: .equal, to: self, attr: .leading)
        Constraints.active(item: roundMask, attr: .trailing, relatedBy: .equal, to: self, attr: .trailing)
        Constraints.active(item: roundMask, attr: .bottom, relatedBy: .equal, to: self, attr: .bottom,
                          constant: -(MultipageReviewPagesCollectionCell.shadowHeight +
                            MultipageReviewPagesCollectionCell.shadowRadius), priority: 999)
        
        // pageIndicator
        Constraints.active(item: pageIndicatorLabel, attr: .centerX, relatedBy: .equal, to: pageIndicatorCircle,
                          attr: .centerX)
        Constraints.active(item: pageIndicatorLabel, attr: .centerY, relatedBy: .equal, to: pageIndicatorCircle,
                          attr: .centerY)
        
        // stateView
        Constraints.active(item: stateView, attr: .centerX, relatedBy: .equal, to: documentImage, attr: .centerX)
        Constraints.active(item: stateView, attr: .centerY, relatedBy: .equal, to: documentImage, attr: .centerY)
        Constraints.active(item: stateView, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                           constant: stateViewSize.height)
        Constraints.active(item: stateView, attr: .width, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                           constant: stateViewSize.width)

        // pageIndicatorCircle
        Constraints.active(item: pageIndicatorCircle, attr: .height, relatedBy: .equal, to: nil,
                          attr: .notAnAttribute, constant: pageIndicatorCircleSize.height)
        Constraints.active(item: pageIndicatorCircle, attr: .width, relatedBy: .equal, to: nil,
                          attr: .notAnAttribute, constant: pageIndicatorCircleSize.width)
        Constraints.active(item: pageIndicatorCircle, attr: .top, relatedBy: .equal, to: bottomContainer,
                          attr: .top, constant: 10, priority: 999)
        Constraints.active(item: pageIndicatorCircle, attr: .bottom, relatedBy: .equal, to: bottomContainer,
                          attr: .bottom, constant: -10, priority: 999)
        Constraints.active(item: pageIndicatorCircle, attr: .centerX, relatedBy: .equal, to: bottomContainer,
                          attr: .centerX)
        Constraints.active(item: pageIndicatorCircle, attr: .centerY, relatedBy: .equal, to: bottomContainer,
                          attr: .centerY)
        
        // pageSelectedLine
        Constraints.active(item: pageSelectedLine, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                          constant: 4)
        Constraints.active(item: pageSelectedLine, attr: .leading, relatedBy: .equal, to: roundMask, attr: .leading)
        Constraints.active(item: pageSelectedLine, attr: .trailing, relatedBy: .equal, to: roundMask, attr: .trailing)
        Constraints.active(item: pageSelectedLine, attr: .bottom, relatedBy: .equal, to: roundMask, attr: .bottom)
        
        // draggableIcon
        Constraints.active(item: draggableIcon, attr: .top, relatedBy: .equal, to: bottomContainer, attr: .top,
                           constant: 12, priority: 999)
        Constraints.active(item: draggableIcon, attr: .bottom, relatedBy: .equal, to: bottomContainer, attr: .bottom,
                          constant: -12)
        Constraints.active(item: draggableIcon, attr: .leading, relatedBy: .greaterThanOrEqual, to: pageIndicatorCircle,
                           attr: .trailing, constant: 6, priority: 999)
        Constraints.active(item: draggableIcon, attr: .trailing, relatedBy: .lessThanOrEqual, to: bottomContainer,
                           attr: .trailing, constant: -6)
        
        // documentImage
        Constraints.active(item: documentImage, attr: .top, relatedBy: .equal, to: roundMask, attr: .top)
        Constraints.active(item: documentImage, attr: .leading, relatedBy: .equal, to: roundMask, attr: .leading)
        Constraints.active(item: documentImage, attr: .trailing, relatedBy: .equal, to: roundMask, attr: .trailing)
        Constraints.active(item: documentImage, attr: .bottom, relatedBy: .equal, to: bottomContainer, attr: .top)
        
        // traslucentBackground
        Constraints.active(item: traslucentBackground, attr: .top, relatedBy: .equal, to: documentImage, attr: .top)
        Constraints.active(item: traslucentBackground, attr: .leading, relatedBy: .equal, to: documentImage,
                           attr: .leading)
        Constraints.active(item: traslucentBackground, attr: .trailing, relatedBy: .equal, to: documentImage,
                           attr: .trailing)
        Constraints.active(item: traslucentBackground, attr: .bottom, relatedBy: .equal, to: documentImage,
                           attr: .bottom)
        
        // bottomContainer
        Constraints.active(item: bottomContainer, attr: .bottom, relatedBy: .equal, to: roundMask, attr: .bottom,
                           priority: 999)
        Constraints.active(item: bottomContainer, attr: .leading, relatedBy: .equal, to: roundMask, attr: .leading)
        Constraints.active(item: bottomContainer, attr: .trailing, relatedBy: .equal, to: roundMask, attr: .trailing)
        Constraints.active(item: bottomContainer, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                          constant: 46)
    }
    
    fileprivate func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = MultipageReviewPagesCollectionCell.shadowRadius
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0,
                                    height: MultipageReviewPagesCollectionCell.shadowHeight)
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    }
    
    class func size(in collection: UICollectionView) -> CGSize {
        let collectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        let height = collection.frame.height -
            collectionInset.top -
            collectionInset.bottom 
        let aspectRatio: CGFloat = 11 / 20
        let width = height * aspectRatio
        
        return CGSize(width: width, height: height)
    }
}
