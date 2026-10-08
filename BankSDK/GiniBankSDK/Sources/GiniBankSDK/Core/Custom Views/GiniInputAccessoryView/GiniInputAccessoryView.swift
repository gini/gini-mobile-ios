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
        toolbar.backgroundColor = .giniBankColorScheme().inputAccessoryView.background.uiColor()

        return toolbar
    }()

    private lazy var previousButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: GiniImages.chevronUp.image,
                                     style: .plain,
                                     target: self,
                                     action: #selector(previousTapped))

        button.tintColor = .giniBankColorScheme().inputAccessoryView.tintColor.uiColor()

        return button
    }()

    private lazy var nextButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: GiniImages.chevronDown.image,
                                     style: .plain,
                                     target: self,
                                     action: #selector(nextTapped))

        button.tintColor = .giniBankColorScheme().inputAccessoryView.tintColor.uiColor()

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
        self.textFields = fields
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: Constants.innerToolbarHeight))
        setupView()
        updateButtonStates()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// On iOS 26 the container grows so the Liquid Glass Done pill does not clip into the keyboard.
    override var intrinsicContentSize: CGSize {
        if #available(iOS 26, *) {
            return CGSize(width: UIView.noIntrinsicMetric, height: Constants.iOS26ContainerHeight)
        }
        return super.intrinsicContentSize
    }

    // MARK: - Setup
    private func setupView() {
        addSubview(toolbar)

        let bottomInset: CGFloat
        if #available(iOS 26, *) {
            bottomInset = Constants.iOS26ToolbarBottomInset
        } else {
            bottomInset = 0
        }
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottomInset),
            toolbar.heightAnchor.constraint(equalToConstant: Constants.innerToolbarHeight)
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
        let enabledTintColor: UIColor = .giniBankColorScheme().inputAccessoryView.tintColor.uiColor()
        let disabledTintColor: UIColor = .giniBankColorScheme().inputAccessoryView.disabledTintColor.uiColor()

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

    private enum Constants {
        /// Height of the `UIToolbar` itself — UIKit's standard toolbar metric. Also the container height on iOS <26.
        static let innerToolbarHeight: CGFloat = 44
        /// Outer container height on iOS 26 — gives the Liquid Glass Done pill room above the toolbar.
        static let iOS26ContainerHeight: CGFloat = 56
        /// Lift the toolbar on iOS 26 to keep the Done pill clear of the keyboard.
        static let iOS26ToolbarBottomInset: CGFloat = -4
    }
}
