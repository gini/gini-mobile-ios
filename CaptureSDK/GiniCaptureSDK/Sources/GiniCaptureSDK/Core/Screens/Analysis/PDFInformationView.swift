//
//  PDFInformationView.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 9/25/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation
import UIKit

final class PDFInformationView: UIView {
    
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    var shadowLayer: CALayer?
    var viewBelow: UIView?
    
    init(title: String,
         subtitle: String,
         textColor: UIColor,
         textFont: UIFont,
         backgroundColor: UIColor,
         superView: UIView?,
         viewBelow: UIView? = nil) {
        super.init(frame: .zero)
        guard let superView = superView else { return }
        
        self.viewBelow = viewBelow
        self.backgroundColor = backgroundColor
        self.alpha = 0
        
        titleLabel.text = title
        titleLabel.textColor = textColor
        titleLabel.textAlignment = .center
        titleLabel.font = textFont.withSize(20.0)
        titleLabel.minimumScaleFactor = 18.0 / 20.0
        titleLabel.adjustsFontSizeToFitWidth = true
        
        subtitleLabel.text = subtitle
        subtitleLabel.textColor = textColor
        subtitleLabel.textAlignment = .center
        subtitleLabel.font = textFont.withSize(16.0)
        
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        
        addInnerShadow()
        superView.addSubview(self)
        
        addConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("You should use init(title:subtitle:textColor:background) initializer")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        arrangeShadow()
    }
    
    fileprivate func addConstraints() {
        guard let superview = superview else { return }
        self.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        Constraints.active(item: self, attr: .top, relatedBy: .equal, to: superview, attr: .top)
        Constraints.active(item: self, attr: .leading, relatedBy: .equal, to: superview, attr: .leading)
        Constraints.active(item: self, attr: .trailing, relatedBy: .equal, to: superview, attr: .trailing)
        Constraints.active(item: self, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute, constant: 95)

        if let viewBelow = viewBelow {
            Constraints.active(item: self, attr: .bottom, relatedBy: .equal, to: viewBelow, attr: .top)
        }
        
        Constraints.active(item: titleLabel, attr: .top, relatedBy: .equal, to: self, attr: .top, constant: 16)
        Constraints.active(item: titleLabel, attr: .bottom, relatedBy: .equal, to: subtitleLabel, attr: .top,
                          constant: -16)
        Constraints.active(item: titleLabel, attr: .leading, relatedBy: .equal, to: self, attr: .leading, constant: 16)
        Constraints.active(item: titleLabel, attr: .trailing, relatedBy: .equal, to: self, attr: .trailing,
                          constant: -16, priority: 999)

        Constraints.active(item: subtitleLabel, attr: .leading, relatedBy: .equal, to: self, attr: .leading,
                          constant: 16)
        Constraints.active(item: subtitleLabel, attr: .trailing, relatedBy: .equal, to: self, attr: .trailing,
                          constant: -16, priority: 999)
        Constraints.active(item: subtitleLabel, attr: .bottom, relatedBy: .equal, to: self, attr: .bottom,
                          constant: -16, priority: 999)

    }
    
    fileprivate func addInnerShadow() {
        if shadowLayer == nil {
            let size = self.frame.size
            self.clipsToBounds = true
            let layer: CALayer = CALayer()
            layer.backgroundColor = UIColor.lightGray.cgColor
            layer.position = CGPoint(x: size.width / 2, y: -size.height / 2 + 0.5)
            layer.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            layer.shadowColor = UIColor.darkGray.cgColor
            layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
            layer.shadowOpacity = 0.8
            layer.shadowRadius = 5.0
            layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
            shadowLayer = layer
            
            self.layer.addSublayer(layer)
        }
    }
    
    fileprivate func arrangeShadow() {
        let size = self.frame.size
        shadowLayer?.position = CGPoint(x: size.width / 2, y: -size.height / 2 + 0.5)
        shadowLayer?.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    }
}

// MARK: Show and hide

extension PDFInformationView {
    func show(after seconds: Double = 0) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: {
            UIView.animate(withDuration: 0.5) {
                self.alpha = 1.0
            }
        })
    }
}
