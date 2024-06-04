//
//  PageCollectionViewCell.swift
//  GiniHealth
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

class PageCollectionViewCell: UICollectionViewCell {

    var pageImageView: ZoomedImageView = {
        let iv = ZoomedImageView()
        iv.setup()
        iv.clipsToBounds = true
        return iv
    }()

    fileprivate func addImageView() {
        contentView.addSubview(pageImageView)
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        addImageView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addImageView()
    }
}
