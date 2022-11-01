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
        let view = ReviewBottomNavigationBar()
        view.delegate = self
        self.view = view
        return view
    }

    func set(loadingState isLoading: Bool) {
        view?.set(loadingState: isLoading)
    }

    func setMainButtonTitle(with title: String) {
        view?.setMainButtonTitle(with: title)
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
