//
//  CameraNotAuthorizedView.swift
//  GiniCapture
//
//  Created by Peter Pult on 06/07/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

final class CameraNotAuthorizedView: UIView {
    
    // User interface
    fileprivate var label = UILabel()
    fileprivate var button = UIButton()
    fileprivate var imageView = UIImageView()
    fileprivate var contentView = UIView()
    
    // Images
    fileprivate var noCameraImage: UIImage? {
        return UIImageNamedPreferred(named: "cameraNotAuthorizedIcon")
    }
    
    init(giniConfiguration: GiniConfiguration = GiniConfiguration.shared) {
        super.init(frame: CGRect.zero)
        
        // Configure image view
        imageView.image = noCameraImage
        imageView.contentMode = .scaleAspectFit
        
        // Configure label
        label.text = .localized(resource: CameraStrings.notAuthorizedMessage)
        label.numberOfLines = 0
        label.textColor = giniConfiguration.cameraNotAuthorizedTextColor
        label.textAlignment = .center
        label.font = giniConfiguration.customFont.with(weight: .thin, size: 20, style: .title2)
        
        // Configure button
        button.setTitle(.localized(resource: CameraStrings.notAuthorizedButton), for: .normal)
        button.setTitleColor(giniConfiguration.cameraNotAuthorizedButtonTitleColor, for: .normal)
        button.setTitleColor(giniConfiguration.cameraNotAuthorizedButtonTitleColor.withAlphaComponent(0.8),
                             for: .highlighted)
        button.titleLabel?.font = giniConfiguration.customFont.with(weight: .regular, size: 20, style: .caption1)

        button.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        
        // Configure view hierachy
        addSubview(contentView)
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        contentView.addSubview(button)
        
        // Add constraints
        addConstraints()
    }
    
    /**
     Returns an object initialized from data in a given unarchiver.
     
     - warning: Not implemented.
     */
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func openSettings(_ sender: AnyObject) {
        UIApplication.shared.openAppSettings()
    }
    
    // MARK: Constraints
    fileprivate func addConstraints() {
        let superview = self
        
        // Content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        Constraints.active(item: contentView, attr: .top, relatedBy: .greaterThanOrEqual, to: superview, attr: .top,
                          constant: 30)
        Constraints.active(item: contentView, attr: .centerX, relatedBy: .equal, to: superview, attr: .centerX)
        Constraints.active(item: contentView, attr: .centerY, relatedBy: .equal, to: superview, attr: .centerY,
                          constant: 5, priority: 999)
        
        // Image view
        imageView.translatesAutoresizingMaskIntoConstraints = false
        Constraints.active(item: imageView, attr: .top, relatedBy: .equal, to: contentView, attr: .top)
        Constraints.active(item: imageView, attr: .width, relatedBy: .lessThanOrEqual, to: nil, attr: .width,
                          constant: 204)
        Constraints.active(item: imageView, attr: .width, relatedBy: .greaterThanOrEqual, to: nil, attr: .width,
                          constant: 75)
        Constraints.active(item: imageView, attr: .height, relatedBy: .lessThanOrEqual, to: nil, attr: .height,
                          constant: 75)
        Constraints.active(item: imageView, attr: .height, relatedBy: .greaterThanOrEqual, to: nil, attr: .height,
                          constant: 50)
        Constraints.active(item: imageView, attr: .centerX, relatedBy: .equal, to: contentView, attr: .centerX)
        
        // Text label
        label.translatesAutoresizingMaskIntoConstraints = false
        Constraints.active(item: label, attr: .top, relatedBy: .equal, to: imageView, attr: .bottom, constant: 35)
        Constraints.active(item: label, attr: .trailing, relatedBy: .equal, to: contentView, attr: .trailing)
        Constraints.active(item: label, attr: .leading, relatedBy: .equal, to: contentView, attr: .leading)
        Constraints.active(item: label, attr: .width, relatedBy: .equal, to: nil, attr: .width, constant: 250)
        Constraints.active(item: label, attr: .height, relatedBy: .greaterThanOrEqual, to: nil, attr: .height,
                          constant: 70)
        
        // Button
        button.translatesAutoresizingMaskIntoConstraints = false
        Constraints.active(item: button, attr: .top, relatedBy: .equal, to: label, attr: .bottom, constant: 10)
        Constraints.active(item: button, attr: .bottom, relatedBy: .equal, to: contentView, attr: .bottom)
        Constraints.active(item: button, attr: .width, relatedBy: .equal, to: label, attr: .width)
        Constraints.active(item: button, attr: .height, relatedBy: .equal, to: nil, attr: .height, constant: 35)
        Constraints.active(item: button, attr: .centerX, relatedBy: .equal, to: contentView, attr: .centerX)
    }
    
}
