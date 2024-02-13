//
//  PaymentProvidersBottomViewController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

final class PaymentProvidersBottomViewController: UIViewController {
    var bottomSheet: PaymentProvidersBottomView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .blue
        setupViewHierarchy()
        setupViewAttributes()
        setupLayout()
    }

    func setupViewHierarchy(){
        self.view.addSubview(bottomSheet)
    }

    func setupViewAttributes(){
        self.view.backgroundColor = .clear
        bottomSheet.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupLayout(){
        NSLayoutConstraint.activate([
            bottomSheet.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            bottomSheet.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -200),
            bottomSheet.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            bottomSheet.heightAnchor.constraint(equalToConstant: 400)
        ])
    }
}
