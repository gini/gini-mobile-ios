//
//  DefaultReviewBottomNavigationBarAdapter.swift
//  
//
//  Created by David Vizaknai on 21.10.2022.
//

import UIKit

class DefaultReviewBottomNavigationBarAdapter: ReviewScreenBottomNavigationBarAdapter {
    private var mainButtonCallback: (() -> Void)?
    private var secondaryButtonCallback: (() -> Void)?
    var view: ReviewBottomNavigationBar?

    func setMainButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        mainButtonCallback = callback
    }

    func setSecondaryButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        secondaryButtonCallback = callback
    }

    func injectedView() -> UIView {
        if let navigationBarView = ReviewBottomNavigationBar().loadNib() as? ReviewBottomNavigationBar {
            self.view = navigationBarView
            self.view?.delegate = self
            return navigationBarView
        } else {
            return UIView()
        }
    }

    func set(loadingState isLoading: Bool) {
        view?.set(loadingState: isLoading)
    }

    @objc func mainButtonClicked() {
        mainButtonCallback?()
    }

    @objc func secondaryButtonClicked() {
        secondaryButtonCallback?()
    }

    func onDeinit() {
        mainButtonCallback = nil
        secondaryButtonCallback = nil
    }
}

extension DefaultReviewBottomNavigationBarAdapter: ReviewBottomNavigationBarDelegate {
    func didTapMainButton(on navigationBar: ReviewBottomNavigationBar) {
        mainButtonClicked()
    }

    func didTapSecondaryButton(on navigationBar: ReviewBottomNavigationBar) {
        secondaryButtonClicked()
    }
}
