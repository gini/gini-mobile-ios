//
//  CaptureSuggestionsCollectionCell.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 10/25/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit

final class CaptureSuggestionsCollectionCell: UICollectionViewCell {
    
    var suggestionImage: UIImageView = {
        let suggestionImage = UIImageView()
        suggestionImage.translatesAutoresizingMaskIntoConstraints = false
        suggestionImage.contentMode = .scaleAspectFit
        return suggestionImage
    }()
    
    var suggestionText: UILabel = {
        let suggestionText = UILabel()
        suggestionText.translatesAutoresizingMaskIntoConstraints = false
        suggestionText.numberOfLines = 0
        suggestionText.adjustsFontSizeToFitWidth = true
        suggestionText.minimumScaleFactor = 10 / 14
        return suggestionText
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(suggestionImage)
        addSubview(suggestionText)
        addConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(frame:) should be used instead")
    }
    
    private func addConstraints() {
        Constraints.active(item: suggestionImage, attr: .top, relatedBy: .equal, to: self, attr: .top, priority: 999)
        Constraints.active(item: suggestionImage, attr: .bottom, relatedBy: .equal, to: self, attr: .bottom,
                          priority: 999)
        Constraints.active(item: suggestionImage, attr: .leading, relatedBy: .equal, to: self, attr: .leading,
                          constant: 20)
        Constraints.active(item: suggestionImage, attr: .trailing, relatedBy: .equal, to: suggestionText,
                          attr: .leading, constant: -20)
        Constraints.active(item: suggestionImage, attr: .width, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                          constant: 85)
        Constraints.active(item: suggestionImage, attr: .height, relatedBy: .lessThanOrEqual, to: nil,
                          attr: .notAnAttribute, constant: 75)
        Constraints.active(item: suggestionImage, attr: .centerY, relatedBy: .equal, to: self, attr: .centerY)
        
        Constraints.active(item: suggestionText, attr: .top, relatedBy: .equal, to: self, attr: .top)
        Constraints.active(item: suggestionText, attr: .bottom, relatedBy: .equal, to: self, attr: .bottom)
        Constraints.active(item: suggestionText, attr: .trailing, relatedBy: .equal, to: self, attr: .trailing,
                          constant: -20, priority: 999)
    }
}

