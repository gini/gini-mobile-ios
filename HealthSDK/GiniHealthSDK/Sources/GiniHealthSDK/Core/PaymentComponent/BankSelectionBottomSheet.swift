//
//  BankSelectionBottomSheet.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

final class BankSelectionBottomSheet: UIViewController {
    var bottomSheet: BanksBottomView! {
        didSet {
            setupLayout()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewHierarchy()
        setupViewAttributes()
    }

    private func setupViewHierarchy() {
        view.addSubview(bottomSheet)
    }

    private func setupViewAttributes() {
        definesPresentationContext = true
        view.backgroundColor = bottomSheet.viewModel.dimmingBackgroundColor
        
        bottomSheet.translatesAutoresizingMaskIntoConstraints = false
        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissViewController))
        gesture.direction = .down
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(gesture)
    }
    
    @objc
    private func dismissViewController() {
        bottomSheet.viewModel.didTapOnClose()
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            bottomSheet.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            bottomSheet.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -(bottomSheet.viewModel.bottomViewHeight)),
            bottomSheet.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            bottomSheet.heightAnchor.constraint(equalToConstant: bottomSheet.viewModel.bottomViewHeight)
        ])
    }
}
