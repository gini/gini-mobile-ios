//
//  SupportedFormatsTableViewCell.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 10/23/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit

final class SupportedFormatsTableViewCell: UITableViewCell {
    
    let imageViewSize = CGSize(width: 12, height: 12)
    let imageBackgroundSize = CGSize(width: 22, height: 22)
    
    lazy var imageBackgroundView: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: self.imageBackgroundSize))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = view.frame.width / 2
        return view
    }()
    
    func addSubViewsAndlayout() {
        
        if let imageView = imageView {
            imageView.tintColor = .white
            imageView.frame = CGRect(origin: CGPoint(x: imageView.frame.origin.x,
                                                     y: (self.frame.height - imageViewSize.height) / 2),
                                     size: imageViewSize)
            contentView.insertSubview(imageBackgroundView, belowSubview: imageView)
            addConstraints()
        }
        
        if let textLabel = textLabel {
            textLabel.numberOfLines = 0
            let textOrigin = CGPoint(x: textLabel.frame.origin.x + imageBackgroundSize.width - imageViewSize.width,
                                     y: textLabel.frame.origin.y)
            textLabel.frame.origin = textOrigin
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubViewsAndlayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addConstraints() {
        Constraints.active(item: imageBackgroundView, attr: .centerX, relatedBy: .equal, to: imageView!, attr: .centerX)
        Constraints.active(item: imageBackgroundView, attr: .centerY, relatedBy: .equal, to: imageView!, attr: .centerY)
        
        Constraints.active(item: imageBackgroundView, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                          constant: 22)
        Constraints.active(item: imageBackgroundView, attr: .width, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                          constant: 22)
    }
}
