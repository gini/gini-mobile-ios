//
//  PaymentProvidersBottomView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

class PaymentProvidersBottomView: UIView {

    var viewModel: PaymentProvidersBottomViewModel! {
        didSet {
            setupView()
        }
    }

    private lazy var mainLabel: UILabel = {
        let label = UILabel()
        label.text = "Payment providers"
        label.font = UIFont.systemFont(ofSize: 24)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        setupViewHierarchy()
        setupViewAttributes()
        setupLayout()
    }

    private func setupViewHierarchy(){
        self.addSubview(mainLabel)
    }

    private func setupViewAttributes(){
        self.backgroundColor = viewModel.backgroundColor
        self.layer.cornerRadius = 40
    }

    private func setupLayout(){
        NSLayoutConstraint.activate([
            mainLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            mainLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 50)
        ])
    }
}
