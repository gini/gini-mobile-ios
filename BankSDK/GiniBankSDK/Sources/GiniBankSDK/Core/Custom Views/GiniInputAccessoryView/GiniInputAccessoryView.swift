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

protocol GiniInputAccessoryViewPresentable {
    var inputAccessoryView: UIView? { get set }
}

final class GiniInputAccessoryView: UIView {

    private lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()

        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.barStyle = .default
        toolbar.backgroundColor = configuration.backgroundColor

        return toolbar
    }()

    private lazy var previousButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: configuration.previousButtonImage,
                                     style: .plain,
                                     target: self,
                                     action: #selector(previousTapped))

        button.tintColor = configuration.tintColor

        return button
    }()

    private lazy var nextButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: configuration.nextButtonImage,
                                     style: .plain,
                                     target: self,
                                     action: #selector(nextTapped))

        button.tintColor = configuration.tintColor

        return button
    }()

    private lazy var cancelButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .done,
                                     target: self,
                                     action: #selector(cancelTapped))

        return button
    }()

    private let configuration: GiniInputAccessoryViewConfiguration
    private let textFields: [UIView]

    private lazy var flexibleSpace: UIBarButtonItem = {
        UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }()

    weak var delegate: GiniInputAccessoryViewDelegate?
    private var currentIndex: Int = 0

    // MARK: - Initialization

    init(fields: [UIView], configuration: GiniInputAccessoryViewConfiguration) {
        let toolbarHeight = 44

        self.textFields = fields
        self.configuration = configuration
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
        previousButton.isEnabled = currentIndex > 0
        nextButton.isEnabled = currentIndex < textFields.count - 1
        previousButton.tintColor = previousButton.isEnabled ? configuration.tintColor : configuration.disabledTintColor
        nextButton.tintColor = nextButton.isEnabled ? configuration.tintColor : configuration.disabledTintColor
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

extension UIViewController {

    func setupInputAccessoryView(for views: [GiniInputAccessoryViewPresentable],
                                 configuration: GiniInputAccessoryViewConfiguration) {
        let accessoryView = GiniInputAccessoryView(fields: views.compactMap { $0 as? UIView },
                                                   configuration: configuration)

        accessoryView.delegate = self as? GiniInputAccessoryViewDelegate

        for var view in views {
            view.inputAccessoryView = accessoryView
        }
    }
}
