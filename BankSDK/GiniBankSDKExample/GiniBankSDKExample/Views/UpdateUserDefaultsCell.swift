//
//  UpdateUserDefaultsCell.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
protocol UpdateUserDefaultsCellDelegate: AnyObject {
    func didTapRemoveButton(in view: UpdateUserDefaultsCell)
}

class UpdateUserDefaultsCell: UITableViewCell, CodeLoadableView {

    let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 17.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let removeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Remove from UserDefaults", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        return view
    }()

    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    weak var delegate: UpdateUserDefaultsCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        removeButton.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Setup subviews and layout constraints
    private func setupViews() {
        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(removeButton)

        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    func set(message: String, buttonActive: Bool) {
        messageLabel.text = message
        updateButtonState(isActive: buttonActive)
    }

    func updateButtonState(isActive: Bool) {
        // Enable or disable the button based on buttonActive
        removeButton.isEnabled = isActive

        // Optionally adjust the button's appearance when disabled (e.g., changing opacity)
        removeButton.alpha = isActive ? 1.0 : 0.5  // 1.0 for enabled, 0.5 for disabled
    }

    @objc private func removeButtonTapped() {
        delegate?.didTapRemoveButton(in: self)
    }
}
