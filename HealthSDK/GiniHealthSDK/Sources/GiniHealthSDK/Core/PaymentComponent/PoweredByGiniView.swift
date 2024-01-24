//
//  PoweredByGiniView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

final class PoweredByGiniView: UIView {
    
    var viewModel: PoweredByGiniViewModel! {
        didSet {
            setupView()
        }
    }
    
    private lazy var poweredByGiniView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame = CGRect(x: 0, y: 0, width: .min, height: 22)
        return view
    }()
    
    private lazy var poweredByGiniLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = viewModel.poweredByGiniLabelText
        label.textColor = viewModel.poweredByGiniLabelAccentColor
        label.font = viewModel.poweredByGiniLabelFont
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var giniImageView: UIImageView = {
        let image = UIImageNamedPreferred(named: viewModel.giniIconName)
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 0, y: 0, width: 28, height: 18)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        poweredByGiniView.addSubview(poweredByGiniLabel)
        poweredByGiniView.addSubview(giniImageView)
        self.frame = CGRect(x: 0, y: 0, width: .min, height: 22)
        self.addSubview(poweredByGiniView)
        
        NSLayoutConstraint.activate([
            poweredByGiniView.trailingAnchor.constraint(equalTo: trailingAnchor),
            poweredByGiniView.leadingAnchor.constraint(equalTo: leadingAnchor),
            poweredByGiniView.topAnchor.constraint(equalTo: topAnchor),
            poweredByGiniView.bottomAnchor.constraint(equalTo: bottomAnchor),
            poweredByGiniView.trailingAnchor.constraint(equalTo: giniImageView.trailingAnchor),
            poweredByGiniView.centerYAnchor.constraint(equalTo: giniImageView.centerYAnchor),
            giniImageView.leadingAnchor.constraint(equalTo: poweredByGiniLabel.trailingAnchor, constant: 4),
            poweredByGiniLabel.centerYAnchor.constraint(equalTo: poweredByGiniView.centerYAnchor),
            poweredByGiniLabel.leadingAnchor.constraint(equalTo: poweredByGiniView.leadingAnchor, constant: 0),
            poweredByGiniLabel.topAnchor.constraint(equalTo: poweredByGiniView.topAnchor, constant: 0),
            poweredByGiniView.bottomAnchor.constraint(equalTo: poweredByGiniView.bottomAnchor, constant: 0),
            giniImageView.heightAnchor.constraint(equalToConstant: giniImageView.frame.height),
            giniImageView.widthAnchor.constraint(equalToConstant: giniImageView.frame.width)
        ])
    }
}
