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
        toolbar.backgroundColor = GiniBankColors.dark03.toUIColor

        return toolbar
    }()

    private lazy var previousButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "chevron.up"),
                                     style: .plain,
                                     target: self,
                                     action: #selector(previousTapped))

        return button
    }()

    private lazy var nextButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "chevron.down"),
                                     style: .plain,
                                     target: self,
                                     action: #selector(nextTapped))

        return button
    }()

    private lazy var cancelButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .done,
                                     target: self,
                                     action: #selector(cancelTapped))

        return button
    }()

    private lazy var flexibleSpace: UIBarButtonItem = {
        UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }()

    weak var delegate: GiniInputAccessoryViewDelegate?
    private var textFields: [UIView] = []
    private var currentIndex: Int = 0

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    convenience init(fields: [UIView]) {
        self.init(frame: .zero)
        self.textFields = fields
        updateButtonStates()
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

    func configure(with textFields: [UIView], currentField: UIView) {
        self.textFields = textFields
        self.currentIndex = textFields.firstIndex(of: currentField) ?? 0
        updateButtonStates()
    }

    func updateCurrentField(_ field: UIView) {
        currentIndex = textFields.firstIndex(of: field) ?? 0
        updateButtonStates()
    }

    private func updateButtonStates() {
        previousButton.isEnabled = currentIndex > 0
        nextButton.isEnabled = currentIndex < textFields.count - 1
        previousButton.tintColor = previousButton.isEnabled ? .systemBlue : .systemGray3
        nextButton.tintColor = nextButton.isEnabled ? .systemBlue : .systemGray3
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

    func setupInputAccessoryView(for views: [GiniInputAccessoryViewPresentable]) {
        let accessoryView = GiniInputAccessoryView(fields: views.compactMap { $0 as? UIView })
        accessoryView.delegate = self as? GiniInputAccessoryViewDelegate

        for var view in views {
            view.inputAccessoryView = accessoryView
        }
    }
}
