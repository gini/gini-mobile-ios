//
//  PaymentComponentBottomView.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Combine
import UIKit
import GiniUtilites

public final class PaymentComponentBottomView: GiniBottomSheetViewController {

    private var paymentView: UIView

    private let emptyScrollView = EmptyScrollView()
    private let contentView = EmptyView()

    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []
    private var cancellables = Set<AnyCancellable>()
    
    public var shouldShowDragIndicator: Bool {
        true
    }
    
    public var shouldShowInFullScreenInLandscapeMode: Bool {
        false
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Detect the initial orientation and set up the appropriate constraints
        setupInitialLayout()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        notifyLayoutChanged()
    }

    public init(paymentView: UIView, bottomSheetConfiguration: BottomSheetConfiguration) {
        self.paymentView = paymentView
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = bottomSheetConfiguration.backgroundColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// This is to notify VoiceOver that the layout changed. The delay is needed to ensure that
    /// VoiceOver has already finished processing the UI changes.
    private func notifyLayoutChanged() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            UIAccessibility.post(notification: .layoutChanged, argument: contentView)
        }
    }

    private func setupView() {
        addScrollViewConstraints()
        configureBottomSheet()
        bindToSizeUpdate()
        setContent()
        contentView.addSubview(paymentView)

        NSLayoutConstraint.activate([
            paymentView.topAnchor.constraint(equalTo: contentView.topAnchor),
            paymentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func addScrollViewConstraints() {
        view.addSubview(emptyScrollView)
        emptyScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emptyScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setContent() {
        emptyScrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: emptyScrollView.topAnchor,
                                             constant: Constants.portraitPadding),
            contentView.leadingAnchor.constraint(equalTo: emptyScrollView.leadingAnchor),
            contentView.bottomAnchor.constraint(lessThanOrEqualTo: emptyScrollView.bottomAnchor),
            contentView.trailingAnchor.constraint(equalTo: emptyScrollView.trailingAnchor)
        ])
    }

    // Detect and setup initial layout based on the current orientation
    private func setupInitialLayout() {
        if UIDevice.isPortrait() {
            setupPortraitConstraints()
        } else {
            setupLandscapeConstraints()
        }
    }

    // Portrait Layout Constraints
    private func setupPortraitConstraints() {
        deactivateAllConstraints()
        portraitConstraints = [
            paymentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.portraitPadding),
            paymentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.portraitPadding)
        ]
        NSLayoutConstraint.activate(portraitConstraints)
    }

    // Landscape Layout Constraints
    private func setupLandscapeConstraints() {
        deactivateAllConstraints()
        landscapeConstraints = [
            paymentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.landscapePadding),
            paymentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.landscapePadding)
        ]
        NSLayoutConstraint.activate(landscapeConstraints)
    }
    
    private func deactivateAllConstraints() {
        NSLayoutConstraint.deactivate(portraitConstraints + landscapeConstraints)
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { [weak self] context in
            if UIDevice.isPortrait() {
                self?.setupPortraitConstraints()
            } else {
                self?.setupLandscapeConstraints()
            }
            
            self?.notifyLayoutChanged()
            self?.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func bindToSizeUpdate() {
        emptyScrollView.$size
            .receive(on: DispatchQueue.main)
            .sink { [weak self] size in
                self?.updateBottomSheetHeight(size.height)
            }.store(in: &cancellables)
    }
}

extension PaymentComponentBottomView {
    private enum Constants {
        static let portraitPadding = 16.0
        static let landscapePadding = 126.0
    }
}
