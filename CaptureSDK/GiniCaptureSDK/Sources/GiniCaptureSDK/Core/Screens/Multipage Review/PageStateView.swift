//
//  PageStateView.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 4/13/18.
//

import UIKit

final class PageStateView: UIView {
    
    enum State {
        case succeeded, failed, loading
    }
    
    lazy private(set) var icon: UIImageView  = {
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        
        return icon
    }()
    
    lazy private(set) var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .white)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(icon)
        addSubview(loadingIndicator)
        addConstraints()
    }
    
    func addConstraints() {
        // loadingIndicator
        Constraints.active(item: loadingIndicator, attr: .centerX, relatedBy: .equal, to: self, attr: .centerX)
        Constraints.active(item: loadingIndicator, attr: .centerY, relatedBy: .equal, to: self, attr: .centerY)
        
        // icon
        Constraints.active(item: icon, attr: .top, relatedBy: .equal, to: self, attr: .top, constant: 10)
        Constraints.active(item: icon, attr: .leading, relatedBy: .equal, to: self, attr: .leading, constant: 10)
        Constraints.active(item: icon, attr: .trailing, relatedBy: .equal, to: self, attr: .trailing, constant: -10)
        Constraints.active(item: icon, attr: .bottom, relatedBy: .equal, to: self, attr: .bottom, constant: -10)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(to status: State) {
        switch status {
        case .succeeded:
            backgroundColor = Colors.Gini.springGreen
            icon.image = UIImage.init(named: "successfullUploadIcon",
                                      in: giniCaptureBundle(),
                                      compatibleWith: nil)
            loadingIndicator.stopAnimating()
            
        case .failed:
            backgroundColor = Colors.Gini.crimson
            icon.image = UIImage.init(named: "failureUploadIcon",
                                      in: giniCaptureBundle(),
                                      compatibleWith: nil)
            loadingIndicator.stopAnimating()
        case .loading:
            backgroundColor = .clear
            icon.image = nil
            loadingIndicator.startAnimating()
        }
    }
}
