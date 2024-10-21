//
//  SettingsHeaderView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

class SettingsHeaderView: UITableViewHeaderFooterView {
    static let identifier = "SettingsHeaderView"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Initializer
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Configure the header view with a title
    func configure(with title: String) {
        titleLabel.text = title
    }
}

