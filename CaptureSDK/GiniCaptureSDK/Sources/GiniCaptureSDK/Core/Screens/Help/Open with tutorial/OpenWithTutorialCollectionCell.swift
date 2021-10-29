//
//  OpenWithTutorialCollectionCell.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 10/23/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit

final class OpenWithTutorialCollectionCell: UICollectionViewCell {
    
    let padding:(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) = (40, 20, 40, 20)
    let stepIndicatorCircleSize: CGSize = CGSize(width: 30, height: 30)
    let imageHeight: CGFloat = UIDevice.current.isIpad ? 250 : 190
    
    let indicatorToTitleDistance: CGFloat = 30
    let titleToSubtitleDistance: CGFloat = 20
    let subtitleToImageDistance: CGFloat = 40
    
    static let maxTitleFontSize: CGFloat = UIDevice.current.isIpad ? 18 : 14
    static let maxSubtitleFontSize: CGFloat = UIDevice.current.isIpad ? 16 : 14
    
    lazy var stepIndicator: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = GiniConfiguration.shared.stepIndicatorColor
        return label
    }()
    
    lazy var stepIndicatorCircle: UIView = {
        var view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame.size = self.stepIndicatorCircleSize
        
        updateStepIndicatorCircleColor(stepIndicatorCircle: view)
        
        view.layer.borderWidth = 1
        view.layer.cornerRadius = self.stepIndicatorCircleSize.width / 2
        return view
    }()
    
    private func updateStepIndicatorCircleColor(stepIndicatorCircle: UIView) {
        
        stepIndicatorCircle.layer.borderColor = UIColor.from(giniColor: GiniConfiguration.shared.indicatorCircleColor).cgColor
    }
    
    lazy var stepTitle: UILabel = {
        var label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    lazy var stepSubTitle: UILabel = {
        var label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 13.0, *) {
            label.textColor = .secondaryLabel
        } else {
            label.textColor = .lightGray
        }
        
        return label
    }()
    
    lazy var stepImage: UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        updateStepImageShadow(stepImage: imageView)
        
        imageView.layer.shadowOpacity = 0.1
        imageView.layer.shadowRadius = 14
        imageView.layer.shadowPath = UIBezierPath(rect: imageView.bounds).cgPath
        return imageView
    }()
    
    private func updateStepImageShadow(stepImage: UIImageView) {
        
        if #available(iOS 13.0, *) {
            stepImage.layer.shadowColor = Colors.Gini.shadowColor.cgColor
        } else {
            stepImage.layer.shadowColor = UIColor.black.cgColor
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                
                updateStepIndicatorCircleColor(stepIndicatorCircle: stepIndicatorCircle)
                updateStepImageShadow(stepImage: stepImage)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if #available(iOS 13.0, *) {
            backgroundColor = .systemBackground
        } else {
            backgroundColor = .white
        }
        
        addSubview(stepIndicator)
        addSubview(stepIndicatorCircle)
        addSubview(stepTitle)
        addSubview(stepSubTitle)
        addSubview(stepImage)
        
        addConstrains()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(frame:) should be used instead")
    }
    
    private func addConstrains() {
        
        // stepIndicator
        Constraints.active(item: stepIndicator, attr: .centerX, relatedBy: .equal, to: stepIndicatorCircle,
                          attr: .centerX)
        Constraints.active(item: stepIndicator, attr: .centerY, relatedBy: .equal, to: stepIndicatorCircle,
                          attr: .centerY)
        
        // stepIndicatorCircle
        Constraints.active(item: stepIndicatorCircle, attr: .height, relatedBy: .equal, to: nil,
                          attr: .notAnAttribute, constant: stepIndicatorCircleSize.height)
        Constraints.active(item: stepIndicatorCircle, attr: .width, relatedBy: .equal, to: nil,
                          attr: .notAnAttribute, constant: stepIndicatorCircleSize.width)
        Constraints.active(item: stepIndicatorCircle, attr: .top, relatedBy: .equal, to: self,
                          attr: .top, constant: padding.top)
        Constraints.active(item: stepIndicatorCircle, attr: .leading, relatedBy: .equal, to: self,
                          attr: .leading, constant: padding.left)
        
        // stepTitle
        Constraints.active(item: stepTitle, attr: .top, relatedBy: .equal, to: stepIndicatorCircle,
                          attr: .bottom, constant: indicatorToTitleDistance)
        Constraints.active(item: stepTitle, attr: .leading, relatedBy: .equal, to: self,
                          attr: .leading, constant: padding.left)
        Constraints.active(item: stepTitle, attr: .trailing, relatedBy: .equal, to: self,
                          attr: .trailing, constant: -padding.right)
        
        // stepSubTitle
        Constraints.active(item: stepSubTitle, attr: .top, relatedBy: .equal, to: stepTitle,
                          attr: .bottom, constant: titleToSubtitleDistance)
        Constraints.active(item: stepSubTitle, attr: .leading, relatedBy: .equal, to: self,
                          attr: .leading, constant: padding.left)
        Constraints.active(item: stepSubTitle, attr: .trailing, relatedBy: .equal, to: self,
                          attr: .trailing, constant: -padding.right)
        stepSubTitle.setContentCompressionResistancePriority(.required, for: .vertical)
        
        // stepImage
        Constraints.active(item: stepImage, attr: .top, relatedBy: .equal, to: stepSubTitle,
                          attr: .bottom, constant: subtitleToImageDistance)
        Constraints.active(item: stepImage, attr: .leading, relatedBy: .equal, to: self,
                          attr: .leading, constant: padding.left, priority: 999)
        Constraints.active(item: stepImage, attr: .trailing, relatedBy: .equal, to: self,
                          attr: .trailing, constant: -padding.right, priority: 999)
        Constraints.active(item: stepImage, attr: .centerX, relatedBy: .equal, to: self,
                          attr: .centerX)
        Constraints.active(item: stepImage, attr: .bottom, relatedBy: .lessThanOrEqual,
                          to: self, attr: .bottom, constant: -padding.bottom, priority: 999)
        Constraints.active(item: stepImage, attr: .height, relatedBy: .equal, to: nil,
                          attr: .notAnAttribute, constant: imageHeight)
        
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes)
        -> UICollectionViewLayoutAttributes {
        guard let collectionView = superview as? UICollectionView else { return layoutAttributes }
        let isHorizontalLayout = collectionView.frame.width > collectionView.frame.height && UIDevice.current.isIpad
        var maxTextWidth: CGFloat = UIScreen.main.bounds.width - padding.left - padding.right
        
        if isHorizontalLayout {
            maxTextWidth = (UIScreen.main.bounds.width / CGFloat(collectionView.numberOfItems(inSection: 0))) -
                padding.left -
                padding.right
        }
        
        let itemSeparations: CGFloat = padding.top +
            padding.bottom +
            indicatorToTitleDistance +
            titleToSubtitleDistance +
            subtitleToImageDistance
        let itemsHeight = stepIndicatorCircleSize.height +
            imageHeight +
            stepTitle.textHeight(forWidth: maxTextWidth) +
            stepSubTitle.textHeight(forWidth: maxTextWidth)
        
        var height: CGFloat = ceil(itemsHeight + itemSeparations)
        
        if isHorizontalLayout && height < collectionView.frame.height {
            height = collectionView.frame.height
        }
        
        layoutAttributes.frame.size.height = height
        
        return layoutAttributes
    }
    
    public func fillWith(item: OpenWithTutorialStep, at position: Int, giniConfiguration: GiniConfiguration) {
        stepIndicator.text = String(describing: position + 1)
        stepTitle.text = item.title
        stepTitle.font = giniConfiguration.customFont.with(weight: .regular,
                                                           size: OpenWithTutorialCollectionCell.maxTitleFontSize,
                                                           style: .headline)
        stepSubTitle.text = item.subtitle
        stepSubTitle.font = giniConfiguration.customFont.with(weight: .regular,
                                                              size: OpenWithTutorialCollectionCell.maxSubtitleFontSize,
                                                              style: .headline)
        stepImage.image = item.image
    }
}

