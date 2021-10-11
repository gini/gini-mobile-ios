//
//  PageCollectionViewCell.swift
//  GiniHealth
//
//  Created by Nadya Karaban on 07.04.21.
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
