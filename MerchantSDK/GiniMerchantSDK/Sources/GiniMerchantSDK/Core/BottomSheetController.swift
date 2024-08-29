//
//  BottomSheetController.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniUtilites

public class BottomSheetController: UIViewController {
    // MARK: - UI
    /// Main bottom sheet container view
    private lazy var mainContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = backgroundColor
        view.roundCorners(corners: [.topLeft, .topRight], radius: Constants.cornerRadiusView)
        view.layer.cornerRadius = Constants.cornerRadiusView
        view.clipsToBounds = true
        return view
    }()

    /// View to hold dynamic content
    private let contentView = EmptyView()

    /// Top bar view that draggable to dismiss
    private let topBarView = EmptyView()

    /// Top view bar
    private lazy var barLineView: UIView = {
        let view = UIView()
        view.backgroundColor = rectangleColor
        view.layer.cornerRadius = Constants.cornerRadiusTopRectangle
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    /// Dimmed background view
    private lazy var dimmedView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = dimmingBackgroundColor
        view.alpha = 0
        return view
    }()

    let backgroundColor: UIColor = GiniColor.standard7.uiColor()
    let rectangleColor: UIColor = GiniColor.standard5.uiColor()
    let dimmingBackgroundColor: UIColor = GiniColor(lightModeColor: UIColor.black,
                                                    darkModeColor: UIColor.white).uiColor().withAlphaComponent(0.4)
    var minHeight: CGFloat = 0

    // MARK: - View Setup
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupGestures()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animatePresent()
    }

    private func setupViews() {
        view.backgroundColor = .clear
        view.addSubview(dimmedView)
        NSLayoutConstraint.activate([
            // Set dimmedView edges to superview
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        // Container View
        view.addSubview(mainContainerView)
        NSLayoutConstraint.activate([
            mainContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        if minHeight > 0 {
            mainContainerView.topAnchor.constraint(lessThanOrEqualTo: view.topAnchor, constant: obtainTopAnchorMinHeightConstraint()).isActive = true
        } else {
            mainContainerView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: Constants.minTopSpacing).isActive = true
        }

        // Top draggable bar view
        mainContainerView.addSubview(topBarView)
        NSLayoutConstraint.activate([
            topBarView.topAnchor.constraint(equalTo: mainContainerView.topAnchor),
            topBarView.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor),
            topBarView.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor),
            topBarView.heightAnchor.constraint(equalToConstant: Constants.heightTopBarView)
        ])
        topBarView.addSubview(barLineView)
        NSLayoutConstraint.activate([
            barLineView.centerXAnchor.constraint(equalTo: topBarView.centerXAnchor),
            barLineView.topAnchor.constraint(equalTo: topBarView.topAnchor, constant: Constants.topAnchorTopRectangle),
            barLineView.widthAnchor.constraint(equalToConstant: Constants.widthTopRectangle),
            barLineView.heightAnchor.constraint(equalToConstant: Constants.heightTopRectangle)
        ])

        // Content View
        mainContainerView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: topBarView.bottomAnchor),
            contentView.bottomAnchor.constraint(equalTo: mainContainerView.bottomAnchor, constant: -Constants.bottomPaddingConstraint)
        ])
    }

    private func obtainTopAnchorMinHeightConstraint() -> CGFloat {
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let extraBottomSafeAreaConstant = window?.safeAreaInsets.bottom == 0 ? Constants.safeAreaBottomPadding : 0 // fix for small devices
        let topAnchorWithMinHeightConstant = view.frame.height - minHeight + extraBottomSafeAreaConstant
        return topAnchorWithMinHeightConstant
    }

    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapDimmedView))
        dimmedView.addGestureRecognizer(tapGesture)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        topBarView.addGestureRecognizer(panGesture)
    }

    @objc private func handleTapDimmedView() {
        dismissBottomSheet()
    }

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        // get drag direction
        let isDraggingDown = translation.y > 0
        guard isDraggingDown else { return }
        let pannedHeight = translation.y
        let currentY = self.view.frame.height - self.mainContainerView.frame.height
        // handle gesture state
        switch gesture.state {
        case .changed:
            // This state will occur when user is dragging
            self.mainContainerView.frame.origin.y = currentY + pannedHeight
        case .ended:
            // When user stop dragging
            // if fulfil the condition dismiss it, else move to original position
            if pannedHeight >= Constants.minDismissiblePanHeight {
                dismissBottomSheet()
            } else {
                self.mainContainerView.frame.origin.y = currentY
            }
        default:
            break
        }
    }

    private func animatePresent() {
        dimmedView.alpha = 0
        // add more animation duration for smoothness
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.dimmedView.alpha = Constants.maxDimmedAlpha
        }
    }

    func dismissBottomSheet() {
        UIView.animate(withDuration: 0.2, animations: {  [weak self] in
            guard let self = self else { return }
            self.dimmedView.alpha = Constants.maxDimmedAlpha
            self.mainContainerView.frame.origin.y = self.view.frame.height
        }, completion: {  [weak self] _ in
            self?.dismiss(animated: false)
        })
    }

    // sub-view controller will call this function to set content
    func setContent(content: UIView) {
        contentView.addSubview(content)
        NSLayoutConstraint.activate([
            content.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            content.topAnchor.constraint(equalTo: contentView.topAnchor),
            content.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        view.layoutIfNeeded()
    }
}

extension BottomSheetController {
    enum Constants {
        /// Maximum alpha for dimmed view
        static let maxDimmedAlpha: CGFloat = 0.8
        /// Minimum drag vertically that enable bottom sheet to dismiss
        static let minDismissiblePanHeight: CGFloat = 20
        /// Minimum spacing between the top edge and bottom sheet
        static var minTopSpacing: CGFloat = 80
        /// Minimum bottom sheet height
        static let heightTopBarView = 32.0
        static let cornerRadiusTopRectangle = 2.0
        static let cornerRadiusView = 12.0
        static let topAnchorTopRectangle = 16.0
        static let widthTopRectangle = 48.0
        static let heightTopRectangle = 4.0
        static let bottomPaddingConstraint = 34.0
        static let safeAreaBottomPadding = 32.0
    }
}

extension UIViewController {
    func presentBottomSheet(viewController: BottomSheetController) {
        viewController.modalPresentationStyle = .overFullScreen
        present(viewController, animated: false, completion: nil)
    }
}
