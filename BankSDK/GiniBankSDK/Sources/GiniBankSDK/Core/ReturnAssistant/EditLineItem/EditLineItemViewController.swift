//
//  EditLineItemViewController.swift
//  
//
//  Created by David Vizaknai on 06.03.2023.
//

import UIKit

final class EditLineItemViewController: UIViewController {
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .GiniBank.light1
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .GiniBank.dark1
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var editLineItemView: EditLineItemView = {
        let view = EditLineItemView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var currentContainerHeight: CGFloat = 300
    private var currentBottomPadding: CGFloat = 0

    private var defaultHeight: CGFloat = 340

    private var containerViewHeightConstraint: NSLayoutConstraint?
    private var containerViewBottomConstraint: NSLayoutConstraint?

    init(lineItemViewModel: EditLineItemViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.editLineItemView.viewModel = lineItemViewModel
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        calculateContainerHeight()
        setupView()
        setupConstraints()
        setupPanGesture()
        setupTapGesture()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animatePresentContainer()
        animateDimmedView()
    }

    private func setupView() {
        view.backgroundColor = .clear
    }

    private func setupConstraints() {
        view.addSubview(dimmedView)
        view.addSubview(containerView)
        containerView.addSubview(editLineItemView)

        NSLayoutConstraint.activate([
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            editLineItemView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            editLineItemView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            editLineItemView.topAnchor.constraint(equalTo: containerView.topAnchor),
            editLineItemView.heightAnchor.constraint(equalToConstant: defaultHeight),
            editLineItemView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor)
        ])

        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: defaultHeight)
        containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        if UIDevice.current.isIpad {
            NSLayoutConstraint.activate([
                containerView.widthAnchor.constraint(equalTo: view.widthAnchor,
                                                     multiplier: Constants.tabletWidthMultiplier),
                containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
            containerViewBottomConstraint?.constant = defaultHeight
        } else {
            NSLayoutConstraint.activate([
                containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }
        containerViewHeightConstraint?.isActive = true
        containerViewBottomConstraint?.isActive = true
    }

    private func calculateContainerHeight() {
        let normalSize: CGFloat = 17 // size of the .body textstyle when the font is not set bigger in accessibility
        if let pointSize = GiniBankConfiguration.shared.textStyleFonts[.body]?.pointSize {
            let diff = pointSize - normalSize
            let height = defaultHeight + 6 * diff //adding the extra difference for the 6 lines of the edit screen
            defaultHeight = min(height, self.view.frame.height)
        }
    }

    private func animatePresentContainer() {
        var bottomPadding: CGFloat
        if UIDevice.current.isIpad {
            bottomPadding = (view.bounds.height - defaultHeight) / 2
            currentBottomPadding = bottomPadding
        } else {
            bottomPadding = 0
        }

        UIView.animate(withDuration: Constants.animationDuration) {
            self.containerViewBottomConstraint?.constant = -bottomPadding
            self.view.layoutIfNeeded()
        }
    }

    private func animateDimmedView() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.dimmedView.alpha = Constants.maxDimmedAlpha
        }
    }

    private func animateDismissView() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.containerViewBottomConstraint?.constant = self.defaultHeight
            self.view.layoutIfNeeded()
        }

        dimmedView.alpha = Constants.maxDimmedAlpha
        UIView.animate(withDuration: Constants.animationDuration) {
            self.dimmedView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }

    // Pan gesture recognizer to move the container on tablet or change the height on phone.
    private func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
    }

    // Tap gesture recognizer to dismiss the viewcontroller
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTapGesture))
        tapGesture.delaysTouchesBegan = false
        tapGesture.delaysTouchesEnded = false
        dimmedView.addGestureRecognizer(tapGesture)
    }

    // Handling the pan gesture
    @objc
    private func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
            let newHeight = currentContainerHeight - translation.y
            let newBottomPadding = currentBottomPadding - translation.y

            switch gesture.state {
            // Pan is still in progress
            case .changed:
                if UIDevice.current.isIpad {
                    // Move the container based on the pan gesture
                    containerViewBottomConstraint?.constant = -newBottomPadding
                    view.layoutIfNeeded()
                } else {
                    // Resize the container based on the pan gesture
                    if newHeight < Constants.maximumContainerHeight {
                        containerViewHeightConstraint?.constant = newHeight
                        if newHeight < defaultHeight {
                            let alpha = newHeight / defaultHeight
                            editLineItemView.alpha = alpha - 0.2
                        } else {
                            editLineItemView.alpha = 1
                        }
                        view.layoutIfNeeded()
                    }
                }
            case .ended:
                // Pan ended
                if UIDevice.current.isIpad {
                    /* Dismiss the view if the bottom padding is half of the standard padding
                     or animate back to initial position of not */
                    if newBottomPadding < currentBottomPadding / 2 {
                        animateDismissView()
                    } else {
                        animateContainerToInitialPosition()
                    }
                } else {
                    /* Dismiss the view if the height is less than minimum height
                     or animate back to initial height of not */
                    if newHeight < Constants.dismissibleHeight {
                        animateDismissView()
                    } else {
                        editLineItemView.alpha = 1
                        animateContainerToInitialHeight()
                    }
                }
            default:
                break
            }
        }

    @objc
    private func handleTapGesture() {
        animateDismissView()
    }

    private func animateContainerToInitialHeight() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.containerViewHeightConstraint?.constant = self.defaultHeight
            self.view.layoutIfNeeded()
        }
        currentContainerHeight = defaultHeight
    }

    private func animateContainerToInitialPosition() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.containerViewBottomConstraint?.constant = -self.currentBottomPadding
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Handle keyboard appearance
    @objc
    private func keyboardWillAppear(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height

            if UIDevice.current.isIpad {
                if currentBottomPadding < keyboardHeight {
                    UIView.animate(withDuration: Constants.animationDuration) {
                        self.containerViewBottomConstraint?.constant = -keyboardHeight
                        self.view.layoutIfNeeded()
                    }
                }
            } else {
                let height = min(self.defaultHeight + keyboardHeight, self.view.frame.height)
                UIView.animate(withDuration: Constants.animationDuration) {
                    self.containerViewHeightConstraint?.constant = height
                    self.view.layoutIfNeeded()
                }
                currentContainerHeight = height
            }
        }
    }

    @objc
    private func keyboardWillDisappear() {
        if UIDevice.current.isIpad {
            animateContainerToInitialPosition()
        } else {
            animateContainerToInitialHeight()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
}

private extension EditLineItemViewController {
    enum Constants {
        static let maxDimmedAlpha: CGFloat = 0.6
        static let defaultHeight: CGFloat = 526
        static let dismissibleHeight: CGFloat = 200
        static let maximumContainerHeight: CGFloat = UIScreen.main.bounds.height - 64
        static let tabletWidthMultiplier: CGFloat = 0.6
        static let animationDuration: CGFloat = 0.3
    }
}
