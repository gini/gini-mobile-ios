//
//  QREngagementTopView.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

class QREngagementTopView: UIView {
    private lazy var progressView: QREngagementProgressView = {
        let view = QREngagementProgressView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var ingredientBrandView: QREngagementIngredientBrandView = {
        let view = QREngagementIngredientBrandView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(progressView)
        addSubview(ingredientBrandView)

        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: topAnchor),
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor),

            ingredientBrandView.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            ingredientBrandView.leadingAnchor.constraint(equalTo: leadingAnchor),
            ingredientBrandView.trailingAnchor.constraint(equalTo: trailingAnchor),
            ingredientBrandView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func update(currentStep: Int, totalSteps: Int) {
        progressView.update(currentStep: currentStep, totalSteps: totalSteps)
    }
}
