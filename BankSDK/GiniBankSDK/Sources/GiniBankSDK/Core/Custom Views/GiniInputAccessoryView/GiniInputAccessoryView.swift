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
    private var toolbarBottomConstraint: NSLayoutConstraint?

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

    /** Grows the container on iOS 26 portrait so the Liquid Glass Done pill clears the keyboard. */
    override var intrinsicContentSize: CGSize {
        if shouldUseExpandedLayout {
            return CGSize(width: UIView.noIntrinsicMetric, height: Constants.iOS26ContainerHeight)
        }
        return super.intrinsicContentSize
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass else { return }
        invalidateIntrinsicContentSize()
        toolbarBottomConstraint?.constant = currentToolbarBottomInset
    }

    private var shouldUseExpandedLayout: Bool {
        if #available(iOS 26, *) {
            return traitCollection.verticalSizeClass == .regular
        }
        return false
    }

    private var currentToolbarBottomInset: CGFloat {
        shouldUseExpandedLayout ? Constants.iOS26ToolbarBottomInset : 0
    }

    // MARK: - Setup
    private func setupView() {
        addSubview(toolbar)

        let bottomConstraint = toolbar.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                               constant: currentToolbarBottomInset)
        toolbarBottomConstraint = bottomConstraint
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomConstraint,
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
        static let innerToolbarHeight: CGFloat = 44
        static let iOS26ContainerHeight: CGFloat = 56
        static let iOS26ToolbarBottomInset: CGFloat = -4
    }
}
