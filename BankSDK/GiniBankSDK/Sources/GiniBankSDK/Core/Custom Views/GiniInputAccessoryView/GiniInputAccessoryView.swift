//
//  GiniInputAccessoryView.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

protocol GiniInputAccessoryViewDelegate: AnyObject {
    func inputAccessoryView(_ view: GiniInputAccessoryView, didSelectPrevious field: UIView)
    func inputAccessoryView(_ view: GiniInputAccessoryView, didSelectNext field: UIView)
    func inputAccessoryViewDidCancel(_ view: GiniInputAccessoryView)
}

final class GiniInputAccessoryView: UIView {

    private lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()

        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.barStyle = .default
        toolbar.backgroundColor = .giniColorScheme().inputAccessoryView.background.uiColor()

        return toolbar
    }()

    private lazy var previousButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: GiniImages.chevronUp.image,
                                     style: .plain,
                                     target: self,
                                     action: #selector(previousTapped))

        button.tintColor = .giniColorScheme().inputAccessoryView.tintColor.uiColor()

        return button
    }()

    private lazy var nextButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: GiniImages.chevronDown.image,
                                     style: .plain,
                                     target: self,
                                     action: #selector(nextTapped))

        button.tintColor = .giniColorScheme().inputAccessoryView.tintColor.uiColor()

        return button
    }()

    private lazy var cancelButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .done,
                                     target: self,
                                     action: #selector(cancelTapped))

        return button
    }()

    private let textFields: [UIView]

    private lazy var flexibleSpace: UIBarButtonItem = {
        UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }()

    weak var delegate: GiniInputAccessoryViewDelegate?
    private var currentIndex: Int = 0

    // MARK: - Initialization

    init(fields: [UIView]) {
        let toolbarHeight: Int = 44

        self.textFields = fields
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: toolbarHeight))
        setupView()
        updateButtonStates()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupView() {
        addSubview(toolbar)

        NSLayoutConstraint.activate([
            toolbar.topAnchor.constraint(equalTo: topAnchor),
            toolbar.leadingAnchor.constraint(equalTo: leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        setupToolbarItems()
    }

    private func setupToolbarItems() {
        let toolbarItems = [previousButton,
                            nextButton,
                            flexibleSpace,
                            cancelButton]

        toolbar.setItems(toolbarItems,
                         animated: false)
    }

    func updateCurrentField(_ field: UIView) {
        currentIndex = textFields.firstIndex(of: field) ?? 0
        updateButtonStates()
    }

    private func updateButtonStates() {
        let enabledTintColor: UIColor = .giniColorScheme().inputAccessoryView.tintColor.uiColor()
        let disabledTintColor: UIColor = .giniColorScheme().inputAccessoryView.disabledTintColor.uiColor()

        previousButton.isEnabled = currentIndex > 0
        nextButton.isEnabled = currentIndex < textFields.count - 1
        previousButton.tintColor = previousButton.isEnabled ? enabledTintColor : disabledTintColor
        nextButton.tintColor = nextButton.isEnabled ? enabledTintColor : disabledTintColor
    }

    @objc private func previousTapped() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        let previousField = textFields[currentIndex]
        delegate?.inputAccessoryView(self, didSelectPrevious: previousField)
        updateButtonStates()
    }

    @objc private func nextTapped() {
        guard currentIndex < textFields.count - 1 else { return }
        currentIndex += 1
        let nextField = textFields[currentIndex]
        delegate?.inputAccessoryView(self, didSelectNext: nextField)
        updateButtonStates()
    }

    @objc private func cancelTapped() {
        delegate?.inputAccessoryViewDidCancel(self)
    }
}
