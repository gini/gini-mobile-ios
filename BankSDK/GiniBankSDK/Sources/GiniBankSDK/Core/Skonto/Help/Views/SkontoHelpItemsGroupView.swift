//
//  SkontoHelpItemsGroupView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

class SkontoHelpItemsGroupView: UIView {
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = Constants.stackViewSpacing
        return stackView
    }()

    private let configuration = GiniBankConfiguration.shared

    private let viewModel: SkontoHelpViewModel

    init(viewModel: SkontoHelpViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .giniColorScheme().bg.surface.uiColor()
        layer.cornerRadius = Constants.cornerRadius
        layer.masksToBounds = true

        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        viewModel.items.enumerated().forEach { index, item in
            let view = SkontoHelpItemView(content: item, separator: index < viewModel.items.count - 1)
            stackView.addArrangedSubview(view)
        }
    }
}

private extension SkontoHelpItemsGroupView {
    enum Constants {
        static let stackViewSpacing: CGFloat = 0
        static let cornerRadius: CGFloat = 8
    }
}
