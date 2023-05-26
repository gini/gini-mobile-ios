//
//  OpenWithTutorialCollectionHeader.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 10/24/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit

final class OpenWithTutorialCollectionHeader: UICollectionReusableView {
    
    let padding:(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) = (20, 20, 20, 20)
    
    lazy var headerContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    static let maxHeaderFontSize: CGFloat = UIDevice.current.isIpad ? 16 : 14
    
    lazy var headerTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 12 / OpenWithTutorialCollectionHeader.maxHeaderFontSize
        return label
    }()
    
    lazy var bottomLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = nil
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        headerContainer.addSubview(headerTitle)
        addSubview(headerContainer)
        addSubview(bottomLine)
        
        addConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(frame:) should be used instead")
    }
    
    private func addConstraints() {
        Constraints.active(item: headerContainer, attr: .top, relatedBy: .equal, to: self, attr: .top)
        Constraints.active(item: headerContainer, attr: .leading, relatedBy: .equal, to: self, attr: .leading)
        Constraints.active(item: headerContainer, attr: .trailing, relatedBy: .equal, to: self, attr: .trailing)
        
        Constraints.active(item: headerTitle, attr: .top, relatedBy: .equal, to: headerContainer, attr: .top,
                          constant: padding.top)
        Constraints.active(item: headerTitle, attr: .leading, relatedBy: .equal, to: headerContainer, attr: .leading,
                          constant: padding.left)
        Constraints.active(item: headerTitle, attr: .trailing, relatedBy: .equal, to: headerContainer, attr: .trailing,
                          constant: -padding.right)
        Constraints.active(item: headerTitle, attr: .bottom, relatedBy: .equal, to: headerContainer, attr: .bottom,
                          constant: -padding.bottom)
        
        Constraints.active(item: bottomLine, attr: .top, relatedBy: .equal, to: headerContainer, attr: .bottom)
        Constraints.active(item: bottomLine, attr: .leading, relatedBy: .equal, to: self, attr: .leading)
        Constraints.active(item: bottomLine, attr: .trailing, relatedBy: .equal, to: self, attr: .trailing)
        Constraints.active(item: bottomLine, attr: .bottom, relatedBy: .equal, to: self, attr: .bottom)
        Constraints.active(item: bottomLine, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                          constant: 1)
    }
}

